import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'services/api_service.dart';
import 'book_data.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with SingleTickerProviderStateMixin {
  bool _isOptionsVisible = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // تعريف ألوان ثابتة للتطبيق
  final Color primaryColor = Color(0xFF2C5364);
  final Color secondaryColor = Color(0xFF203A43);
  final Color accentColor = Color(0xFF0F2027);
  final Color backgroundColor = Color(0xFFF5F5F5);
  final Color cardShadowColor = Color(0x40000000);

  // قائمة الكتب التي سيتم تحميلها من API
  List<BookData> books = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // تحميل الكتب من API
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      // حمّل الكتب من API
      final List<BookData> loadedBooks = await ApiService.fetchBooks();
      
      setState(() {
        books = loadedBooks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'فشل تحميل الكتب: $e';
        isLoading = false;
      });
      print('خطأ في تحميل الكتب: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOptionsVisible = !_isOptionsVisible;
      if (_isOptionsVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "المكتبة",
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isOptionsVisible ? Icons.close : Icons.menu,
              color: Colors.white,
            ),
            onPressed: _toggleMenu,
            iconSize: 24,
            splashRadius: 20,
          ),
        ],
      ),
      body: Stack(
        children: [
          // خلفية متدرجة
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [backgroundColor, Colors.white],
              ),
            ),
          ),
          
          // محتوى الصفحة
          isLoading 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    SizedBox(height: 20),
                    Text(
                      'جاري تحميل الكتب...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              )
            : errorMessage.isNotEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red),
                      SizedBox(height: 20),
                      Text(
                        errorMessage,
                        style: TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadBooks,
                        child: Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : books.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 60, color: Colors.grey),
                        SizedBox(height: 20),
                        Text(
                          'لا توجد كتب متاحة حالياً',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: GridView.builder(
                      padding: EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 24,
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return BookCard(
                          book: books[index],
                          primaryColor: primaryColor,
                          cardShadowColor: cardShadowColor,
                        );
                      },
                    ),
                  ),
          
          // القائمة الجانبية المحدثة
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SidebarMenu(
                isVisible: _isOptionsVisible,
                animation: _animation,
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
                accentColor: accentColor,
              );
            },
          ),
        ],
      ),
      // زر إعادة تحميل الكتب
      floatingActionButton: FloatingActionButton(
        onPressed: _loadBooks,
        backgroundColor: primaryColor,
        child: Icon(Icons.refresh),
        tooltip: 'تحديث قائمة الكتب',
      ),
    );
  }
}

class SidebarMenu extends StatelessWidget {
  final bool isVisible;
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  
  const SidebarMenu({
    Key? key,
    required this.isVisible,
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -220 * (1 - animation.value),
      top: 0,
      bottom: 0,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, secondaryColor, accentColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(-5, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Text(
                  'علماء شنقيط',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'كنوز المعرفة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'شروح وتفسير من عدة علماء',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              const Divider(color: Colors.white24, height: 1),
              _buildOption(context, "الواجهة", Icons.home, () => Navigator.pushNamed(context, '/')),
              _buildOption(context, "من نحن", Icons.info, () => Navigator.pushNamed(context, '/about')),
              _buildOption(context, "المفضلة", Icons.favorite, () => Navigator.pushNamed(context, '/favorites')),
              _buildOption(context, "العلماء", Icons.people, () => Navigator.pushNamed(context, '/scholars')),
              const Divider(color: Colors.white24, height: 1),
              const Spacer(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOption(
    BuildContext context, 
    String title, 
    IconData icon, 
    VoidCallback onTap, 
    {bool showArrow = true}
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showArrow)
                const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(width: 12),
              Icon(icon, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final BookData book;
  final Color primaryColor;
  final Color cardShadowColor;

  const BookCard({
    Key? key,
    required this.book,
    required this.primaryColor,
    required this.cardShadowColor,
  }) : super(key: key);

  @override
// في ملف library_page.dart، عدّل Widget build في BookCard
@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(
            book: book,
            primaryColor: primaryColor,
          ),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardShadowColor,
            spreadRadius: 1,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5, // زيادة المساحة للصورة
            child: Hero(
              tag: "book-${book.id}",
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  book.coverImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[400],
                          size: 50,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: primaryColor,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            // تحديد ارتفاع ثابت للجزء السفلي من البطاقة
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            height: 70, // حدد ارتفاع يناسب النصوص
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0xFFF7F7F7)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // استخدم الحجم الأدنى المطلوب فقط
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  book.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14, // تصغير حجم الخط
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: primaryColor,
                  ),
                  maxLines: 1, // اجعلها سطر واحد فقط
                  overflow: TextOverflow.ellipsis,
                ),
                if (book.author != null && book.author!.isNotEmpty)
                  Text(
                    book.author!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12, // نص أصغر للمؤلف
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}

class PDFViewerPage extends StatefulWidget {
  final BookData book;
  final Color primaryColor;

  const PDFViewerPage({
    Key? key,
    required this.book,
    required this.primaryColor,
  }) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> with SingleTickerProviderStateMixin {
  bool _isOptionsVisible = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final Color secondaryColor = Color(0xFF203A43);
  final Color accentColor = Color(0xFF0F2027);
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOptionsVisible = !_isOptionsVisible;
      if (_isOptionsVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book.title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: widget.primaryColor,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isOptionsVisible ? Icons.close : Icons.menu,
              color: Colors.white,
            ),
            onPressed: _toggleMenu,
            iconSize: 24,
          ),
        ],
      ),
      body: Stack(
        children: [
          // عارض PDF
          Hero(
            tag: "book-${widget.book.id}-pdf",
            child: SfPdfViewer.network(
              widget.book.pdfUrl,
              enableDoubleTapZooming: true,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              enableTextSelection: true,
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                setState(() {
                  errorMessage = 'فشل تحميل الملف: ${details.error}';
                });
              },
            ),
          ),

          // رسالة الخطأ
          if (errorMessage.isNotEmpty)
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 50, color: Colors.red),
                    SizedBox(height: 20),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('العودة للمكتبة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // القائمة الجانبية المحدثة
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SidebarMenu(
                isVisible: _isOptionsVisible,
                animation: _animation,
                primaryColor: widget.primaryColor,
                secondaryColor: secondaryColor,
                accentColor: accentColor,
              );
            },
          ),
        ],
      ),
    );
  }
}