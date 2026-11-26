import 'package:material_ui/material_ui.dart';

import '../../core/config/portfolio_config.dart';
import '../../data/models/github_stats.dart';
import '../../data/models/project_item.dart';
import '../../data/models/skill_category.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../../data/services/portfolio_controller.dart';
import '../../shell/glass_bottom_nav.dart';

enum TerminalLineTone {
  prompt,
  normal,
  success,
  highlight,
  warning,
  error,
}

final class TerminalOutputEntry {
  const TerminalOutputEntry({
    required this.command,
    required this.lines,
    this.tone = TerminalLineTone.normal,
    this.relatedProject,
  });

  final String command;
  final List<String> lines;
  final TerminalLineTone tone;
  final ProjectItem? relatedProject;
}

/// Interactive `-zsh` command interpreter powering `isTuhin.dev`'s signature
/// macOS terminal experience (`dev.istuhin/components/terminal/commands.ts`).
class TerminalController extends ChangeNotifier {
  TerminalController({
    PortfolioRepository? repository,
    this.portfolioController,
    this.onNavigateTab,
    this.onSetThemeMode,
    this.onInspectProject,
  }) : _repository = repository ?? const PortfolioRepository() {
    _seedWelcomeBanner();
  }

  final PortfolioRepository _repository;
  final PortfolioController? portfolioController;
  final ValueChanged<int>? onNavigateTab;
  final ValueChanged<ThemeMode>? onSetThemeMode;
  final ValueChanged<ProjectItem>? onInspectProject;

  final List<TerminalOutputEntry> _entries = [];
  final List<String> _history = [];
  int _focusRequestId = 0;
  VoidCallback? _focusHandler;

  PortfolioConfig get _liveConfig =>
      portfolioController?.config ?? PortfolioConfig.istuhinDev;

  GitHubStats get _liveGitHubStats =>
      portfolioController?.githubStats ?? _repository.seedGitHubStats;

  List<TerminalOutputEntry> get entries => List.unmodifiable(_entries);
  List<String> get history => List.unmodifiable(_history);
  int get focusRequestId => _focusRequestId;

  /// Registers a synchronous focus handler (needed by mobile web to open the
  /// soft keyboard within the user's tap gesture).
  void attachFocusHandler(VoidCallback handler) {
    _focusHandler = handler;
  }

  /// Unregisters the synchronous focus handler when the terminal unmounts.
  void detachFocusHandler(VoidCallback handler) {
    if (_focusHandler == handler) {
      _focusHandler = null;
    }
  }

  /// Requests that the active terminal input field scroll into view and gain focus.
  void requestFocus() {
    _focusHandler?.call();
    _focusRequestId++;
    notifyListeners();
  }

  static const quickCommands = <String>[
    'help',
    'about',
    'skills',
    'store',
    'projects',
    'github',
    'experience',
    'contact',
    'clear',
  ];

  void _seedWelcomeBanner() {
    _entries.add(
      const TerminalOutputEntry(
        command: '',
        tone: TerminalLineTone.normal,
        lines: [
          'Interactive portfolio shell. Type `help` to begin.',
        ],
      ),
    );
  }

  void clear() {
    _entries
      ..clear()
      ..add(
        const TerminalOutputEntry(
          command: '',
          tone: TerminalLineTone.normal,
          lines: [
            'Terminal cleared. Type `help` for commands.',
          ],
        ),
      );
    notifyListeners();
  }

