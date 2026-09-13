/// Bundled image assets. Registered under `assets/images/` in pubspec.yaml.
class AppImages {
  AppImages._();

  /// Square brand mark — a heart holding a setting sun, on the brand gradient.
  /// Carries its own background, so it sits safely on either theme.
  static const String logo = 'assets/images/logo.png';

  /// Horizontal lockup: mark plus "Amour Et Sincérité". Transparent, but the
  /// type is dark — only use it on a light surface.
  static const String wordmark = 'assets/images/wordmark.png';
}
