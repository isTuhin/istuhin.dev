import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/config/portfolio_config.dart';
import '../models/developer_profile.dart';
import '../models/github_stats.dart';
import '../models/project_item.dart';
import '../models/skill_category.dart';
import '../models/social_channel.dart';
import '../repositories/portfolio_repository.dart';
import 'github_stats_service.dart';

/// Reactive controller synchronizing `isTuhin.dev`'s dynamic Supabase CMS tables
/// (`site_settings`, `projects`, `skill_categories`, `skills`, `contact_messages`)
/// and live GitHub telemetry (`stats`, 53-week `contributions` heatmap, monthly
/// `contributionActivity`, `featured` and `recent` repositories) across Home,
/// Store, Connect, Search, and Terminal.
///
/// Mirrors `POLL_MS = 60_000` from `dev.istuhin/components/stats/LiveStats.tsx`.
class PortfolioController extends ChangeNotifier {
  PortfolioController({
    this.repository = const PortfolioRepository(),
    PortfolioConfig initialConfig = PortfolioConfig.istuhinDev,
    this.githubService,
    this.pollInterval = const Duration(seconds: 60),
    this.autoStart = false,
  })  : _config = initialConfig,
        _githubStats = repository.seedGitHubStats,
        _projects = repository.projects,
        _skills = repository.skills;

  final PortfolioRepository repository;
  final GitHubStatsService? githubService;
  final Duration pollInterval;
  final bool autoStart;

  PortfolioConfig _config;
  GitHubStats _githubStats;
  List<ProjectItem> _projects;
  List<SkillItem> _skills;
  bool _isSyncing = false;
  String? _error;
  Timer? _pollTimer;
  bool _disposed = false;

  PortfolioConfig get config => _config;
  GitHubStats get githubStats => _githubStats;
  bool get isSyncing => _isSyncing;
  String? get error => _error;

  DeveloperProfile get profile => repository.profile;

  /// Dynamic products loaded from Supabase `public.projects`.
  /// Empty when no products are published in Supabase (`"No products listed yet."`).
  List<ProjectItem> get projects => _projects;

  List<ProjectItem> get featuredProducts =>
      _projects.where((p) => p.isFeaturedProduct).toList();

  List<ProjectItem> get nonFeaturedProducts =>
      _projects.where((p) => !p.isFeaturedProduct).toList();

  List<SkillItem> get skills => _skills;
  List<CertificateBadge> get certificates => repository.certificates;
  List<SocialChannel> get socials => repository.socials;

  List<GitHubRepo> get featuredRepos => _githubStats.featuredRepos;
  List<GitHubRepo> get recentRepos => _githubStats.recentRepos;

  List<SkillItem> skillsByDomain(SkillDomain domain) =>
      _skills.where((s) => s.domain == domain).toList();

  /// Starts initial load and optional 60-second background polling when a
  /// [GitHubStatsService] with `enableNetwork: true` is attached.
  void start() {
    final service = githubService;
    if (service == null) return;
    refresh();
    if (service.enableNetwork && _pollTimer == null) {
      _pollTimer = Timer.periodic(pollInterval, (_) => refresh());
    }
  }

  /// Refreshes Supabase CMS tables (`site_settings`, `projects`, `skills`) and
  /// live GitHub telemetry (`/api/github/overview/` + CORS fallback).
  Future<void> refresh() async {
    final service = githubService;
    if (service == null || _disposed) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final results = await Future.wait<Object>([
        service.loadSiteConfig(fallback: _config),
        service.loadStats(),
        service.loadProjects(fallback: _projects),
        service.loadSkills(fallback: _skills),
      ]);
      if (_disposed) return;
      _config = results[0] as PortfolioConfig;
      _githubStats = results[1] as GitHubStats;
      _projects = results[2] as List<ProjectItem>;
      _skills = results[3] as List<SkillItem>;
      _error = null;
    } catch (_) {
      if (_disposed) return;
      _error = 'GitHub stats temporarily unavailable.';
    } finally {
      if (!_disposed) {
        _isSyncing = false;
        notifyListeners();
      }
    }
  }

  /// Submits a contact form message to Supabase `public.submit_contact_message`.
  Future<ContactSubmitStatus> submitContactMessage({
    required String name,
    required String email,
    String subject = '',
    required String body,
    String honeypot = '',
  }) async {
    final service = githubService;
    if (service == null) {
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (name.trim().isEmpty ||
          email.trim().isEmpty ||
          !emailRegex.hasMatch(email.trim()) ||
          body.trim().isEmpty) {
        return ContactSubmitStatus.invalid;
      }
      return ContactSubmitStatus.sent;
    }
    return service.submitContactMessage(
      name: name,
      email: email,
      subject: subject,
      body: body,
      honeypot: honeypot,
    );
  }

  /// Allows tests or admin actions to push updated state and notify all tabs immediately.
  void updateData({
    PortfolioConfig? config,
    GitHubStats? githubStats,
    List<ProjectItem>? projects,
    List<SkillItem>? skills,
  }) {
    if (_disposed) return;
    var changed = false;
    if (config != null && config != _config) {
      _config = config;
      changed = true;
    }
    if (githubStats != null && githubStats != _githubStats) {
      _githubStats = githubStats;
      changed = true;
    }
    if (projects != null) {
      _projects = projects;
      changed = true;
    }
    if (skills != null) {
      _skills = skills;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    _pollTimer = null;
    super.dispose();
  }
}
