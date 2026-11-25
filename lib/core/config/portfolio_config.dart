import 'package:flutter/foundation.dart';

/// Canonical portfolio navigation destinations matching `istuhin.dev`.
enum PortfolioDestination {
  home('/'),
  store('/store'),
  blog('/blog'),
  connect('/connect'),
  external('');

  const PortfolioDestination(this.defaultHref);

  final String defaultHref;

  /// Resolves a normalized route path to its [PortfolioDestination].
  static PortfolioDestination fromHref(String href) {
    final normalized = PortfolioNavResolver.normalizeHref(href.split('#').first);
    return switch (normalized) {
      '/' || '' => PortfolioDestination.home,
      '/store' => PortfolioDestination.store,
      '/blog' => PortfolioDestination.blog,
      '/connect' => PortfolioDestination.connect,
      _ => PortfolioDestination.external,
    };
  }
}

/// Immutable navigation link entry for the portfolio header and footer.
@immutable
final class PortfolioNavItem {
  const PortfolioNavItem({
    required this.name,
    required this.href,
    this.external = false,
  });

  final String name;
  final String href;
  final bool external;

  PortfolioDestination get destination => isExternal
      ? PortfolioDestination.external
      : PortfolioDestination.fromHref(href);

  bool get isExternal => external || PortfolioNavResolver.isExternalHref(href);

  factory PortfolioNavItem.fromJson(Map<String, dynamic> json) {
    return PortfolioNavItem(
      name: (json['name'] as String? ?? '').trim(),
      href: (json['href'] as String? ?? '/').trim(),
      external: json['external'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'href': href,
        'external': external,
      };

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PortfolioNavItem &&
            other.name == name &&
            other.href == href &&
            other.external == external);
  }

  @override
  int get hashCode => Object.hash(name, href, external);
}

/// Social link entry from Supabase `site_settings.socials` (`dev.istuhin/lib/siteConfig.ts`).
@immutable
final class PortfolioSocialLink {
  const PortfolioSocialLink({
    required this.name,
    required this.url,
    this.color = 'hover:text-foreground',
  });

  final String name;
  final String url;
  final String color;

