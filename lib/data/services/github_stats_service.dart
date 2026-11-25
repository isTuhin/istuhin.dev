import 'dart:convert';

import '../../core/config/portfolio_config.dart';
import '../../core/network/http_text_client.dart';
import '../../core/storage/local_preferences.dart';
import '../models/github_stats.dart';
import '../models/project_item.dart';
import '../models/skill_category.dart';
import '../repositories/portfolio_seed_data.dart';

/// Result status returned by [GitHubStatsService.submitContactMessage].
enum ContactSubmitStatus {
  sent,
  invalid,
  server,
}

/// Synchronizes live GitHub telemetry (`stats`, `featured` repos, `repositories`,
/// 53-week `contributions` heatmap, and `contributionActivity`) and Supabase CMS
/// tables (`site_settings`, `projects`, `skill_categories`, `skills`, `contact_messages`)
/// from `asestiivtrpixfxpnhyt.supabase.co` and `https://istuhin.dev/api/github/overview/`.
class GitHubStatsService {
  GitHubStatsService({
    LocalPreferences? preferences,
    this.enableNetwork = true,
    this.overviewEndpoint = 'https://istuhin.dev/api/github/overview/',
    this.supabaseUrl = defaultSupabaseUrl,
    this.supabaseAnonKey = defaultSupabaseAnonKey,
    String? username,
  })  : _preferences = preferences ?? LocalPreferences(),
        username = (username != null && username.trim().isNotEmpty)
            ? username.trim()
            : PortfolioSeedData.githubStats.username;

  static const String defaultSupabaseUrl =
      'https://asestiivtrpixfxpnhyt.supabase.co';
  static const String defaultSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzZXN0aWl2dHJwaXhmeHBuaHl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUwODkzODgsImV4cCI6MjEwMDY2NTM4OH0.Vb_uSLlCc9WHuQA6YfCklV-In9OSrR5VksHR27LZ9j4';

  static const _cacheKeyPrefix = 'github_overview_v3_';
  final LocalPreferences? _preferences;
  final bool enableNetwork;
  final String overviewEndpoint;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String username;

  String get _cacheKey => '$_cacheKeyPrefix${username.toLowerCase()}';

  Map<String, String> get _supabaseHeaders => <String, String>{
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Accept': 'application/json',
      };

