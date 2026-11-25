import '../models/developer_profile.dart';
import '../models/github_stats.dart';
import '../models/project_item.dart';
import '../models/skill_category.dart';
import '../models/social_channel.dart';

/// Baseline configuration defaults mirroring `dev.istuhin/lib/siteConfig.ts`
/// and `dev.istuhin/lib/skillsData.ts` before live Supabase CMS and GitHub
/// responses arrive. Contains ZERO synthetic heatmap data or fake products.
abstract final class PortfolioSeedData {
  static const profile = DeveloperProfile(
    name: 'Touhidur Rahman',
    handle: 'isTuhin',
    domain: 'istuhin.dev',
    role: 'lovestack software developer',
    tagline: 'This is',
    bio:
        'Full-stack developer focused on Flutter, Next.js, TypeScript, and automation. Founder energy behind Connectis, Niihut, and HackiisLab.',
    location: 'Dhaka, Bangladesh',
    timezone: 'UTC+06:00 (BST)',
    availabilityLabel: 'Available for remote collaboration',
    isAvailable: true,
    email: 'code@istuhin.dev',
    resumeUrl: 'https://istuhin.dev',
    metrics: [],
  );

  /// Store products are 100% dynamic from Supabase `public.projects`.
  /// When the database table has no published products, `StorePage` renders
  /// `"No products listed yet."` matching `dev.istuhin/components/store/ProductsSection.tsx`.
  static const projects = <ProjectItem>[];

