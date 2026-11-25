/// Four-tier engineering stack domains featured on `istuhin.dev`.
enum SkillDomain {
  languagesMobile,
  frontend,
  backendData,
  toolsAutomation;

  String get title => switch (this) {
        SkillDomain.languagesMobile => 'Languages & Mobile',
        SkillDomain.frontend => 'Frontend & UI',
        SkillDomain.backendData => 'Backend, Cloud & Data',
        SkillDomain.toolsAutomation => 'Tools & Automation',
      };

  String get cliFlag => switch (this) {
        SkillDomain.languagesMobile => '--mobile',
        SkillDomain.frontend => '--frontend',
        SkillDomain.backendData => '--backend',
        SkillDomain.toolsAutomation => '--tools',
      };
}

final class SkillItem {
  const SkillItem({
    required this.name,
    required this.domain,
    required this.levelLabel,
    this.proficiency = 0.9,
    this.isPrimary = false,
    this.relatedProjectIds = const [],
  });

  final String name;
  final SkillDomain domain;
  final String levelLabel;
  final double proficiency;
  final bool isPrimary;
  final List<String> relatedProjectIds;

  bool matchesQuery(String rawQuery) {
    final q = rawQuery.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        domain.title.toLowerCase().contains(q) ||
        levelLabel.toLowerCase().contains(q);
  }
}

final class CertificateBadge {
  const CertificateBadge({
    required this.id,
    required this.title,
    required this.issuer,
    required this.year,
    required this.credentialTag,
    this.verifyUrl,
  });

  final String id;
  final String title;
  final String issuer;
  final String year;
  final String credentialTag;
  final String? verifyUrl;
}
