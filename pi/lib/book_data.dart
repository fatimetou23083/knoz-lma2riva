// book_data.dart
class BookData {
  final int id;
  final String title;
  final String? author;
  final String? description;
  final String coverImageUrl;
  final String pdfUrl;

  BookData({
    required this.id,
    required this.title,
    this.author,
    this.description,
    required this.coverImageUrl,
    required this.pdfUrl,
  });

  factory BookData.fromJson(Map<String, dynamic> json) {
    // استخراج الروابط الأصلية
    String coverUrl = json['url_cover'] ?? '';
    String pdfUrl = json['url_pdf'] ?? '';
    
    // إصلاح المسارات قبل استخدامها
    if (coverUrl.contains('media/media/')) {
      coverUrl = coverUrl.replaceAll('media/media/', 'media/');
    }
    
    if (pdfUrl.contains('media/media/')) {
      pdfUrl = pdfUrl.replaceAll('media/media/', 'media/');
    }
    
    return BookData(
      id: json['id'],
      title: json['titre'],
      author: json['auteur'],
      description: json['description'],
      coverImageUrl: coverUrl,
      pdfUrl: pdfUrl,
    );
  }
}