
import 'package:flutter/material.dart';
import 'about_page.dart';
import 'library_page.dart';
import 'scholars_page.dart';
import 'favorite.dart';
import 'download.dart';
import 'services/api_service.dart';
import 'search_result.dart';
import 'dart:async';
import 'arabic_search_page.dart'; // استيراد صفحة البحث الجديدة

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'كنوز المعرفة',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Amiri',
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const KnowledgeTreasuresPage(),
        '/about': (context) => const AboutPage(),
        '/library': (context) => const LibraryPage(),
        '/scholars': (context) => const ScholarsPage(),
        '/favorites': (context) => const FavoritesPage(),
        '/downloads': (context) => const DownloadsPage(),
      },
    );
  }
}

class KnowledgeTreasuresPage extends StatefulWidget {
  const KnowledgeTreasuresPage({super.key});

  @override
  State<KnowledgeTreasuresPage> createState() => _KnowledgeTreasuresPageState();
}

class _KnowledgeTreasuresPageState extends State<KnowledgeTreasuresPage> {
  String _searchText = "";
  bool _isSearching = false;
  List<SearchResult> _searchResultsData = [];
  List<String> _searchResults = [];

// تصحيح دالة البحث في ملف main.dart (في _KnowledgeTreasuresPageState)

// وظيفة البحث المبسطة
// Corrección para la función de búsqueda en main.dart

Future<List<String>> _search(String query) async {
  if (query.isEmpty) {
    setState(() {
      _searchResults = [];
      _searchResultsData = [];
      _isSearching = false;
    });
    return [];
  }
  
  setState(() {
    _isSearching = true;
  });
  
  try {
    print('بدء عملية البحث عن: "$query"');
    
    // استخدام خدمة API للبحث
    final results = await ApiService.search(query);
    print("نتائج API الأصلية: ${results.length}");
    
    if (results.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchResultsData = [];
        _isSearching = false;
      });
      print("لا توجد نتائج من API");
      return [];
    }
    
    // تحويل النتائج إلى صيغة نصية مع طباعة كل نتيجة للتصحيح
    List<String> formattedResults = [];
    for (var result in results) {
      String formattedResult;
      
      switch (result.type) {
        case 'livre':
          formattedResult = "كتاب: ${result.title}";
          break;
        case 'video':
          formattedResult = "فيديو: ${result.title}";
          break;
        case 'savant':
          formattedResult = "عالم: ${result.title}";
          break;
        default:
          formattedResult = "نتيجة: ${result.title}";
      }
      
      print("إضافة نتيجة: $formattedResult");
      formattedResults.add(formattedResult);
    }
    
    // تعيين النتائج مباشرة إلى متغيرات الحالة
    setState(() {
      _searchResults = List<String>.from(formattedResults);
      _searchResultsData = List<SearchResult>.from(results);
      _isSearching = false;
    });
    
    print("النتائج المنسقة: ${formattedResults.length}");
    print("تم العثور على ${_searchResults.length} نتيجة (متغير الحالة)");
    
    return formattedResults;
  } catch (e) {
    print('خطأ في البحث: $e');
    
    setState(() {
      _searchResults = ["حدث خطأ أثناء البحث"];
      _isSearching = false;
    });
    
    // إظهار رسالة خطأ للمستخدم
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("حدث خطأ أثناء البحث: ${e.toString()}"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: "حسنًا",
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
    
    return ["حدث خطأ أثناء البحث"];
  }
}

