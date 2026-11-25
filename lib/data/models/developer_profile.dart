///Immutable profile & identity model for Touhidur Rahman (`isTuhin`).
final class DeveloperProfile {
  const DeveloperProfile({
    required this.name,
    required this.handle,
    required this.domain,
    required this.role,
    required this.tagline,
    required this.bio,
    required this.location,
    required this.timezone,
    required this.availabilityLabel,
    required this.isAvailable,
    required this.email,
    required this.resumeUrl,
    required this.metrics,
  });

  final String name;
  final String handle;
  final String domain;
  final String role;
  final String tagline;
  final String bio;
  final String location;
  final String timezone;
  final String availabilityLabel;
  final bool isAvailable;
  final String email;
  final String resumeUrl;
  final List<ProfileMetric> metrics;
}

final class ProfileMetric {
  const ProfileMetric({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;
}