  Future<GitHubStats> loadStats() async {
    var current = PortfolioSeedData.githubStats;
    final prefs = _preferences;

    // 1. Load last cached v3 snapshot first so offline/startup is instant
    if (prefs != null) {
      final cachedRaw = await prefs.getString(_cacheKey);
      if (cachedRaw != null && cachedRaw.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedRaw);
          if (decoded is Map<String, dynamic>) {
            current = GitHubStats.fromOverviewPayload(
              decoded,
              fallback: current,
            );
          }
        } on FormatException {
          // Ignore malformed cache
        }
      }
    }

    if (!enableNetwork) return current;

    try {
      // 2. Primary live fetch from `https://istuhin.dev/api/github/overview/`
      final normalizedUrl = overviewEndpoint.endsWith('/')
          ? overviewEndpoint
          : '$overviewEndpoint/';
      final overviewUri = Uri.tryParse(normalizedUrl);
      if (overviewUri != null) {
        final body = await HttpTextClient.getText(
          overviewUri,
          headers: const <String, String>{
            'Accept': 'application/json',
          },
        );
        if (body != null && body.isNotEmpty) {
          final decoded = jsonDecode(body);
          if (decoded is Map<String, dynamic> && decoded['data'] != null) {
            final liveStats = GitHubStats.fromOverviewPayload(
              decoded,
              fallback: current,
            );
            if (prefs != null) {
              await prefs.setString(
                _cacheKey,
                jsonEncode(liveStats.toOverviewJson()),
              );
            }
            return liveStats;
          }
        }
      }

      // 3. Chrome Web CORS-safe live fallback:
      // Queries `github-contributions-api.jogruber.de/v4/<username>?y=last` (Access-Control-Allow-Origin: *)
      // alongside `api.github.com/users/<username>` + `/repos` in parallel.
      final results = await Future.wait<String?>([
        HttpTextClient.getText(
          Uri.parse(
            'https://github-contributions-api.jogruber.de/v4/$username?y=last',
          ),
          headers: const <String, String>{'Accept': 'application/json'},
        ),
        HttpTextClient.getText(
          Uri.https('api.github.com', '/users/$username'),
          headers: const <String, String>{
            'Accept': 'application/vnd.github+json',
          },
        ),
        HttpTextClient.getText(
          Uri.https(
            'api.github.com',
            '/users/$username/repos',
            <String, String>{
              'per_page': '100',
              'type': 'owner',
              'sort': 'updated',
            },
          ),
          headers: const <String, String>{
            'Accept': 'application/vnd.github+json',
          },
        ),
      ]);

      final contribBody = results[0];
      final userBody = results[1];
      final reposBody = results[2];

      var annualContributions = current.annualContributions;
      var contributionWeeks = current.contributionWeeks;
      var heatmapWeeks = current.heatmapWeeks;
      var hasLiveData = false;

      if (contribBody != null && contribBody.isNotEmpty) {
        final contribJson = jsonDecode(contribBody);
        if (contribJson is Map<String, dynamic>) {
          final totalMap = contribJson['total'];
          if (totalMap is Map<String, dynamic>) {
            annualContributions =
                (totalMap['lastYear'] as num?)?.toInt() ?? annualContributions;
          }
          final rawDays = contribJson['contributions'];
          if (rawDays is List && rawDays.isNotEmpty) {
            final allDays = rawDays
                .whereType<Map<String, dynamic>>()
                .map(ContributionDay.fromJson)
                .toList();
            if (allDays.isNotEmpty) {
              final groupedWeeks = <List<ContributionDay>>[];
              var currentWeek = <ContributionDay>[];
              for (final day in allDays) {
                final parsed = DateTime.tryParse('${day.date}T00:00:00Z');
                // GitHub weeks start on Sunday (weekday == 7 in Dart)
                if (parsed != null &&
                    parsed.weekday == DateTime.sunday &&
                    currentWeek.isNotEmpty) {
                  groupedWeeks.add(currentWeek);
                  currentWeek = <ContributionDay>[];
                }
                currentWeek.add(day);
                if (currentWeek.length == 7) {
                  groupedWeeks.add(currentWeek);
                  currentWeek = <ContributionDay>[];
                }
              }
              if (currentWeek.isNotEmpty) {
                groupedWeeks.add(currentWeek);
              }
              if (groupedWeeks.isNotEmpty) {
                contributionWeeks = groupedWeeks;
                heatmapWeeks = groupedWeeks
                    .map((w) => w.map((d) => d.level).toList())
                    .toList();
                hasLiveData = true;
              }
            }
          }
        }
      }

      var publicRepos = current.publicRepos;
      var followers = current.followers;
      var following = current.following;
      var recentRepos = current.recentRepos;
      var featuredRepos = current.featuredRepos;
      var totalStars = current.totalStars;
      var totalForks = current.totalForks;
      var languages = current.languages;

      if (userBody != null && userBody.isNotEmpty) {
        final userJson = jsonDecode(userBody);
        if (userJson is Map<String, dynamic>) {
          publicRepos =
              (userJson['public_repos'] as num?)?.toInt() ?? publicRepos;
          followers = (userJson['followers'] as num?)?.toInt() ?? followers;
          following = (userJson['following'] as num?)?.toInt() ?? following;
          hasLiveData = true;
        }
      }

      if (reposBody != null && reposBody.isNotEmpty) {
        final reposList = jsonDecode(reposBody);
        if (reposList is List) {
          final mapped = reposList
              .whereType<Map<String, dynamic>>()
              .map(GitHubRepo.fromJson)
              .where((r) => !r.fork && !r.archived)
              .toList();
          if (mapped.isNotEmpty) {
            recentRepos = mapped.take(24).toList();
            final sortedByStars = [...mapped]
              ..sort(
                (a, b) => b.stargazersCount.compareTo(a.stargazersCount),
              );
            featuredRepos = sortedByStars.take(1).toList();
            totalStars = mapped.fold<int>(
              0,
              (sum, r) => sum + r.stargazersCount,
            );
            totalForks = mapped.fold<int>(
              0,
              (sum, r) => sum + r.forksCount,
            );
            final langCounts = <String, int>{};
            for (final r in mapped) {
              final lang = r.language;
              if (lang != null && lang.isNotEmpty) {
                langCounts[lang] = (langCounts[lang] ?? 0) + 1;
              }
            }
            languages = langCounts.entries
                .map((e) => GitHubLanguageCount(name: e.key, count: e.value))
                .toList()
              ..sort((a, b) => b.count.compareTo(a.count));
            hasLiveData = true;
          }
        }
      }

      if (hasLiveData) {
        final updated = current.copyWith(
          publicRepos: publicRepos,
          followers: followers,
          following: following,
          totalStars: totalStars,
          totalForks: totalForks,
          featuredCount: featuredRepos.length,
          featuredRepos: featuredRepos,
          recentRepos: recentRepos,
          languages: languages,
          annualContributions: annualContributions,
          contributionWeeks: contributionWeeks,
          heatmapWeeks: heatmapWeeks,
          fetchedAt: DateTime.now().toUtc().toIso8601String(),
          isLive: true,
        );
        if (prefs != null) {
          await prefs.setString(
            _cacheKey,
            jsonEncode(updated.toOverviewJson()),
          );
        }
        return updated;
      }
    } catch (_) {
      // Offline or test environment: return cached or real snapshot cleanly.
    }

    return current;
  }

  /// Fetches dynamic `site_settings` (`id=1`) from the public Supabase REST table
  /// with local cache fallback in [LocalPreferences].
  Future<PortfolioConfig> loadSiteConfig({
    PortfolioConfig fallback = PortfolioConfig.istuhinDev,
  }) async {
    const cacheKey = 'cms_site_settings_v2';
    var current = fallback;
    final prefs = _preferences;

    if (prefs != null) {
      final cachedRaw = await prefs.getString(cacheKey);
      if (cachedRaw != null && cachedRaw.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedRaw);
          if (decoded is Map<String, dynamic>) {
            current = PortfolioConfig.fromSiteSettingsJson(decoded);
          }
        } on FormatException {
          // Ignore malformed cache
        }
      }
    }

    if (!enableNetwork || supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      return current;
    }

    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/site_settings?id=eq.1');
      final body = await HttpTextClient.getText(
        uri,
        headers: _supabaseHeaders,
        timeout: const Duration(seconds: 4),
      );
      if (body != null && body.isNotEmpty) {
        final decoded = jsonDecode(body);
        if (decoded is List &&
            decoded.isNotEmpty &&
            decoded.first is Map<String, dynamic>) {
          final row = decoded.first as Map<String, dynamic>;
          final liveConfig = PortfolioConfig.fromSiteSettingsJson(row);
          if (prefs != null) {
            await prefs.setString(cacheKey, jsonEncode(liveConfig.toJson()));
          }
          return liveConfig;
        }
      }
    } catch (_) {
      // Offline or test environment: return cached or default config cleanly.
    }

    return current;
  }

  /// Fetches published & visible products from Supabase `public.projects`
  /// (`SELECT * FROM public.projects WHERE published = true AND visible = true ORDER BY sort_order ASC`).
  /// Returns an empty list when no products are published in Supabase (never fake products).
  Future<List<ProjectItem>> loadProjects({
    List<ProjectItem> fallback = const <ProjectItem>[],
  }) async {
    const cacheKey = 'cms_projects_v1';
    var current = fallback;
    final prefs = _preferences;

    if (prefs != null) {
      final cachedRaw = await prefs.getString(cacheKey);
      if (cachedRaw != null && cachedRaw.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedRaw);
          if (decoded is List) {
            current = decoded
                .whereType<Map<String, dynamic>>()
                .map(ProjectItem.fromSupabaseJson)
                .toList();
          }
        } on FormatException {
          // Ignore malformed cache
        }
      }
    }

    if (!enableNetwork || supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      return current;
    }

    try {
      final uri = Uri.parse(
        '$supabaseUrl/rest/v1/projects?select=*&published=eq.true&visible=eq.true&order=sort_order.asc',
      );
      final body = await HttpTextClient.getText(
        uri,
        headers: _supabaseHeaders,
        timeout: const Duration(seconds: 4),
      );
      if (body != null && body.isNotEmpty) {
        final decoded = jsonDecode(body);
        if (decoded is List) {
          final liveProjects = decoded
              .whereType<Map<String, dynamic>>()
              .map(ProjectItem.fromSupabaseJson)
              .toList();
          if (prefs != null) {
            await prefs.setString(
              cacheKey,
              jsonEncode(liveProjects.map((p) => p.toJson()).toList()),
            );
          }
          return liveProjects;
        }
      }
    } catch (_) {
      // Return cached or empty list on offline state.
    }

    return current;
  }

  /// Fetches dynamic `skill_categories` and `skills` from Supabase CMS.
  Future<List<SkillItem>> loadSkills({
    List<SkillItem> fallback = PortfolioSeedData.skills,
  }) async {
    if (!enableNetwork || supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      return fallback;
    }

    try {
      final results = await Future.wait<String?>([
        HttpTextClient.getText(
          Uri.parse(
            '$supabaseUrl/rest/v1/skill_categories?select=*&visible=eq.true&order=sort_order.asc',
          ),
          headers: _supabaseHeaders,
          timeout: const Duration(seconds: 4),
        ),
        HttpTextClient.getText(
          Uri.parse(
            '$supabaseUrl/rest/v1/skills?select=*&visible=eq.true&order=sort_order.asc',
          ),
          headers: _supabaseHeaders,
          timeout: const Duration(seconds: 4),
        ),
      ]);

      final catsRaw = results[0];
      final skillsRaw = results[1];
      if (catsRaw != null && skillsRaw != null) {
        final catsList = jsonDecode(catsRaw);
        final skillsList = jsonDecode(skillsRaw);
        if (catsList is List &&
            catsList.isNotEmpty &&
            skillsList is List &&
            skillsList.isNotEmpty) {
          final catIdToDomain = <String, SkillDomain>{};
          for (var i = 0; i < catsList.length; i++) {
            final c = catsList[i];
            if (c is Map<String, dynamic>) {
              final id = (c['id'] ?? '').toString();
              final title = (c['title'] as String? ?? '').toLowerCase();
              final domain = title.contains('front')
                  ? SkillDomain.frontend
                  : title.contains('back') || title.contains('data')
                      ? SkillDomain.backendData
                      : title.contains('tool') || title.contains('auto')
                          ? SkillDomain.toolsAutomation
                          : SkillDomain.values[i % SkillDomain.values.length];
              if (id.isNotEmpty) {
                catIdToDomain[id] = domain;
              }
            }
          }

          final mappedSkills = <SkillItem>[];
          for (final s in skillsList) {
            if (s is Map<String, dynamic>) {
              final name = (s['name'] as String? ?? '').trim();
              final catId = (s['category_id'] ?? '').toString();
              final domain = catIdToDomain[catId];
              if (name.isNotEmpty && domain != null) {
                mappedSkills.add(
                  SkillItem(
                    name: name,
                    domain: domain,
                    proficiency: 0.92,
                    levelLabel: 'Core',
                  ),
                );
              }
            }
          }
          if (mappedSkills.isNotEmpty) {
            return mappedSkills;
          }
        }
      }
    } catch (_) {
      // Fallback to default skills on offline state.
    }

    return fallback;
  }

  /// Submits a message to Supabase `public.submit_contact_message` RPC
  /// (`public.contact_messages` table).
  Future<ContactSubmitStatus> submitContactMessage({
    required String name,
    required String email,
    String subject = '',
    required String body,
    String honeypot = '',
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    final cleanSubject = subject.trim();
    final cleanBody = body.trim();

    if (honeypot.trim().isNotEmpty) {
      return ContactSubmitStatus.sent;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (cleanName.isEmpty ||
        cleanName.length > 120 ||
        cleanEmail.isEmpty ||
        cleanEmail.length > 200 ||
        !emailRegex.hasMatch(cleanEmail) ||
        cleanBody.isEmpty ||
        cleanBody.length > 5000) {
      return ContactSubmitStatus.invalid;
    }

    if (!enableNetwork || supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      return ContactSubmitStatus.sent;
    }

    try {
      final uri =
          Uri.parse('$supabaseUrl/rest/v1/rpc/submit_contact_message');
      final responseText = await HttpTextClient.postJson(
        uri,
        headers: _supabaseHeaders,
        jsonBody: jsonEncode(<String, dynamic>{
          'p_name': cleanName,
          'p_email': cleanEmail,
          'p_subject': cleanSubject,
          'p_body': cleanBody,
          'p_honeypot': honeypot,
        }),
      );
      if (responseText != null && responseText.isNotEmpty) {
        final decoded = jsonDecode(responseText);
        if (decoded is Map<String, dynamic>) {
          final status = decoded['status'] as String? ?? '';
          if (status == 'sent') return ContactSubmitStatus.sent;
          if (status == 'invalid') return ContactSubmitStatus.invalid;
          return ContactSubmitStatus.server;
        }
      }
    } catch (_) {
      return ContactSubmitStatus.server;
    }

    return ContactSubmitStatus.server;
  }
}
