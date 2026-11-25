/// Public GitHub repository model matching `GitHubRepo` in `dev.istuhin/lib/github/types.ts`.
final class GitHubRepo {
  const GitHubRepo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.htmlUrl,
    this.description,
    this.language,
    this.stargazersCount = 0,
    this.forksCount = 0,
    this.createdAt = '',
    this.updatedAt = '',
    this.pushedAt,
    this.topics = const [],
    this.fork = false,
    this.archived = false,
  });

  final int id;
  final String name;
  final String fullName;
  final String? description;
  final String htmlUrl;
  final String? language;
  final int stargazersCount;
  final int forksCount;
  final String createdAt;
  final String updatedAt;
  final String? pushedAt;
  final List<String> topics;
  final bool fork;
  final bool archived;

  bool matchesQuery(String rawQuery) {
    final q = rawQuery.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        fullName.toLowerCase().contains(q) ||
        (description?.toLowerCase().contains(q) ?? false) ||
        (language?.toLowerCase().contains(q) ?? false) ||
        topics.any((t) => t.toLowerCase().contains(q));
  }

  factory GitHubRepo.fromJson(Map<String, dynamic> json) {
    final rawTopics = json['topics'];
    return GitHubRepo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      fullName: (json['fullName'] ?? json['full_name']) as String? ?? '',
      description: json['description'] as String?,
      htmlUrl: (json['htmlUrl'] ?? json['html_url']) as String? ?? '',
      language: json['language'] as String?,
      stargazersCount:
          ((json['stargazersCount'] ?? json['stargazers_count']) as num?)
                  ?.toInt() ??
              0,
      forksCount:
          ((json['forksCount'] ?? json['forks_count']) as num?)?.toInt() ?? 0,
      createdAt: (json['createdAt'] ?? json['created_at']) as String? ?? '',
      updatedAt: (json['updatedAt'] ?? json['updated_at']) as String? ?? '',
      pushedAt: (json['pushedAt'] ?? json['pushed_at']) as String?,
      topics: rawTopics is List
          ? rawTopics.whereType<String>().toList()
          : const <String>[],
      fork: json['fork'] as bool? ?? false,
      archived: json['archived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'fullName': fullName,
        'description': description,
        'htmlUrl': htmlUrl,
        'language': language,
        'stargazersCount': stargazersCount,
        'forksCount': forksCount,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'pushedAt': pushedAt,
        'topics': topics,
        'fork': fork,
        'archived': archived,
      };
}

/// Language count entry matching `LanguageStat` in `dev.istuhin/lib/github/types.ts`.
final class GitHubLanguageCount {
  const GitHubLanguageCount({
    required this.name,
    required this.count,
  });

  final String name;
  final int count;

  factory GitHubLanguageCount.fromJson(Map<String, dynamic> json) {
    return GitHubLanguageCount(
      name: (json['name'] as String?) ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'count': count,
      };
}

/// Repository commit count inside a monthly activity bucket (`ActivityRepoCommit`).
final class ActivityRepoCommit {
  const ActivityRepoCommit({
    required this.nameWithOwner,
    required this.url,
    required this.commits,
  });

  final String nameWithOwner;
  final String url;
  final int commits;

