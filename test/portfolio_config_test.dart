import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_app/core/config/portfolio_config.dart';

void main() {
  group('PortfolioConfig & PortfolioNavResolver', () {
    test('brandLogoLabel concatenates brandPrefix and brandName without .dev', () {
      const config = PortfolioConfig.istuhinDev;
      expect(config.brand, 'isTuhin.dev');
      expect(config.brandLogoLabel, 'isTuhin');
    });

    test('getAppBarNavLinks excludes Store/Connect CTAs and legacy Stats links', () {
      const nav = <PortfolioNavItem>[
        PortfolioNavItem(name: 'Home', href: '/'),
        PortfolioNavItem(name: 'Store', href: '/store'),
        PortfolioNavItem(name: 'Blog', href: '/blog'),
        PortfolioNavItem(name: 'Connect', href: '/connect'),
        PortfolioNavItem(name: 'Stats', href: '/#stats'),
        PortfolioNavItem(name: 'Legacy', href: '/stats'),
      ];

      final links = PortfolioNavResolver.getAppBarNavLinks(nav);
      expect(
        links,
        equals(const <PortfolioNavItem>[
          PortfolioNavItem(name: 'Home', href: '/'),
          PortfolioNavItem(name: 'Blog', href: '/blog'),
        ]),
      );
    });

    test('getAppBarNavLinks appends external CV link only when cvUrl is safe', () {
      final withCv = PortfolioNavResolver.getAppBarNavLinks(
        PortfolioConfig.defaultNav,
        cvUrl: 'https://istuhin.dev/Resume.pdf',
      );
      expect(withCv.last.name, 'CV');
      expect(withCv.last.href, 'https://istuhin.dev/Resume.pdf');
      expect(withCv.last.isExternal, isTrue);

      final withUnsafeCv = PortfolioNavResolver.getAppBarNavLinks(
        PortfolioConfig.defaultNav,
        cvUrl: 'javascript:alert(1)',
      );
      expect(withUnsafeCv.any((l) => l.name == 'CV'), isFalse);
    });

    test('getAppBarCtas always resolves Store then Connect with fallbacks', () {
      final ctas = PortfolioNavResolver.getAppBarCtas(
        PortfolioConfig.defaultNav,
      );
      expect(
        ctas,
        equals(const <PortfolioNavItem>[
          PortfolioNavItem(name: 'Store', href: '/store'),
          PortfolioNavItem(name: 'Connect', href: '/connect'),
        ]),
      );

      final fallbackCtas = PortfolioNavResolver.getAppBarCtas(const []);
      expect(
        fallbackCtas,
        equals(const <PortfolioNavItem>[
          PortfolioNavItem(name: 'Store', href: '/store'),
          PortfolioNavItem(name: 'Connect', href: '/connect'),
        ]),
      );
    });

    test('isActivePath matches root and subpaths accurately', () {
      expect(PortfolioNavResolver.isActivePath('/', '/'), isTrue);
      expect(PortfolioNavResolver.isActivePath('/store', '/'), isFalse);
      expect(PortfolioNavResolver.isActivePath('/store', '/store'), isTrue);
      expect(PortfolioNavResolver.isActivePath('/store/item', '/store'), isTrue);
      expect(PortfolioNavResolver.isActivePath('/blog/post-1', '/blog/'), isTrue);
      expect(PortfolioNavResolver.isActivePath('/connect', '/store'), isFalse);
    });
  });
}
