/// Category taxonomy for `isTuhin.dev` digital products and open-source work.
enum ProjectCategory {
  product,
  mobile,
  web,
  openSource,
  automation;

  String get label => switch (this) {
        ProjectCategory.product => 'Products',
        ProjectCategory.mobile => 'Flutter & Mobile',
        ProjectCategory.web => 'Full-Stack Web',
        ProjectCategory.openSource => 'Open Source',
        ProjectCategory.automation => 'Automation & AI',
      };

  String get shortLabel => switch (this) {
        ProjectCategory.product => 'Products',
        ProjectCategory.mobile => 'Mobile',
        ProjectCategory.web => 'Web',
        ProjectCategory.openSource => 'OSS',
        ProjectCategory.automation => 'Automation',
      };

  static ProjectCategory fromRaw(String? raw) {
    final lower = (raw ?? '').trim().toLowerCase();
    if (lower.contains('mobile') || lower.contains('flutter')) {
      return ProjectCategory.mobile;
    }
    if (lower.contains('web')) return ProjectCategory.web;
    if (lower.contains('open') || lower.contains('oss')) {
      return ProjectCategory.openSource;
    }
    if (lower.contains('auto') || lower.contains('ai')) {
      return ProjectCategory.automation;
    }
    return ProjectCategory.product;
  }
}

/// Digital product from Supabase `public.projects` (`dev.istuhin/lib/supabase/types.ts`).
final class ProjectItem {
  const ProjectItem({
    required this.id,
    required this.title,
    required this.tagline,
    required this.description,
    required this.category,
    required this.techStack,
    this.categoryBadge = 'Product',
    this.slug = '',
    this.images = const [],
    this.role = 'Creator & Lead Engineer',
    this.isFeaturedProduct = false,
    this.liveUrl,
    this.repoUrl,
    this.highlights = const [],
    this.statusLabel = 'Product',
    this.accentHex = 0xFF00FF99,
    this.year = '2026',
    this.sortOrder = 0,
  });

  final String id;
  final String slug;
  final String title;
  final String tagline;
  final String description;
  final ProjectCategory category;
  final String categoryBadge;
  final List<String> techStack;
  final List<String> images;
  final String role;
  final bool isFeaturedProduct;
  final String? liveUrl;
  final String? repoUrl;
  final List<String> highlights;
  final String statusLabel;
  final int accentHex;
  final String year;
  final int sortOrder;

  String? get primaryHref =>
      (liveUrl != null && liveUrl!.trim().isNotEmpty)
          ? liveUrl!.trim()
          : (repoUrl != null && repoUrl!.trim().isNotEmpty)
              ? repoUrl!.trim()
              : null;

  factory ProjectItem.fromSupabaseJson(Map<String, dynamic> json) {
    final rawTech = json['technologies'];
    final techs = rawTech is List
        ? rawTech.whereType<String>().where((s) => s.trim().isNotEmpty).toList()
        : const <String>[];
    final rawImages = json['images'];
    final imgs = rawImages is List
        ? rawImages
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .toList()
        : const <String>[];
    final rawCat = (json['category'] as String?)?.trim() ?? '';
    final badge = rawCat.isNotEmpty ? rawCat : 'Product';
    final desc = (json['description'] as String?)?.trim() ?? '';
    final demoUrl = (json['demo_url'] as String?)?.trim();
    final githubUrl = (json['github_url'] as String?)?.trim();

    return ProjectItem(
      id: (json['id'] ?? json['slug'] ?? '').toString(),
      slug: (json['slug'] as String?)?.trim() ?? '',
      title: (json['title'] as String?)?.trim() ?? 'Untitled Product',
      tagline: desc,
      description: desc,
      category: ProjectCategory.fromRaw(rawCat),
      categoryBadge: badge,
      techStack: techs,
      images: imgs,
      isFeaturedProduct: json['featured'] as bool? ?? false,
      liveUrl: (demoUrl != null && demoUrl.isNotEmpty) ? demoUrl : null,
      repoUrl: (githubUrl != null && githubUrl.isNotEmpty) ? githubUrl : null,
      statusLabel: badge,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'slug': slug,
        'title': title,
        'description': description,
        'category': categoryBadge,
        'technologies': techStack,
        'images': images,
        'featured': isFeaturedProduct,
        'demo_url': liveUrl,
        'github_url': repoUrl,
        'sort_order': sortOrder,
      };

  bool matchesQuery(String rawQuery) {
    final q = rawQuery.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        tagline.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q) ||
        categoryBadge.toLowerCase().contains(q) ||
        techStack.any((t) => t.toLowerCase().contains(q));
  }
}
