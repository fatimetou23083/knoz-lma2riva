import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// إعادة استيراد scholars_page.dart لاستخدام نفس فئات Video و PlayList
import 'scholars_page.dart';
import 'video_player_page.dart';

const String apiUrl = "http://10.0.2.2:8000/api/";

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with SingleTickerProviderStateMixin {
  List<Video> favoriteVideos = [];
  bool isLoading = true;
  String? errorMessage;
  bool _isMenuVisible = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  final TextEditingController _searchController = TextEditingController();
  List<Video> _filteredVideos = [];
  
  // Map لتخزين حالة التحميل لكل فيديو بالمعرف
  Map<String, bool> _loadingVideoIds = {};

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    fetchFavoriteVideos();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterVideos(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredVideos = favoriteVideos;
      });
    } else {
      setState(() {
        _filteredVideos = favoriteVideos
            .where((video) => video.title.contains(query))
            .toList();
      });
    }
  }

  Future<void> fetchFavoriteVideos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      debugPrint("📡 جاري تحميل المفضلة من: ${apiUrl}favorites/");
      final response = await http.get(Uri.parse('${apiUrl}favorites/'));
      
      debugPrint("📊 حالة استجابة API: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (!jsonData.containsKey('videos')) {
          debugPrint("⚠️ خطأ: مفتاح 'videos' غير موجود في الاستجابة");
          throw Exception("Data key 'videos' not found in response!");
        }

        final List<dynamic> data = jsonData['videos'];
        debugPrint("📋 عدد الفيديوهات المفضلة: ${data.length}");

        setState(() {
          favoriteVideos = data
              .map((videoJson) => Video.fromJson(videoJson))
              .where((video) => video.isFavorite)
              .where((video) => video.localPath == null || video.localPath!.isEmpty)
              .toList();
          _filteredVideos = favoriteVideos;
          isLoading = false;
          debugPrint("✅ تم تحميل ${favoriteVideos.length} فيديو مفضل بنجاح");
        });
      } else {
        debugPrint("⚠️ خطأ API: الحالة ${response.statusCode}, الرد: ${response.body}");
        throw Exception('API Error: ${response.body}');
      }
    } catch (e) {
      debugPrint("❌ استثناء في fetchFavoriteVideos: $e");
      setState(() {
        isLoading = false;
        errorMessage = "حدث خطأ أثناء تحميل المفضلة.";
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("حدث خطأ أثناء تحميل قائمة المفضلة"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> toggleFavorite(Video video) async {
    // إظهار مؤشر التحميل
    setState(() {
      // اضبط حالة التحميل، مع التعامل مع إمكانية عدم وجود الخاصية
      try {
        // video.isLoading = true;
      } catch (e) {
        // في حالة عدم وجود الخاصية، نتجاهل الخطأ
        debugPrint("لا يمكن ضبط حالة التحميل: $e");
      } // نضيف خاصية جديدة لتتبع حالة التحميل
    });
    
    try {
      debugPrint("📡 تحديث حالة المفضلة للفيديو: ${video.title}");
      final response = await http.post(
        Uri.parse('${apiUrl}update_favorite/'),
        body: json.encode({
          'id': video.videoId, // تغيير من 'video_id' إلى 'id'
          'est_favori': !video.isFavorite // تغيير من 'is_favorite' إلى 'est_favori'
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          video.isFavorite = !video.isFavorite;
          
          // إذا تم إزالة الفيديو من المفضلة، نزيله من القائمة
          if (!video.isFavorite) {
            favoriteVideos.remove(video);
            _filteredVideos = List.from(favoriteVideos);
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(video.isFavorite ? "تمت الإضافة إلى المفضلة" : "تمت الإزالة من المفضلة"),
            backgroundColor: video.isFavorite ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
      } else {
        debugPrint("⚠️ خطأ في تحديث المفضلة: ${response.statusCode}, ${response.body}");
        throw Exception('فشل تحديث المفضلة');
      }
    } catch (e) {
      debugPrint("❌ استثناء عند تحديث المفضلة: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("خطأ أثناء تحديث المفضلة"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      // إخفاء مؤشر التحميل بغض النظر عن النتيجة
      setState(() {
        _loadingVideoIds[video.videoId] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            
            const Text(
              "المفضلة",
              style: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF336B87),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              setState(() {
                _isMenuVisible = !_isMenuVisible;
                if (_isMenuVisible) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFEEEEEE),
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterVideos,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: "ابحث في المفضلة...",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF336B87)),
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Color(0xFF336B87)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SidebarMenu(
                isVisible: _isMenuVisible,
                animation: _animation,
              );
            },
          ),
        ],
      ),
      floatingActionButton: isLoading ? null : FloatingActionButton(
        onPressed: () {
          setState(() {
            isLoading = true;
          });
          fetchFavoriteVideos().then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("تم تحديث قائمة المفضلة"),
                backgroundColor: Color(0xFF336B87),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          });
        },
        backgroundColor: Color(0xFF336B87),
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF336B87)),
            ),
            const SizedBox(height: 20),
            Text(
              'جاري تحميل المفضلة...',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Arial',
                color: Color(0xFF336B87),
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Arial',
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: fetchFavoriteVideos,
              icon: Icon(Icons.refresh),
              label: Text("إعادة المحاولة"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF336B87),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchController.text.isNotEmpty ? Icons.search_off : Icons.favorite_border,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'لا توجد نتائج للبحث'
                  : 'لا توجد فيديوهات في المفضلة',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Arial',
                color: Colors.grey.shade600,
              ),
            ),
            if (_searchController.text.isNotEmpty)
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _filterVideos('');
                },
                child: Text(
                  'مسح البحث',
                  style: TextStyle(
                    color: Color(0xFF336B87),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // إضافة مسافة في الأسفل للـ FAB
      itemCount: _filteredVideos.length,
      itemBuilder: (context, index) {
        final video = _filteredVideos[index];
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Card(
            elevation: 3,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerPage(
                      video: video,
                      playlist: PlayList(title: "المفضلة", videos: _filteredVideos),
                    ),
                  ),
                );
              },
                              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    // استخدام متغير loadingVideoId لتتبع أي فيديو يتم تحميله حاليًا
                    _loadingVideoIds[video.videoId] == true
                    ? Container(
                        width: 40,
                        height: 40,
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 28,
                            ),
                            onPressed: () => toggleFavorite(video),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.play_circle_filled,
                              color: Color(0xFF336B87),
                              size: 40,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerPage(
                                    video: video,
                                    playlist: PlayList(title: "المفضلة", videos: _filteredVideos),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            video.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2F3542),
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "تمت الإضافة إلى المفضلة",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SidebarMenu extends StatelessWidget {
  final bool isVisible;
  final Animation<double> animation;
  
  const SidebarMenu({
    super.key, 
    required this.isVisible,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -200 * (1 - animation.value),
      top: 0,
      bottom: 0,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Color(0xFF336B87),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 1,
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
                    color: Color(0xFF336B87),
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
              _buildOption(context, "المكتبة", Icons.library_books, () => Navigator.pushNamed(context, '/library')),
              _buildOption(context, "من نحن", Icons.info, () => Navigator.pushNamed(context, '/about')),
              _buildOption(context,"العلماء",Icons.people, () => Navigator.pushNamed(context, '/scholars'),
                  ),
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