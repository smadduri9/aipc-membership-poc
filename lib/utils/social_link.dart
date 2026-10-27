/// Validates a pasted profile link for Instagram, LinkedIn or Facebook.
/// Handles such as "@name" or "name" are rejected; the full link is required.
enum SocialPlatform { instagram, linkedin, facebook }

String? validateSocialLink(SocialPlatform platform, String input) {
  final value = input.trim();
  if (value.isEmpty) return null;
  final withScheme =
      value.startsWith(RegExp(r'https?://', caseSensitive: false))
      ? value
      : 'https://$value';
  final uri = Uri.tryParse(withScheme);
  if (uri == null || uri.host.isEmpty || !uri.host.contains('.')) {
    return _error(platform);
  }
  final host = uri.host.toLowerCase().replaceFirst(
    RegExp(r'^(www|m|in)\.'),
    '',
  );
  final hostOk = switch (platform) {
    SocialPlatform.instagram => host == 'instagram.com',
    SocialPlatform.linkedin => host == 'linkedin.com',
    SocialPlatform.facebook => host == 'facebook.com' || host == 'fb.com',
  };
  if (!hostOk) return _error(platform);
  final path = uri.path.replaceAll('/', '');
  if (path.isEmpty) return _error(platform);
  if (platform == SocialPlatform.linkedin &&
      !(uri.path.startsWith('/in/') || uri.path.startsWith('/company/'))) {
    return _error(platform);
  }
  return null;
}

String _error(SocialPlatform platform) {
  final example = switch (platform) {
    SocialPlatform.instagram => 'https://www.instagram.com/yourname',
    SocialPlatform.linkedin => 'https://www.linkedin.com/in/yourname',
    SocialPlatform.facebook => 'https://www.facebook.com/yourname',
  };
  return 'Paste the full profile link, for example $example';
}