  factory ActivityRepoCommit.fromJson(Map<String, dynamic> json) {
    return ActivityRepoCommit(
      nameWithOwner: (json['nameWithOwner'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      commits: (json['commits'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'nameWithOwner': nameWithOwner,
        'url': url,
        'commits': commits,
      };
}

/// Monthly commit breakdown matching `ContributionActivityGroup` in `dev.istuhin`.
final class ContributionActivityGroup {
  const ContributionActivityGroup({
    required this.monthKey,
    required this.label,
    required this.totalCommits,
    required this.repositories,
  });

  final String monthKey;
  final String label;
  final int totalCommits;
  final List<ActivityRepoCommit> repositories;

  factory ContributionActivityGroup.fromJson(Map<String, dynamic> json) {
    final rawRepos = json['repositories'];
    return ContributionActivityGroup(
      monthKey: (json['monthKey'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      totalCommits: (json['totalCommits'] as num?)?.toInt() ?? 0,
      repositories: rawRepos is List
          ? rawRepos
              .whereType<Map<String, dynamic>>()
              .map(ActivityRepoCommit.fromJson)
              .toList()
          : const <ActivityRepoCommit>[],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'monthKey': monthKey,
        'label': label,
        'totalCommits': totalCommits,
        'repositories': repositories.map((r) => r.toJson()).toList(),
      };
}

/// Single day cell inside the 53-week GitHub contribution calendar (`ContributionDay`).
final class ContributionDay {
  const ContributionDay({
    required this.date,
    required this.count,
    required this.level,
  });

  final String date;
  final int count;
  final int level;

  factory ContributionDay.fromJson(Map<String, dynamic> json) {
    return ContributionDay(
      date: (json['date'] as String?) ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      level: ((json['level'] as num?)?.toInt() ?? 0).clamp(0, 4),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'date': date,
        'count': count,
        'level': level,
      };
}

/// Snapshot of GitHub activity, contribution heatmap, repositories, and commit
/// breakdown for `@isTuhin` (`dev.istuhin/lib/github/types.ts`).
final class GitHubStats {
  const GitHubStats({
    required this.username,
    required this.publicRepos,
    required this.totalStars,
    required this.totalForks,
    required this.followers,
    required this.annualContributions,
    required this.currentStreakDays,
    required this.topLanguages,
    required this.heatmapWeeks,
    this.contributionWeeks = const [],
    this.following = 0,
    this.featuredCount = 1,
    this.languages = const [],
    this.contributionActivity = const [],
    this.featuredRepos = const [],
    this.recentRepos = const [],
    this.profileUrl = 'https://github.com/isTuhin',
    this.fetchedAt = '',
    this.isLive = false,
  });

  final String username;
  final int publicRepos;
  final int totalStars;
  final int totalForks;
  final int followers;
  final int following;
  final int featuredCount;
  final int annualContributions;
  final int currentStreakDays;
  final Map<String, double> topLanguages;
  final List<GitHubLanguageCount> languages;
  final List<ContributionActivityGroup> contributionActivity;
  final List<GitHubRepo> featuredRepos;
  final List<GitHubRepo> recentRepos;
  final String profileUrl;
  final String fetchedAt;

  /// Full 53-week calendar with per-day ISO `date`, `count`, and `level` (`0..4`).
  final List<List<ContributionDay>> contributionWeeks;

  /// Each week is a list of 7 intensity levels (`0..4`).
  final List<List<int>> heatmapWeeks;
  final bool isLive;

  GitHubStats copyWith({
    String? username,
    int? publicRepos,
    int? totalStars,
    int? totalForks,
    int? followers,
    int? following,
    int? featuredCount,
    int? annualContributions,
    int? currentStreakDays,
    Map<String, double>? topLanguages,
    List<GitHubLanguageCount>? languages,
    List<ContributionActivityGroup>? contributionActivity,
    List<GitHubRepo>? featuredRepos,
    List<GitHubRepo>? recentRepos,
    List<List<ContributionDay>>? contributionWeeks,
    List<List<int>>? heatmapWeeks,
    String? profileUrl,
    String? fetchedAt,
    bool? isLive,
  }) {
    return GitHubStats(
      username: username ?? this.username,
      publicRepos: publicRepos ?? this.publicRepos,
      totalStars: totalStars ?? this.totalStars,
      totalForks: totalForks ?? this.totalForks,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      featuredCount: featuredCount ?? this.featuredCount,
      annualContributions: annualContributions ?? this.annualContributions,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      topLanguages: topLanguages ?? this.topLanguages,
      languages: languages ?? this.languages,
      contributionActivity: contributionActivity ?? this.contributionActivity,
      featuredRepos: featuredRepos ?? this.featuredRepos,
      recentRepos: recentRepos ?? this.recentRepos,
      contributionWeeks: contributionWeeks ?? this.contributionWeeks,
      heatmapWeeks: heatmapWeeks ?? this.heatmapWeeks,
      profileUrl: profileUrl ?? this.profileUrl,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isLive: isLive ?? this.isLive,
    );
  }

  /// Parses the response from `https://istuhin.dev/api/github/overview`
  /// (`{ data: { stats, featured, repositories } }`).
  factory GitHubStats.fromOverviewPayload(
    Map<String, dynamic> payload, {
    required GitHubStats fallback,
  }) {
    final data = (payload['data'] is Map<String, dynamic>)
        ? payload['data'] as Map<String, dynamic>
        : payload;
    final statsJson = (data['stats'] is Map<String, dynamic>)
        ? data['stats'] as Map<String, dynamic>
        : data;

    final rawFeatured = data['featured'];
    final featuredRepos = rawFeatured is List
        ? rawFeatured
            .whereType<Map<String, dynamic>>()
            .map(GitHubRepo.fromJson)
            .toList()
        : fallback.featuredRepos;

    final rawRepos = data['repositories'];
    final recentRepos = rawRepos is List
        ? rawRepos
            .whereType<Map<String, dynamic>>()
            .map(GitHubRepo.fromJson)
            .toList()
        : fallback.recentRepos;

    final rawLangs = statsJson['languages'];
    final languages = rawLangs is List
        ? rawLangs
            .whereType<Map<String, dynamic>>()
            .map(GitHubLanguageCount.fromJson)
            .where((l) => l.name.isNotEmpty)
            .toList()
        : fallback.languages;

    final rawActivity = statsJson['contributionActivity'];
    final contributionActivity = rawActivity is List
        ? rawActivity
            .whereType<Map<String, dynamic>>()
            .map(ContributionActivityGroup.fromJson)
            .toList()
        : fallback.contributionActivity;

    var annualContribs = fallback.annualContributions;
    var heatmapWeeks = fallback.heatmapWeeks;
    var contributionWeeks = fallback.contributionWeeks;
    final contribsJson = statsJson['contributions'];
    if (contribsJson is Map<String, dynamic>) {
      annualContribs = (contribsJson['totalContributions'] as num?)?.toInt() ??
          annualContribs;
      final rawWeeks = contribsJson['weeks'];
      if (rawWeeks is List && rawWeeks.isNotEmpty) {
        final parsedWeeks = <List<int>>[];
        final parsedDayWeeks = <List<ContributionDay>>[];
        for (final week in rawWeeks) {
          if (week is List) {
            final days = <int>[];
            final fullDays = <ContributionDay>[];
            for (final day in week) {
              if (day is Map<String, dynamic>) {
                final parsedDay = ContributionDay.fromJson(day);
                days.add(parsedDay.level);
                fullDays.add(parsedDay);
              } else if (day is num) {
                final lvl = day.toInt().clamp(0, 4);
                days.add(lvl);
                fullDays.add(
                  ContributionDay(date: '', count: 0, level: lvl),
                );
              }
            }
            if (days.isNotEmpty) {
              parsedWeeks.add(days);
              parsedDayWeeks.add(fullDays);
            }
          }
        }
        if (parsedWeeks.isNotEmpty) {
          heatmapWeeks = parsedWeeks;
          contributionWeeks = parsedDayWeeks;
        }
      }
    }

    return fallback.copyWith(
      username: (statsJson['username'] as String?) ?? fallback.username,
      publicRepos:
          (statsJson['publicRepos'] as num?)?.toInt() ?? fallback.publicRepos,
      totalStars:
          (statsJson['totalStars'] as num?)?.toInt() ?? fallback.totalStars,
      totalForks:
          (statsJson['totalForks'] as num?)?.toInt() ?? fallback.totalForks,
      followers:
          (statsJson['followers'] as num?)?.toInt() ?? fallback.followers,
      following:
          (statsJson['following'] as num?)?.toInt() ?? fallback.following,
      featuredCount: (statsJson['featuredCount'] as num?)?.toInt() ??
          (featuredRepos.isNotEmpty
              ? featuredRepos.length
              : fallback.featuredCount),
      annualContributions: annualContribs,
      languages: languages,
      contributionActivity: contributionActivity,
      featuredRepos: featuredRepos,
      recentRepos: recentRepos,
      contributionWeeks: contributionWeeks,
      heatmapWeeks: heatmapWeeks,
      profileUrl: (statsJson['profileUrl'] as String?) ?? fallback.profileUrl,
      fetchedAt: (statsJson['fetchedAt'] as String?) ??
          (payload['cachedAt'] as String?) ??
          fallback.fetchedAt,
      isLive: true,
    );
  }

  Map<String, dynamic> toOverviewJson() => <String, dynamic>{
        'data': <String, dynamic>{
          'stats': <String, dynamic>{
            'username': username,
            'publicRepos': publicRepos,
            'totalStars': totalStars,
            'totalForks': totalForks,
            'followers': followers,
            'following': following,
            'featuredCount': featuredCount,
            'languages': languages.map((l) => l.toJson()).toList(),
            'contributions': <String, dynamic>{
              'totalContributions': annualContributions,
              'weeks': contributionWeeks.isNotEmpty
                  ? contributionWeeks
                      .map((w) => w.map((d) => d.toJson()).toList())
                      .toList()
                  : heatmapWeeks,
            },
            'contributionActivity':
                contributionActivity.map((a) => a.toJson()).toList(),
            'profileUrl': profileUrl,
            'fetchedAt': fetchedAt,
          },
          'featured': featuredRepos.map((r) => r.toJson()).toList(),
          'repositories': recentRepos.map((r) => r.toJson()).toList(),
        },
      };
}
