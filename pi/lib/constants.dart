// 1. First, update constants.dart to include all API endpoints
// lib/constants.dart
class AppConstants {
  // API base URL for emulator
  static const String apiBaseUrl = "https://fatimetou23.pythonanywhere.com/api/";
  
  // API endpoints
  static const String scholarsEndpoint = "${apiBaseUrl}scholars/";
  static const String favoritesEndpoint = "${apiBaseUrl}favorites/";
  static const String updateFavoriteEndpoint = "${apiBaseUrl}update_favorite/";
  static const String recordDownloadEndpoint = "${apiBaseUrl}record_download/";
  static const String statusEndpoint = "${apiBaseUrl}status/";
 static const String booksEndpoint = "${apiBaseUrl}books/";
}

