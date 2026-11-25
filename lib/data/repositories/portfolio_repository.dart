import '../models/developer_profile.dart';
import '../models/github_stats.dart';
import '../models/project_item.dart';
import '../models/skill_category.dart';
import '../models/social_channel.dart';
import 'portfolio_seed_data.dart';

/// Read-only repository exposing all `isTuhin.dev` portfolio domain entities.
class PortfolioRepository {
  const PortfolioRepository();

  DeveloperProfile get profile => PortfolioSeedData.profile;

  List<ProjectItem> get projects => PortfolioSeedData.projects;

  List<ProjectItem> get featuredProducts =>
      PortfolioSeedData.projects.where((p) => p.isFeaturedProduct).toList();

  List<SkillItem> get skills => PortfolioSeedData.skills;

  List<CertificateBadge> get certificates => PortfolioSeedData.certificates;

  List<SocialChannel> get socials => PortfolioSeedData.socials;

  GitHubStats get seedGitHubStats => PortfolioSeedData.githubStats;

  List<SkillItem> skillsByDomain(SkillDomain domain) =>
      PortfolioSeedData.skills.where((s) => s.domain == domain).toList();

  ProjectItem? findProjectByIdOrName(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final project in PortfolioSeedData.projects) {
      if (project.id.toLowerCase() == normalized ||
          project.title.toLowerCase() == normalized ||
          project.title.toLowerCase().contains(normalized)) {
        return project;
      }
    }
    return null;
  }
}