  /// Default skill categories matching `dev.istuhin/lib/skillsData.ts` and
  /// Supabase `public.skill_categories` + `public.skills`.
  static const skills = <SkillItem>[
    // Languages & Mobile
    SkillItem(
      name: 'Dart',
      domain: SkillDomain.languagesMobile,
      proficiency: 0.98,
      levelLabel: 'Core',
      isPrimary: true,
    ),
    SkillItem(
      name: 'Flutter',
      domain: SkillDomain.languagesMobile,
      proficiency: 0.98,
      levelLabel: 'Core',
      isPrimary: true,
    ),
    SkillItem(
      name: 'JavaScript',
      domain: SkillDomain.languagesMobile,
      proficiency: 0.92,
      levelLabel: 'Core',
      isPrimary: true,
    ),
    SkillItem(
      name: 'TypeScript',
      domain: SkillDomain.languagesMobile,
      proficiency: 0.94,
      levelLabel: 'Core',
      isPrimary: true,
    ),
    SkillItem(
      name: 'Python',
      domain: SkillDomain.languagesMobile,
      proficiency: 0.88,
      levelLabel: 'Advanced',
    ),
    SkillItem(
      name: 'C++',
      domain: SkillDomain.languagesMobile,
      proficiency: 0.82,
      levelLabel: 'Systems',
    ),
    SkillItem(
      name: 'Swift',
      domain: SkillDomain.languagesMobile,
      proficiency: 0.80,
      levelLabel: 'Native iOS',
    ),
    SkillItem(
      name: 'Java',
      domain: SkillDomain.languagesMobile,
      proficiency: 0.82,
      levelLabel: 'Native Android',
    ),

    // Frontend
    SkillItem(
      name: 'React',
      domain: SkillDomain.frontend,
      proficiency: 0.94,
      levelLabel: 'Core',
      isPrimary: true,
    ),
    SkillItem(
      name: 'React Native',
      domain: SkillDomain.frontend,
      proficiency: 0.88,
      levelLabel: 'Cross-Platform',
    ),
    SkillItem(
      name: 'Next.js',
      domain: SkillDomain.frontend,
      proficiency: 0.95,
      levelLabel: 'Core',
      isPrimary: true,
    ),
    SkillItem(
      name: 'Vue.js',
      domain: SkillDomain.frontend,
      proficiency: 0.82,
      levelLabel: 'SPA',
    ),
    SkillItem(
      name: 'Tailwind CSS',
      domain: SkillDomain.frontend,
      proficiency: 0.96,
      levelLabel: 'Design Systems',
      isPrimary: true,
    ),
    SkillItem(
      name: 'HTML5',
      domain: SkillDomain.frontend,
      proficiency: 0.96,
      levelLabel: 'Web Standards',
    ),
    SkillItem(
      name: 'CSS3',
      domain: SkillDomain.frontend,
      proficiency: 0.95,
      levelLabel: 'Web Standards',
    ),
    SkillItem(
      name: 'Framer Motion',
      domain: SkillDomain.frontend,
      proficiency: 0.90,
      levelLabel: 'Animation',
    ),

    // Backend & Data
    SkillItem(
      name: 'Node.js',
      domain: SkillDomain.backendData,
      proficiency: 0.92,
      levelLabel: 'Core',
      isPrimary: true,
    ),
    SkillItem(
      name: 'Express.js',
      domain: SkillDomain.backendData,
      proficiency: 0.90,
      levelLabel: 'REST APIs',
    ),
    SkillItem(
      name: 'MongoDB',
      domain: SkillDomain.backendData,
      proficiency: 0.86,
      levelLabel: 'Document DB',
    ),
    SkillItem(
      name: 'PostgreSQL',
      domain: SkillDomain.backendData,
      proficiency: 0.92,
      levelLabel: 'Relational DB',
      isPrimary: true,
    ),
    SkillItem(
      name: 'Supabase',
      domain: SkillDomain.backendData,
      proficiency: 0.96,
      levelLabel: 'BaaS & RLS',
      isPrimary: true,
    ),
    SkillItem(
      name: 'Firebase',
      domain: SkillDomain.backendData,
      proficiency: 0.92,
      levelLabel: 'Realtime & Push',
    ),
    SkillItem(
      name: 'Docker',
      domain: SkillDomain.backendData,
      proficiency: 0.86,
      levelLabel: 'Containers',
    ),
    SkillItem(
      name: 'Zod',
      domain: SkillDomain.backendData,
      proficiency: 0.90,
      levelLabel: 'Validation',
    ),
    SkillItem(
      name: 'Resend',
      domain: SkillDomain.backendData,
      proficiency: 0.88,
      levelLabel: 'Email',
    ),

    // Tools & Automation
    SkillItem(
      name: 'Git',
      domain: SkillDomain.toolsAutomation,
      proficiency: 0.95,
      levelLabel: 'Version Control',
      isPrimary: true,
    ),
    SkillItem(
      name: 'n8n',
      domain: SkillDomain.toolsAutomation,
      proficiency: 0.94,
      levelLabel: 'Workflows',
      isPrimary: true,
    ),
    SkillItem(
      name: 'Puppeteer',
      domain: SkillDomain.toolsAutomation,
      proficiency: 0.90,
      levelLabel: 'Headless Chrome',
    ),
    SkillItem(
      name: 'Selenium',
      domain: SkillDomain.toolsAutomation,
      proficiency: 0.86,
      levelLabel: 'Browser Testing',
    ),
    SkillItem(
      name: 'Postman',
      domain: SkillDomain.toolsAutomation,
      proficiency: 0.94,
      levelLabel: 'API Testing',
    ),
    SkillItem(
      name: 'VS Code',
      domain: SkillDomain.toolsAutomation,
      proficiency: 0.96,
      levelLabel: 'IDE',
    ),
    SkillItem(
      name: 'GitHub Actions',
      domain: SkillDomain.toolsAutomation,
      proficiency: 0.92,
      levelLabel: 'CI/CD',
    ),
    SkillItem(
      name: 'Vercel',
      domain: SkillDomain.toolsAutomation,
      proficiency: 0.94,
      levelLabel: 'Cloud Edge',
    ),
  ];

  /// No hardcoded certificate pills — `BadgesContainer.tsx` renders only the live Holopin board.
  static const certificates = <CertificateBadge>[];