  factory PortfolioSocialLink.fromJson(Map<String, dynamic> json) {
    return PortfolioSocialLink(
      name: (json['name'] as String? ?? '').trim(),
      url: (json['url'] as String? ?? '').trim(),
      color: (json['color'] as String? ?? 'hover:text-foreground').trim(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'url': url,
        'color': color,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PortfolioSocialLink &&
          other.name == name &&
          other.url == url &&
          other.color == color);

  @override
  int get hashCode => Object.hash(name, url, color);
}

/// Contact email entry matching `ContactEmailConfig` in `dev.istuhin/lib/siteConfig.ts`.
@immutable
final class ContactEmailEntry {
  const ContactEmailEntry({
    required this.label,
    required this.address,
  });

  final String label;
  final String address;
}

/// Single channel item inside a Connect section (`ConnectLink` in `dev.istuhin/lib/connect.ts`).
@immutable
final class ConnectLinkItem {
  const ConnectLinkItem({
    required this.platform,
    required this.href,
    required this.accentHex,
  });

  final String platform;
  final String href;
  final int accentHex;
}

/// Grouped Connect section (`ConnectSection` in `dev.istuhin/lib/connect.ts`).
@immutable
final class ConnectSectionGroup {
  const ConnectSectionGroup({
    required this.title,
    required this.items,
  });

  final String title;
  final List<ConnectLinkItem> items;
}

/// Immutable portfolio site configuration mirroring `istuhin.dev` (`siteConfig.ts` & Supabase `site_settings`).
@immutable
final class PortfolioConfig {
  const PortfolioConfig({
    this.brand = 'isTuhin.dev',
    this.brandPrefix = 'is',
    this.brandName = 'Tuhin',
    this.brandSuffix = '.dev',
    this.tagline = 'This is',
    this.role = 'lovestack software developer',
    this.about =
        'Full-stack developer focused on Flutter, Next.js, TypeScript, and automation. Founder energy behind Connectis, Niihut, and HackiisLab.',
    this.availability = 'Available for remote collaboration',
    this.email = 'code@istuhin.dev',
    this.githubUsername = 'isTuhin',
    this.siteUrl = 'https://istuhin.dev',
    this.holopinProfileUrl = 'https://holopin.io/@istuhin',
    this.holopinBoardUrl = 'https://holopin.me/istuhin',
    this.cvUrl,
    this.terminalEnabled = true,
    this.nav = defaultNav,
    this.socials = defaultSocials,
    this.contactEmails = defaultContactEmails,
  });

  /// Canonical default portfolio configuration for `istuhin.dev`.
  static const PortfolioConfig istuhinDev = PortfolioConfig();

  static const List<PortfolioNavItem> defaultNav = <PortfolioNavItem>[
    PortfolioNavItem(name: 'Home', href: '/'),
    PortfolioNavItem(name: 'Store', href: '/store'),
    PortfolioNavItem(name: 'Blog', href: '/blog'),
    PortfolioNavItem(name: 'Connect', href: '/connect'),
  ];

  static const List<PortfolioSocialLink> defaultSocials =
      <PortfolioSocialLink>[
    PortfolioSocialLink(
      name: 'GitHub',
      url: 'https://github.com/isTuhin',
    ),
    PortfolioSocialLink(
      name: 'LinkedIn',
      url: 'https://linkedin.com/in/istuhin',
    ),
    PortfolioSocialLink(
      name: 'Dev.to',
      url: 'https://dev.to/istuhin',
    ),
    PortfolioSocialLink(
      name: 'Twitter',
      url: 'https://twitter.com/istuhin',
    ),
    PortfolioSocialLink(
      name: 'Instagram',
      url: 'https://instagram.com/istuhin21',
    ),
    PortfolioSocialLink(
      name: 'WhatsApp',
      url: 'https://wa.me/qr/KGPL5IQIZZXYC1',
    ),
    PortfolioSocialLink(
      name: 'CodePen',
      url: 'https://codepen.com/istuhin',
    ),
  ];

  static const List<PortfolioSocialLink> extraConnectSocials =
      <PortfolioSocialLink>[
    PortfolioSocialLink(
      name: 'GitLab',
      url: 'https://gitlab.com/istuhin',
    ),
    PortfolioSocialLink(
      name: 'Facebook',
      url: 'https://www.facebook.com/istuhin15',
    ),
    PortfolioSocialLink(
      name: 'Buy Me A Coffee',
      url: 'https://www.buymeacoffee.com/istuhin',
    ),
  ];

  static const List<ContactEmailEntry> defaultContactEmails =
      <ContactEmailEntry>[
    ContactEmailEntry(label: 'Business', address: 'code@istuhin.dev'),
    ContactEmailEntry(label: 'iCloud', address: 'istuhin@icloud.com'),
    ContactEmailEntry(label: 'ProtonMail', address: 'istuhin@protonmail.com'),
  ];

  static const Map<String, int> platformAccentHex = <String, int>{
    'Portfolio': 0xFF00FF99,
    'LinkedIn': 0xFF0A66C2,
    'GitHub': 0xFF9CA3AF,
    'GitLab': 0xFFFC6D26,
    'CodePen': 0xFF00BCD4,
    'Dev.to': 0xFFA855F7,
    'WhatsApp': 0xFF25D366,
    'Business': 0xFF00FF99,
    'iCloud': 0xFF147EFB,
    'ProtonMail': 0xFF6D4AFF,
    'Twitter': 0xFF38BDF8,
    'Instagram': 0xFFE1306C,
    'Facebook': 0xFF1877F2,
    'Buy Me A Coffee': 0xFFFFDD00,
  };

  final String brand;
  final String brandPrefix;
  final String brandName;
  final String brandSuffix;
  final String tagline;
  final String role;
  final String about;
  final String availability;
  final String email;
  final String githubUsername;
  final String siteUrl;
  final String holopinProfileUrl;
  final String holopinBoardUrl;
  final String? cvUrl;
  final bool terminalEnabled;
  final List<PortfolioNavItem> nav;
  final List<PortfolioSocialLink> socials;
  final List<ContactEmailEntry> contactEmails;

  /// Combined brand display label for the AppBar logo (`isTuhin`, without `.dev`).
  String get brandLogoLabel => '$brandPrefix$brandName';

  /// Resolved desktop navigation text links (excludes Store/Connect CTAs and legacy Stats).
  List<PortfolioNavItem> get appBarNavLinks =>
      PortfolioNavResolver.getAppBarNavLinks(nav, cvUrl: cvUrl);

  /// Resolved always-visible AppBar pill CTAs (`Store` and `Connect`).
  List<PortfolioNavItem> get appBarCtas =>
      PortfolioNavResolver.getAppBarCtas(nav);

  /// Builds the 4 Connect page sections matching `getConnectSections()` in `dev.istuhin/lib/connect.ts`.
  List<ConnectSectionGroup> get connectSections {
    final map = <String, String>{};
    for (final s in [...socials, ...extraConnectSocials]) {
      if (s.name.isNotEmpty && s.url.isNotEmpty) {
        map[s.name] = s.url;
      }
    }

    ConnectLinkItem? link(String platform, String? href) {
      if (href == null || href.trim().isEmpty) return null;
      return ConnectLinkItem(
        platform: platform,
        href: href.trim(),
        accentHex: platformAccentHex[platform] ?? 0xFF00FF99,
      );
    }

    ConnectLinkItem? pick(String name) => link(name, map[name]);

    final cleanSiteUrl = siteUrl.replaceAll(RegExp(r'/+$'), '');
    final resolvedEmails = <ContactEmailEntry>[
      ContactEmailEntry(
        label: 'Business',
        address: email.isNotEmpty ? email : 'code@istuhin.dev',
      ),
      for (final entry in contactEmails)
        if (entry.label != 'Business') entry,
    ];

    final sections = <ConnectSectionGroup>[
      ConnectSectionGroup(
        title: 'Direct Contact',
        items: [
          if (pick('WhatsApp') != null) pick('WhatsApp')!,
          for (final entry in resolvedEmails)
            if (link(entry.label, 'mailto:${entry.address}') != null)
              link(entry.label, 'mailto:${entry.address}')!,
        ],
      ),
      ConnectSectionGroup(
        title: 'Professional Networks',
        items: [
          if (link('Portfolio', cleanSiteUrl) != null)
            link('Portfolio', cleanSiteUrl)!,
          if (pick('LinkedIn') != null) pick('LinkedIn')!,
          if (pick('GitHub') != null) pick('GitHub')!,
          if (pick('GitLab') != null) pick('GitLab')!,
        ],
      ),
      ConnectSectionGroup(
        title: 'Development Platforms',
        items: [
          if (pick('CodePen') != null) pick('CodePen')!,
          if (pick('Dev.to') != null) pick('Dev.to')!,
        ],
      ),
      ConnectSectionGroup(
        title: 'Social & Support',
        items: [
          if (pick('Twitter') != null) pick('Twitter')!,
          if (pick('Instagram') != null) pick('Instagram')!,
          if (pick('Facebook') != null) pick('Facebook')!,
          if (pick('Buy Me A Coffee') != null) pick('Buy Me A Coffee')!,
        ],
      ),
    ];

    return sections.where((s) => s.items.isNotEmpty).toList();
  }

  /// Parses a Supabase `site_settings` row (`dev.istuhin/lib/cms/content.ts`).
  factory PortfolioConfig.fromSiteSettingsJson(Map<String, dynamic> json) {
    String nonEmptyOr(Object? raw, String fallback) {
      final s = (raw as String?)?.trim() ?? '';
      return s.isNotEmpty ? s : fallback;
    }

    final rawNav = json['nav'];
    final parsedNav = <PortfolioNavItem>[];
    if (rawNav is List) {
      for (final item in rawNav) {
        if (item is Map<String, dynamic>) {
          final navItem = PortfolioNavItem.fromJson(item);
          if (navItem.name.isNotEmpty &&
              PortfolioNavResolver.isSafeHref(navItem.href) &&
              !PortfolioNavResolver.isStatsNavLink(navItem)) {
            final lowerHref = navItem.href.trim().toLowerCase();
            final isLegacyProjects = lowerHref == '/#projects' ||
                lowerHref == '#projects' ||
                lowerHref == '/projects' ||
                navItem.name.toLowerCase() == 'projects';
            parsedNav.add(
              isLegacyProjects
                  ? const PortfolioNavItem(name: 'Store', href: '/store')
                  : navItem,
            );
          }
        }
      }
    }

    final rawSocials = json['socials'];
    final parsedSocials = <PortfolioSocialLink>[];
    if (rawSocials is List) {
      for (final item in rawSocials) {
        if (item is Map<String, dynamic>) {
          final social = PortfolioSocialLink.fromJson(item);
          if (social.name.isNotEmpty &&
              PortfolioNavResolver.isSafeHref(social.url)) {
            parsedSocials.add(social);
          }
        }
      }
    }

    final rawCv = (json['cv_url'] as String?)?.trim();
    final safeCv = PortfolioNavResolver.isSafeHref(rawCv) ? rawCv : null;
    final rawSiteUrl = (json['site_url'] as String?)?.trim();
    final safeSiteUrl = PortfolioNavResolver.isSafeHref(rawSiteUrl)
        ? rawSiteUrl!
        : istuhinDev.siteUrl;
    final ghUser = nonEmptyOr(
      json['github_username'],
      istuhinDev.githubUsername,
    ).replaceAll(RegExp(r'^@+'), '');

    return PortfolioConfig(
      brand: nonEmptyOr(json['brand'], istuhinDev.brand),
      brandPrefix: nonEmptyOr(json['brand_prefix'], istuhinDev.brandPrefix),
      brandName: nonEmptyOr(json['brand_name'], istuhinDev.brandName),
      brandSuffix: nonEmptyOr(json['brand_suffix'], istuhinDev.brandSuffix),
      tagline: nonEmptyOr(json['tagline'], istuhinDev.tagline),
      role: nonEmptyOr(
        json['role_title'] ?? json['role'],
        istuhinDev.role,
      ),
      about: nonEmptyOr(json['about'], istuhinDev.about),
      availability: nonEmptyOr(json['availability'], istuhinDev.availability),
      email: nonEmptyOr(json['email'], istuhinDev.email),
      githubUsername: ghUser.isNotEmpty ? ghUser : istuhinDev.githubUsername,
      siteUrl: safeSiteUrl,
      holopinProfileUrl: 'https://holopin.io/@${ghUser.toLowerCase()}',
      holopinBoardUrl: 'https://holopin.me/${ghUser.toLowerCase()}',
      cvUrl: safeCv,
      terminalEnabled: json['terminal_enabled'] as bool? ?? true,
      nav: parsedNav.isNotEmpty ? parsedNav : defaultNav,
      socials: parsedSocials.isNotEmpty ? parsedSocials : defaultSocials,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'brand': brand,
        'brand_prefix': brandPrefix,
        'brand_name': brandName,
        'brand_suffix': brandSuffix,
        'tagline': tagline,
        'role_title': role,
        'about': about,
        'availability': availability,
        'email': email,
        'github_username': githubUsername,
        'site_url': siteUrl,
        'cv_url': cvUrl,
        'terminal_enabled': terminalEnabled,
        'nav': nav.map((n) => n.toJson()).toList(),
        'socials': socials.map((s) => s.toJson()).toList(),
      };
}

/// Pure navigation resolution utilities ported from `istuhin.dev/lib/nav.ts`.
abstract final class PortfolioNavResolver {
  /// Canonical CTA route targets in display order (`Store` then `Connect`).
  static const List<String> ctaHrefs = <String>['/store', '/connect'];

  static const Map<String, String> _ctaFallbackNames = <String, String>{
    '/store': 'Store',
    '/connect': 'Connect',
  };

  static final RegExp _trailingSlashes = RegExp(r'/+$');
  static final RegExp _httpScheme = RegExp(r'^https?://', caseSensitive: false);

  /// Normalizes a path or href by trimming whitespace and trailing slashes.
  static String normalizeHref(String href) {
    final trimmed = href.trim();
    if (trimmed.isEmpty) return '/';
    if (trimmed.length == 1) return trimmed;
    final stripped = trimmed.replaceAll(_trailingSlashes, '');
    return stripped.isEmpty ? '/' : stripped;
  }

  /// Validates that an external or CV URL uses a safe scheme (`https://`, `http://`, or root-relative `/`).
  static bool isSafeHref(String? rawHref) {
    if (rawHref == null) return false;
    final trimmed = rawHref.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.startsWith('/') && !trimmed.startsWith('//')) {
      return !trimmed.contains(RegExp(r'[\x00-\x1F\x7F]'));
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return false;
    final scheme = uri.scheme.toLowerCase();
    return scheme == 'https' || scheme == 'http';
  }

  /// Whether [href] points to an external HTTP(S) origin.
  static bool isExternalHref(String href) {
    return _httpScheme.hasMatch(href.trim());
  }

  /// True when [pathname] matches or is a sub-route of [href].
  static bool isActivePath(String pathname, String href) {
    final current = normalizeHref(pathname.split('#').first);
    final targetPart = href.split('#').first;
    final target = normalizeHref(targetPart.isEmpty ? '/' : targetPart);
    if (target == '/') return current == '/';
    return current == target || current.startsWith('$target/');
  }

  /// Whether [href] is one of the primary AppBar CTA targets (`/store`, `/connect`).
  static bool isCtaHref(String href) {
    return ctaHrefs.contains(normalizeHref(href));
  }

  /// Drops legacy `Stats` / `#stats` / `/stats` entries.
  static bool isStatsNavLink(PortfolioNavItem link) {
    final name = link.name.trim().toLowerCase();
    final pathOnly = link.href.split('#').first;
    final href = normalizeHref(pathOnly.isEmpty ? '/' : pathOnly);
    final hashIndex = link.href.indexOf('#');
    final hash = hashIndex >= 0
        ? link.href.substring(hashIndex + 1).trim().toLowerCase()
        : '';
    return name == 'stats' || hash == 'stats' || href == '/stats';
  }

  /// Resolves desktop text links for the AppBar, excluding Store/Connect CTAs
  /// and legacy Stats links. Appends external `CV` link when [cvUrl] is safe.
  static List<PortfolioNavItem> getAppBarNavLinks(
    List<PortfolioNavItem> nav, {
    String? cvUrl,
  }) {
    final links = <PortfolioNavItem>[
      for (final link in nav)
        if (!isCtaHref(link.href) &&
            !isStatsNavLink(link) &&
            isSafeHref(link.href))
          link,
    ];

    if (isSafeHref(cvUrl)) {
      links.add(
        PortfolioNavItem(
          name: 'CV',
          href: cvUrl!.trim(),
          external: true,
        ),
      );
    }

    return List<PortfolioNavItem>.unmodifiable(links);
  }

  /// Resolves `Store` + `Connect` CTAs from [nav] with stable fallbacks.
  static List<PortfolioNavItem> getAppBarCtas(List<PortfolioNavItem> nav) {
    final ctas = <PortfolioNavItem>[];
    for (final href in ctaHrefs) {
      PortfolioNavItem? match;
      for (final item in nav) {
        if (normalizeHref(item.href) == href) {
          match = item;
          break;
        }
      }
      ctas.add(
        PortfolioNavItem(
          name: (match != null && match.name.trim().isNotEmpty)
              ? match.name.trim()
              : _ctaFallbackNames[href]!,
          href: (match != null && isSafeHref(match.href)) ? match.href : href,
          external: match?.external ?? false,
        ),
      );
    }
    return List<PortfolioNavItem>.unmodifiable(ctas);
  }
}