  void execute(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return;

    _history
      ..remove(trimmed)
      ..insert(0, trimmed);
    if (_history.length > 50) {
      _history.removeRange(50, _history.length);
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    final cmd = parts.first.toLowerCase();
    final args = parts.length > 1 ? parts.sublist(1) : const <String>[];
    final argString = args.join(' ').toLowerCase();
    final cfg = _liveConfig;

    switch (cmd) {
      case 'clear':
      case 'cls':
        clear();
        return;

      case 'help':
      case '?':
        _entries.add(
          TerminalOutputEntry(
            command: trimmed,
            tone: TerminalLineTone.normal,
            lines: const [
              'Available commands:',
              '  help        — Show available commands',
              '  about       — Introduction',
              '  skills      — Technical skills',
              '  store       — Store page (products + open source)',
              '  projects    — Public GitHub repositories',
              '  github      — GitHub profile stats',
              '  search <q>  — Search products, repos & skills',
              '  experience  — Professional experience',
              '  contact     — Contact information',
              '  theme       — Switch theme (theme dark | light | system)',
              '  clear       — Clear terminal history',
            ],
          ),
        );

      case 'about':
      case 'whoami':
        _entries.add(
          TerminalOutputEntry(
            command: trimmed,
            tone: TerminalLineTone.normal,
            lines: [
              cfg.brand,
              cfg.role,
              '',
              cfg.about,
              '',
              cfg.availability,
            ],
          ),
        );

      case 'skills':
      case 'stack':
        final filteredDomains = SkillDomain.values.where((d) {
          if (argString.isEmpty) return true;
          return d.cliFlag.contains(argString) ||
              d.title.toLowerCase().contains(argString);
        }).toList();
        final domains =
            filteredDomains.isEmpty ? SkillDomain.values : filteredDomains;
        final lines = <String>[];
        for (final domain in domains) {
          lines.add('> ${domain.title}');
          for (final s in _repository.skillsByDomain(domain)) {
            lines.add('  - ${s.name}');
          }
          lines.add('');
        }
        if (lines.isNotEmpty && lines.last.isEmpty) {
          lines.removeLast();
        }
        _entries.add(
          TerminalOutputEntry(
            command: trimmed,
            tone: TerminalLineTone.normal,
            lines: lines,
          ),
        );

      case 'experience':
        _entries.add(
          TerminalOutputEntry(
            command: trimmed,
            tone: TerminalLineTone.normal,
            lines: const [
              'Founder & Owner @ Connectis (Present — building)',
              '  - Social platform: messaging, posts, video, and mobile-banking flows',
              '  - End-to-end product and engineering across mobile and web',
              '',
              'Founder & Owner @ HackiisLab (Present)',
              '  - Digital products and services — apps, websites, and new experiments',
              '  - Hands-on full-stack delivery with modern tooling',
              '',
              'Founder & Owner @ Niihut (Present)',
              '  - Premium branded daily wear and footwear — limited, detail-finished',
              '  - Quality-first drops: expensive on purpose, craft over volume',
            ],
          ),
        );

      case 'store':
        _entries.add(
          TerminalOutputEntry(
            command: trimmed,
            tone: TerminalLineTone.normal,
            lines: [
              'Store — products and open source',
              '',
              '  Products     Apps, websites, and digital goods',
              '  Open source  Free public GitHub repositories',
              '',
              '${cfg.siteUrl}/store',
            ],
          ),
        );

      case 'projects':
      case 'ls':
        final g = _liveGitHubStats;
        final lines = <String>[
          'Open source (also on /store):',
          '',
          'Featured / pinned:',
        ];
        for (final r in g.featuredRepos.take(6)) {
          final lang =
              (r.language != null && r.language!.isNotEmpty) ? ' [${r.language}]' : '';
          lines.add('* ${r.name}$lang ★${r.stargazersCount}');
          if (r.description != null && r.description!.isNotEmpty) {
            lines.add('  ${r.description}');
          }
          lines.add('  ${r.htmlUrl}');
        }
        lines.add('');
        lines.add('Recent:');
        for (final r in g.recentRepos.take(8)) {
          final lang =
              (r.language != null && r.language!.isNotEmpty) ? ' [${r.language}]' : '';
          lines.add('- ${r.name}$lang ★${r.stargazersCount}');
          lines.add('  ${r.htmlUrl}');
        }
        _entries.add(
          TerminalOutputEntry(
            command: trimmed,
            tone: TerminalLineTone.normal,
            lines: lines,
          ),
        );

      case 'open':
      case 'cat':
      case 'inspect':
        if (argString.isEmpty) {
          _entries.add(
            TerminalOutputEntry(
              command: trimmed,
              tone: TerminalLineTone.warning,
              lines: const [
                'Usage: open <project-name> (e.g. "open connectis")',
              ],
            ),
          );
          break;
        }
        final match = _repository.findProjectByIdOrName(argString);
        if (match != null) {
          _entries.add(
            TerminalOutputEntry(
              command: trimmed,
              tone: TerminalLineTone.success,
              relatedProject: match,
              lines: [
                '★ ${match.title} (${match.year}) · ${match.role}',
                '  ${match.description}',
                '  Stack: ${match.techStack.join(' · ')}',
              ],
            ),
          );
          onInspectProject?.call(match);
        } else {
          _entries.add(
            TerminalOutputEntry(
              command: trimmed,
              tone: TerminalLineTone.error,
              lines: [
                'Command not found: $argString',
                'Type "help" to see available commands.',
              ],
            ),
          );
        }

      case 'github':
      case 'stats':
        final g = _liveGitHubStats;
        _entries.add(
          TerminalOutputEntry(
            command: trimmed,
            tone: TerminalLineTone.normal,
            lines: [
              'GitHub @${g.username}',
              '  repos     ${g.publicRepos}',
              '  stars     ${g.totalStars}',
              '  forks     ${g.totalForks}',
              '  followers ${g.followers}',
              '  featured  ${g.featuredCount}',
              '  contribs  ${g.annualContributions} (last year)',
              if (g.languages.isNotEmpty) ...[
                '',
                'Top languages:',
                for (final l in g.languages.take(8))
                  '  - ${l.name} (${l.count})',
              ],
              '',
              g.profileUrl,
            ],
          ),
        );

      case 'certs':
      case 'badges':
        final certs = _repository.certificates;
        _entries.add(
          TerminalOutputEntry(
            command: trimmed,
            tone: TerminalLineTone.normal,
            lines: [
              'Verified Credentials & Badges (${certs.length}):',
              for (final c in certs)
                '  ✦ [${c.credentialTag}] ${c.title} (${c.year})',
              cfg.holopinProfileUrl,
            ],
          ),
        );

      case 'contact':
      case 'socials':
        final socials = _repository.socials;
        _entries.add(
          TerminalOutputEntry(
            command: trimmed,
            tone: TerminalLineTone.normal,
            lines: [
              'email   ${cfg.email}',
              'github  https://github.com/${cfg.githubUsername}',
              'web     ${cfg.siteUrl}',
              '',
              'Socials:',
              for (final s in socials)
                '  ${s.platform.padRight(10)} ${s.url}',
            ],
          ),
        );
        if (cmd == 'contact' && argString == '--open') {
          onNavigateTab?.call(GlassBottomNav.connectPageIndex);
        }

      case 'theme':
        if (argString.contains('dark')) {
          onSetThemeMode?.call(ThemeMode.dark);
          _entries.add(
            TerminalOutputEntry(
              command: trimmed,
              tone: TerminalLineTone.success,
              lines: const ['Switched Liquid Glass appearance to Dark mode.'],
            ),
          );
        } else if (argString.contains('light')) {
          onSetThemeMode?.call(ThemeMode.light);
          _entries.add(
            TerminalOutputEntry(
              command: trimmed,
              tone: TerminalLineTone.success,
              lines: const ['Switched Liquid Glass appearance to Light mode.'],
            ),
          );
        } else if (argString.contains('system')) {
          onSetThemeMode?.call(ThemeMode.system);
          _entries.add(
            TerminalOutputEntry(
              command: trimmed,
              tone: TerminalLineTone.success,
              lines: const ['Switched appearance to follow System mode.'],
            ),
          );
        } else {
          _entries.add(
            TerminalOutputEntry(
              command: trimmed,
              tone: TerminalLineTone.warning,
              lines: const ['Usage: theme <dark|light|system>'],
            ),
          );
        }

      case 'goto':
      case 'cd':
        if (argString.contains('home') || argString == '~') {
          onNavigateTab?.call(GlassBottomNav.homePageIndex);
        } else if (argString.contains('project') ||
            argString.contains('store')) {
          onNavigateTab?.call(GlassBottomNav.storePageIndex);
        } else if (argString.contains('connect') ||
            argString.contains('contact')) {
          onNavigateTab?.call(GlassBottomNav.connectPageIndex);
        } else if (argString.contains('setting')) {
          onNavigateTab?.call(GlassBottomNav.settingsPageIndex);
        } else if (argString.contains('search') ||
            argString.contains('spotlight')) {
          onNavigateTab?.call(GlassBottomNav.searchPageIndex);
        }
        _entries.add(
          TerminalOutputEntry(
            command: trimmed,
            tone: TerminalLineTone.success,
            lines: ['Navigated to ${argString.isEmpty ? "~" : argString}.'],
          ),
        );

      case 'search':
      case 'find':
        if (argString.isEmpty) {
          _entries.add(
            TerminalOutputEntry(
              command: trimmed,
              tone: TerminalLineTone.warning,
              lines: const ['Usage: search <keyword> (e.g. search flutter)'],
            ),
          );
          break;
        }
        final products =
            (portfolioController?.projects ?? _repository.featuredProducts)
                .where((p) => p.matchesQuery(argString))
                .toList();
        final repos = _liveGitHubStats.recentRepos
            .where((r) => r.matchesQuery(argString))
            .toList();
        final skills = (portfolioController?.skills ?? _repository.skills)
            .where((s) => s.matchesQuery(argString))
            .toList();
        final results = <String>[
          for (final p in products.take(4)) '[store] ${p.title} — ${p.tagline}',
          for (final r in repos.take(5))
            '[repo]  ${r.name}${r.language != null ? " (${r.language})" : ""}',
          for (final s in skills.take(6))
            '[skill] ${s.name} · ${s.levelLabel}',
        ];
        _entries.add(
          TerminalOutputEntry(
            command: trimmed,
            tone: results.isEmpty
                ? TerminalLineTone.warning
                : TerminalLineTone.highlight,
            lines: results.isEmpty
                ? ['No matches found for "$argString".']
                : results,
          ),
        );

      default:
        _entries.add(
          TerminalOutputEntry(
            command: trimmed,
            tone: TerminalLineTone.error,
            lines: [
              'Command not found: $cmd',
              'Type "help" to see available commands.',
            ],
          ),
        );
    }

    notifyListeners();
  }
}