  static const socials = <SocialChannel>[
    SocialChannel(
      id: 'github',
      platform: 'GitHub',
      handle: '@isTuhin',
      url: 'https://github.com/isTuhin',
      subtitle: 'Open-source repositories & contribution graph',
      cliCommand: 'open github',
    ),
    SocialChannel(
      id: 'linkedin',
      platform: 'LinkedIn',
      handle: 'in/istuhin',
      url: 'https://linkedin.com/in/istuhin',
      subtitle: 'Professional network & engineering background',
      cliCommand: 'open linkedin',
    ),
    SocialChannel(
      id: 'devto',
      platform: 'Dev.to',
      handle: '@istuhin',
      url: 'https://dev.to/istuhin',
      subtitle: 'Technical articles & engineering deep-dives',
      cliCommand: 'open devto',
    ),
    SocialChannel(
      id: 'twitter',
      platform: 'Twitter',
      handle: '@istuhin',
      url: 'https://twitter.com/istuhin',
      subtitle: 'Building in public & product updates',
      cliCommand: 'open twitter',
    ),
    SocialChannel(
      id: 'instagram',
      platform: 'Instagram',
      handle: '@istuhin21',
      url: 'https://instagram.com/istuhin21',
      subtitle: 'Photography, travel & daily life',
      cliCommand: 'open instagram',
    ),
    SocialChannel(
      id: 'whatsapp',
      platform: 'WhatsApp',
      handle: 'WhatsApp',
      url: 'https://wa.me/qr/KGPL5IQIZZXYC1',
      subtitle: 'Direct messaging',
      cliCommand: 'open whatsapp',
    ),
    SocialChannel(
      id: 'codepen',
      platform: 'CodePen',
      handle: '@istuhin',
      url: 'https://codepen.com/istuhin',
      subtitle: 'UI experiments & frontend demos',
      cliCommand: 'open codepen',
    ),
  ];

  /// Real 53-week GitHub contribution calendar for `@isTuhin` synced from
  /// `https://istuhin.dev/api/github/overview/` (exact 23 active days, 376 total contributions).
  static final githubStats = GitHubStats(
    username: 'isTuhin',
    publicRepos: 14,
    totalStars: 25,
    totalForks: 1,
    followers: 9,
    following: 9,
    featuredCount: 1,
    annualContributions: 376,
    currentStreakDays: 8,
    profileUrl: 'https://github.com/isTuhin',
    fetchedAt: '2026-11-25T18:38:09Z',
    languages: const [
      GitHubLanguageCount(name: 'HTML', count: 1),
      GitHubLanguageCount(name: 'C', count: 1),
    ],
    contributionActivity: const [
      ContributionActivityGroup(
        monthKey: '2026-11',
        label: 'November 2026',
        totalCommits: 5,
        repositories: [
          ActivityRepoCommit(
            nameWithOwner: 'isTuhin/isTuhin',
            url: 'https://github.com/isTuhin/isTuhin',
            commits: 4,
          ),
          ActivityRepoCommit(
            nameWithOwner: 'flutter/website',
            url: 'https://github.com/flutter/website',
            commits: 1,
          ),
        ],
      ),
    ],
    featuredRepos: const [
      GitHubRepo(
        id: 879103231,
        name: 'flutter_folder_structure',
        fullName: 'isTuhin/flutter_folder_structure',
        htmlUrl: 'https://github.com/isTuhin/flutter_folder_structure',
        language: 'C',
        stargazersCount: 7,
        forksCount: 1,
        createdAt: '2024-10-27T01:33:13Z',
        updatedAt: '2026-11-22T02:02:02Z',
        pushedAt: '2024-10-27T02:24:45Z',
      ),
    ],
    recentRepos: const [
      GitHubRepo(
        id: 1457174576,
        name: 'isTuhin',
        fullName: 'isTuhin/isTuhin',
        description: 'Profile README and developer configuration.',
        htmlUrl: 'https://github.com/isTuhin/isTuhin',
        stargazersCount: 2,
        forksCount: 0,
        updatedAt: '2026-11-25T00:00:00Z',
        pushedAt: '2026-11-25T00:00:00Z',
      ),
      GitHubRepo(
        id: 1457174577,
        name: 'mhcloth',
        fullName: 'isTuhin/mhcloth',
        htmlUrl: 'https://github.com/isTuhin/mhcloth',
        stargazersCount: 2,
        forksCount: 0,
        updatedAt: '2026-11-22T00:00:00Z',
        pushedAt: '2026-11-22T00:00:00Z',
      ),
      GitHubRepo(
        id: 879103231,
        name: 'flutter_folder_structure',
        fullName: 'isTuhin/flutter_folder_structure',
        htmlUrl: 'https://github.com/isTuhin/flutter_folder_structure',
        language: 'C',
        stargazersCount: 7,
        forksCount: 1,
        updatedAt: '2026-11-22T02:02:02Z',
        pushedAt: '2024-10-27T02:24:45Z',
      ),
      GitHubRepo(
        id: 4,
        name: 'istuhin.github.io',
        fullName: 'isTuhin/istuhin.github.io',
        htmlUrl: 'https://github.com/isTuhin/istuhin.github.io',
        language: 'HTML',
        stargazersCount: 7,
        forksCount: 0,
        updatedAt: '2026-11-18T00:00:00Z',
        pushedAt: '2026-11-18T00:00:00Z',
      ),
      GitHubRepo(
        id: 5,
        name: 'badge',
        fullName: 'isTuhin/badge',
        htmlUrl: 'https://github.com/isTuhin/badge',
        stargazersCount: 7,
        forksCount: 0,
        updatedAt: '2026-11-15T00:00:00Z',
        pushedAt: '2026-11-15T00:00:00Z',
      ),
    ],
    topLanguages: const {
      'HTML': 0.5,
      'C': 0.5,
    },
    contributionWeeks: _realSnapshotWeeks,
    heatmapWeeks: _realSnapshotWeeks
        .map((w) => w.map((d) => d.level).toList())
        .toList(),
  );

