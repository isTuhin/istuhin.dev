/// Social and professional communication channels for `isTuhin.dev`.
final class SocialChannel {
  const SocialChannel({
    required this.id,
    required this.platform,
    required this.handle,
    required this.url,
    required this.subtitle,
    this.cliCommand,
  });

  final String id;
  final String platform;
  final String handle;
  final String url;
  final String subtitle;
  final String? cliCommand;

  bool matchesQuery(String rawQuery) {
    final q = rawQuery.trim().toLowerCase();
    if (q.isEmpty) return true;
    return platform.toLowerCase().contains(q) ||
        handle.toLowerCase().contains(q) ||
        subtitle.toLowerCase().contains(q);
  }
}

/// Outbound message drafted via the Connect page's Liquid Glass contact form.
final class ContactMessage {
  const ContactMessage({
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
  });

  final String name;
  final String email;
  final String subject;
  final String message;
}
