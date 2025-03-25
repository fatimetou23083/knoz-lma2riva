// 2. Create a proper API service to handle all requests
// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../scholars_page.dart';  // Create this file later
import '../library_page.dart';
import '../book_data.dart';  // Create this file later
import '../search_result.dart';  // Create this file later

class ApiService {
  // Test API connection
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.statusEndpoint),
      ).timeout(Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Fetch all scholars with their playlists and videos
  static Future<List<Scholar>> fetchScholars() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.scholarsEndpoint));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> scholarsData = data['savants'];
        
        return scholarsData.map((scholarData) => Scholar.fromJson(scholarData)).toList();
      } else {
        throw Exception('Failed to load scholars: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching scholars: $e');
      throw Exception('Failed to load scholars: $e');
    }
  }

  // Fetch favorite videos
  static Future<List<Video>> fetchFavorites() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.favoritesEndpoint));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (!data.containsKey('videos')) {
          throw Exception("Data key 'videos' not found in response!");
        }
        
        final List<dynamic> videosData = data['videos'];
        return videosData
            .map((videoJson) => Video.fromJson(videoJson))
            .where((video) => video.isFavorite)
            .toList();
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching favorites: $e');
      throw Exception('Failed to load favorites: $e');
    }
  }

  // Update favorite status
  static Future<bool> updateFavorite(String videoId, bool isFavorite) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.updateFavoriteEndpoint),
        body: json.encode({
          'id': videoId,
          'est_favori': isFavorite
        }),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating favorite: $e');
      return false;
    }
  }

  // Record a downloaded video
  static Future<bool> recordDownload(Map<String, dynamic> downloadData) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.recordDownloadEndpoint),
        body: json.encode(downloadData),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error recording download: $e');
      return false;
    }
  }



  // إضافة إلى api_service.dart

// api_service.dart - in fetchBooks() method
// في api_service.dart
static Future<List<BookData>> fetchBooks() async {
  try {
    final response = await http.get(Uri.parse(AppConstants.booksEndpoint));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // تأكد من استخدام المفتاح الصحيح
      final String dataKey = data.containsKey('livres') ? 'livres' : 'books';
      
      if (!data.containsKey(dataKey)) {
        print('مفاتيح المتوفرة: ${data.keys.toList()}');
        throw Exception("مفتاح البيانات غير موجود في الاستجابة");
      }
      
      final List<dynamic> booksData = data[dataKey];
      return booksData.map((bookData) => BookData.fromJson(bookData)).toList();
    } else {
      throw Exception('فشل تحميل الكتب: ${response.statusCode}');
    }
  } catch (e) {
    print('خطأ في تحميل الكتب: $e');
    throw Exception('فشل تحميل الكتب: $e');
  }
}






// Corrección para la función search en api_service.dart

static Future<List<SearchResult>> search(String query) async {
  try {
    print('بدء البحث عن: "$query"');
    
    // بناء عنوان URL مع معالجة الأحرف الخاصة بشكل صحيح
    final String encodedQuery = Uri.encodeComponent(query);
    final String url = '${AppConstants.apiBaseUrl}search/?q=$encodedQuery';
    
    print('إرسال طلب إلى: $url');
    
    // إضافة محاولة مع مهلة محددة
    final response = await http.get(
      Uri.parse(url),
    ).timeout(Duration(seconds: 10));
    
    print('استجابة الخادم: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      // طباعة الاستجابة كاملة للتصحيح
      print('الاستجابة الكاملة: ${response.body}');
      
      final Map<String, dynamic> data = json.decode(response.body);
      
      // التحقق من وجود المفتاح الصحيح
      final String resultKey = data.containsKey('resultats') ? 'resultats' : 'results';
      
      if (!data.containsKey(resultKey)) {
        print('مفاتيح الاستجابة المتاحة: ${data.keys.toList()}');
        throw Exception('مفتاح النتائج غير موجود في استجابة البحث');
      }
      
      final List<dynamic> results = data[resultKey];
      print('عدد نتائج البحث المستلمة: ${results.length}');
      
      if (results.isEmpty) {
        return [];
      }
      
      // معالجة كل نتيجة بحث
      List<SearchResult> searchResults = [];
      for (var result in results) {
        try {
          final searchResult = SearchResult.fromJson(result);
          searchResults.add(searchResult);
          print('تمت إضافة نتيجة: ${searchResult.type} - ${searchResult.title}');
        } catch (e) {
          print('خطأ في معالجة نتيجة البحث: $e، البيانات: $result');
        }
      }
      
      print('إجمالي نتائج البحث المعالجة: ${searchResults.length}');
      return searchResults;
    } else {
      print('خطأ في استجابة الخادم: ${response.statusCode} - ${response.body}');
      throw Exception('فشل البحث: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('خطأ في البحث: $e');
    throw Exception('فشل البحث: $e');
  }
}








}




