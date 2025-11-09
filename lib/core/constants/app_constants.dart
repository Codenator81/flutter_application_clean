class AppConstants {
  // API
  static const String apiBaseUrl = 'https://api.example.com';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage
  static const String appBoxName = 'app_box';
  static const String userBoxName = 'user_box';

  // Shared Preferences Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyThemeMode = 'theme_mode';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  AppConstants._();
}