  /// Exact 23 real non-zero contribution days from `https://istuhin.dev/api/github/overview/`
  /// across the 53-week window (`2025-11-23` .. `2026-11-25`).
  static const Map<String, (int, int)> _realActiveDays = <String, (int, int)>{
    '2026-02-13': (1, 1),
    '2026-04-15': (1, 1),
    '2026-07-03': (3, 1),
    '2026-07-28': (6, 1),
    '2026-07-29': (15, 3),
    '2026-07-31': (1, 1),
    '2026-08-02': (1, 1),
    '2026-08-03': (1, 1),
    '2026-11-07': (25, 4),
    '2026-11-08': (25, 4),
    '2026-11-09': (72, 4),
    '2026-11-10': (93, 4),
    '2026-11-11': (8, 2),
    '2026-11-12': (39, 4),
    '2026-11-13': (5, 1),
    '2026-11-14': (9, 2),
    '2026-11-15': (4, 1),
    '2026-11-18': (2, 1),
    '2026-11-21': (1, 1),
    '2026-11-22': (4, 1),
    '2026-11-23': (14, 3),
    '2026-11-24': (26, 4),
    '2026-11-25': (20, 4),
  };

  static final List<List<ContributionDay>> _realSnapshotWeeks =
      _buildRealSnapshotWeeks();

  static List<List<ContributionDay>> _buildRealSnapshotWeeks() {
    final startSunday = DateTime.utc(2025, 11, 23);
    final lastDate = DateTime.utc(2026, 11, 25);
    final weeks = <List<ContributionDay>>[];

    for (var w = 0; w < 53; w++) {
      final week = <ContributionDay>[];
      for (var d = 0; d < 7; d++) {
        final dayDate = startSunday.add(Duration(days: (w * 7) + d));
        if (dayDate.isAfter(lastDate)) break;
        final y = dayDate.year.toString().padLeft(4, '0');
        final m = dayDate.month.toString().padLeft(2, '0');
        final dayStr = dayDate.day.toString().padLeft(2, '0');
        final iso = '$y-$m-$dayStr';
        final active = _realActiveDays[iso];
        week.add(
          ContributionDay(
            date: iso,
            count: active?.$1 ?? 0,
            level: active?.$2 ?? 0,
          ),
        );
      }
      weeks.add(week);
    }
    return weeks;
  }
}
