class SearchResult {
  final String type; // 'savant', 'video', or 'livre'
  final int id;
  final String title;
  final String? imageUrl;
  final bool? isFavorite;
  final int? playlistId;
  final int? scholarId;
  final String? author;

  SearchResult({
    required this.type,
    required this.id,
    required this.title,
    this.imageUrl,
    this.isFavorite,
    this.playlistId,
    this.scholarId,
    this.author,
  });

// Corrección para SearchResult.fromJson en search_result.dart

factory SearchResult.fromJson(Map<String, dynamic> json) {
  // طباعة البيانات الواردة للتصحيح
  print("معالجة بيانات البحث: $json");
  
  // التأكد من أن البيانات تحتوي على الحقول المطلوبة
  if (!json.containsKey('type') || !json.containsKey('id')) {
    print("خطأ: بيانات غير مكتملة في نتائج البحث");
    // إنشاء نتيجة افتراضية في حالة عدم وجود البيانات المطلوبة
    return SearchResult(
      type: json['type'] ?? 'unknown',
      id: json['id'] ?? 0,
      title: json['titre'] ?? json['title'] ?? 'عنوان غير معروف',
    );
  }
  
  // استخراج البيانات مع مراعاة أسماء الحقول المختلفة
  final String title = json['titre'] ?? json['title'] ?? '';
  final String type = json['type'];
  final int id = json['id'];
  
  // معالجة الصور بناءً على نوع النتيجة
  String? imageUrl;
  if (type == 'savant') {
    imageUrl = json['image'] ?? json['url_image'];
  } else if (type == 'livre') {
    imageUrl = json['image'] ?? json['url_cover'];
  }
  
  // معالجة المفضلة للفيديوهات
  bool? isFavorite;
  if (type == 'video') {
    isFavorite = json['est_favori'] ?? json['is_favorite'] ?? false;
  }
  
  // استخراج معرفات إضافية للفيديوهات
  int? playlistId, scholarId;
  if (type == 'video') {
    playlistId = json['liste_lecture_id'] ?? json['playlist_id'];
    scholarId = json['savant_id'] ?? json['scholar_id'];
  }
  
  // استخراج معلومات المؤلف للكتب
  String? author;
  if (type == 'livre') {
    author = json['auteur'] ?? json['author'];
  }
  
  // إنشاء وإرجاع كائن SearchResult
  return SearchResult(
    type: type,
    id: id,
    title: title,
    imageUrl: imageUrl,
    isFavorite: isFavorite,
    playlistId: playlistId,
    scholarId: scholarId,
    author: author,
  );
}
}