// دالة التنقل إلى نتيجة البحث
void _navigateToSearchResult(BuildContext context, SearchResult result) {
  print('التنقل إلى نتيجة البحث: ${result.type} - ${result.title}');
  
  switch (result.type) {
    case 'livre':
      // التنقل إلى صفحة المكتبة
      Navigator.pushNamed(context, '/library');
      break;
    case 'video':
      // التنقل إلى صفحة العلماء
      Navigator.pushNamed(context, '/scholars');
      break;
    case 'savant':
      // التنقل إلى صفحة العلماء
      Navigator.pushNamed(context, '/scholars');
      break;
    default:
      // إذا كان نوع النتيجة غير معروف، لا تفعل شيئًا
      print('نوع نتيجة البحث غير معروف: ${result.type}');
      break;
  }
}



  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF336B87),
                const Color(0xFF90AFC5).withOpacity(0.6),
              ],
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                // شريط التطبيق
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  expandedHeight: 80,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFF336B87).withOpacity(0.7),
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      "كنوز المعرفة: علماء شنقيط",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        shadows: [
                          Shadow(
                            color: Color(0x4D000000),
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),
                
                // زر البحث
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 15, 25, 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArabicSearchPage(
                              onSearch: _search,
                              searchResults: _searchResults,
                              searchResultsData: _searchResultsData,
                              isSearching: _isSearching,
                              onNavigate: _navigateToSearchResult,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Color(0xFF336B87),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'ابحث عن كتاب أو فيديو...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.normal,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // الأزرار الرئيسية
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildListDelegate([
                      // زر العلماء
                      _buildDashboardItem(
                        title: 'العلماء',
                        icon: Icons.play_circle_fill,
                        backgroundColor: const Color(0xFF90AFC5),
                        gradientEndColor: const Color(0xFF7090A5),
                        iconBackgroundColor: Colors.white.withOpacity(0.2),
                        onTap: () {
                          Navigator.pushNamed(context, '/scholars');
                        },
                      ),
                      // زر المكتبة
                      _buildDashboardItem(
                        title: 'المكتبة',
                        icon: Icons.menu_book_rounded,
                        backgroundColor: const Color(0xFFA5C882),
                        gradientEndColor: const Color(0xFF85A862),
                        iconBackgroundColor: Colors.white.withOpacity(0.2),
                        onTap: () {
                          Navigator.pushNamed(context, '/library');
                        },
                      ),
                      // زر من نحن
                     _buildDashboardItem(
                      title: 'من نحن',
                      icon: Icons.auto_stories,
                      backgroundColor: const Color(0xFF8D6E63),
                      gradientEndColor: const Color(0xFF6D4E43),
                      iconBackgroundColor: Colors.white.withOpacity(0.2),
                      onTap: () {
                        Navigator.pushNamed(context, '/about');
                      },
                    ),
                      // زر المفضلة
                      _buildDashboardItem(
                        title: 'المفضلة',
                        icon: Icons.favorite_rounded,
                        backgroundColor: const Color(0xFFE57373),
                        gradientEndColor: const Color(0xFFC55353),
                        iconBackgroundColor: Colors.white.withOpacity(0.2),
                        onTap: () {
                          Navigator.pushNamed(context, '/favorites');
                        },
                      ),
                    ]),
                  ),
                ),
                
                // بطاقة الترحيب
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(25, 0, 25, 25),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_stories,
                            size: 25,
                            color: Color(0xFF336B87),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "مرحباً بك في كنوز المعرفة",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF336B87),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "اكتشف كنوز العلم والمعرفة من خلال مكتبة متنوعة من الكتب والفيديوهات التعليمية لعلماء شنقيط",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardItem({
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color gradientEndColor,
    required Color iconBackgroundColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [backgroundColor, gradientEndColor],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// فئة مخصصة للبحث تدعم اللغة العربية
class ArabicSearchDelegate extends SearchDelegate<String> {
  final Future<void> Function(String) onSearch;
  final List<String> searchResults;
  final List<SearchResult> searchResultsData;
  final bool isSearching;
  final void Function(BuildContext, SearchResult) onNavigate;

  ArabicSearchDelegate({
    required this.onSearch,
    required this.searchResults,
    required this.searchResultsData,
    required this.isSearching,
    required this.onNavigate,
  }) : super(
          searchFieldLabel: 'ابحث عن كتاب أو فيديو...',
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  @override
  TextStyle? get searchFieldStyle => TextStyle(
    fontSize: 16,
    textBaseline: TextBaseline.alphabetic,
    locale: Locale('ar', 'EG'), // تعيين اللغة العربية
  );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF336B87),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        // إضافة خصائص إضافية للدعم العربي
        alignLabelWithHint: true,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.white,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    
    if (isSearching) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF336B87)),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Text(
          'لا توجد نتائج للبحث',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final result = searchResults[index];
          final isBook = result.startsWith("كتاب");
          final isVideo = result.startsWith("فيديو");
          final isScholar = result.startsWith("عالم");
          
          IconData iconData;
          Color iconColor;
          
          if (isBook) {
            iconData = Icons.book;
            iconColor = const Color(0xFFA5C882);
          } else if (isVideo) {
            iconData = Icons.play_circle_outline;
            iconColor = const Color(0xFF90AFC5);
          } else if (isScholar) {
            iconData = Icons.person;
            iconColor = const Color(0xFF336B87);
          } else {
            iconData = Icons.search;
            iconColor = Colors.grey;
          }
          
          return ListTile(
            leading: Icon(
              iconData,
              color: iconColor,
            ),
            title: Text(
              result,
              textAlign: TextAlign.right,
            ),
            onTap: () {
              close(context, result);
              if (index < searchResultsData.length) {
                onNavigate(context, searchResultsData[index]);
              }
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) {
      onSearch(query);
      
      if (isSearching) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF336B87)),
          ),
        );
      }
      
      if (searchResults.isNotEmpty) {
        return buildResults(context);
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'ابدأ البحث عن الكتب والفيديوهات',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}