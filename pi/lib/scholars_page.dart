
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'video_player_page.dart';

const String apiUrl = "http://10.0.2.2:8000/api/";

class Video {
  final String title;
  final String videoId;
  bool isFavorite;
  final String downloadUrl;
  String? localPath;

  Video({
    required this.title,
    required this.videoId,
    required this.downloadUrl,
    this.isFavorite = false,
    this.localPath,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['titre'] ?? "بدون عنوان",
      videoId: json['id']?.toString() ?? "",
      downloadUrl: json['url_telechargement'] ?? '',
      isFavorite: json['est_favori'] ?? false,
      localPath: json['chemin_local'],
    );
  }
}

class PlayList {
  final String title;
  final List<Video> videos;

  PlayList({required this.title, required this.videos});
}

class Scholar {
  final String name;
  final String imagePath;
  final List<PlayList> playlists;

  Scholar({required this.name, required this.imagePath, required this.playlists});

  factory Scholar.fromJson(Map<String, dynamic> json) {
    List<PlayList> playlists = (json['listesLecture'] as List).map((playlistData) {
      List<Video> videos = (playlistData['videos'] as List)
          .map((videoData) => Video.fromJson(videoData as Map<String, dynamic>))
          .toList();
      return PlayList(title: playlistData['titre'], videos: videos);
    }).toList();
    
    return Scholar(
      name: json['nom'] ?? "غير معروف",
      imagePath: json['cheminImage'] ?? "",
      playlists: playlists,
    );
  }
}

class ScholarsPage extends StatefulWidget {
  const ScholarsPage({super.key});

  @override
  _ScholarsPageState createState() => _ScholarsPageState();
}

class _ScholarsPageState extends State<ScholarsPage> with SingleTickerProviderStateMixin {
  List<Scholar> scholarsList = [];
  bool isLoading = true;
  bool _isOptionsVisible = false;
  final TextEditingController _searchController = TextEditingController();
  List<Scholar> _filteredScholars = [];
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    fetchScholars();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterScholars(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredScholars = scholarsList;
      });
    } else {
      setState(() {
        _filteredScholars = scholarsList
            .where((scholar) => scholar.name.contains(query))
            .toList();
      });
    }
  }

  Future<void> fetchScholars() async {
    try {
      print("جاري تحميل العلماء من: ${apiUrl}scholars/");
      
      final response = await http.get(Uri.parse('${apiUrl}scholars/'));
      
      print("حالة استجابة API: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        print("الاستجابة الخام: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...");
        
        final jsonData = json.decode(response.body);
        
        if (!jsonData.containsKey('savants')) {
          print("خطأ: مفتاح 'savants' غير موجود في الاستجابة");
          throw Exception("مفتاح 'savants' غير موجود في استجابة API");
        }
        
        final data = jsonData['savants'];
        print("عدد العلماء المستلمين: ${data.length}");
        
        setState(() {
          scholarsList = data.map<Scholar>((scholarData) {
            print("بيانات العالم: ${scholarData['nom']}");
            
            List<PlayList> playlists = (scholarData['listesLecture'] as List).map((playlistData) {
              List<Video> videos = (playlistData['videos'] as List)
                  .map((videoData) => Video.fromJson(videoData))
                  .toList();
              return PlayList(title: playlistData['titre'], videos: videos);
            }).toList();

            return Scholar(
              name: scholarData['nom'] ?? "غير معروف",
              imagePath: scholarData['cheminImage'] ?? "",
              playlists: playlists,
            );
          }).toList();
          
          _filteredScholars = scholarsList;
          isLoading = false;
          print("تم تحميل ${scholarsList.length} عالم بنجاح");
        });
      } else {
        print("خطأ API: الحالة ${response.statusCode}, الرد: ${response.body}");
        throw Exception('فشل في تحميل بيانات العلماء: ${response.statusCode}');
      }
    } catch (e) {
      print("استثناء في fetchScholars: $e");
      setState(() => isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("حدث خطأ أثناء تحميل بيانات العلماء"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'قائمة العلماء', 
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF336B87),
        elevation: 0,
        centerTitle: true,
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
                _isOptionsVisible = !_isOptionsVisible;
                if (_isOptionsVisible) {
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
                    onChanged: _filterScholars,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: "ابحث عن عالم...",
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
                  child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF336B87)),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'جاري تحميل بيانات العلماء...',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Arial',
                                color: Color(0xFF336B87),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _filteredScholars.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_search,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isNotEmpty 
                                    ? 'لا توجد نتائج للبحث' 
                                    : 'لا يوجد علماء متوفرين حالياً',
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
                                    _filterScholars('');
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
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: _filteredScholars.length,
                          itemBuilder: (context, index) {
                            final scholar = _filteredScholars[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Card(
                                margin: const EdgeInsets.all(0),
                                elevation: 4,
                                shadowColor: Colors.black26,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: ExpansionTile(
                                    collapsedBackgroundColor: Colors.white,
                                    backgroundColor: Colors.white,
                                    leading: Hero(
                                      tag: 'scholar-${scholar.name}',
                                      child: CircleAvatar(
                                        radius: 26,
                                        backgroundColor: Color(0xFFE1E2E1),
                                        child: CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.white,
                                          backgroundImage: scholar.imagePath.isNotEmpty
                                              ? NetworkImage(scholar.imagePath) as ImageProvider
                                              : AssetImage('assets/images/default_scholar.png') as ImageProvider,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      scholar.name,
                                      style: const TextStyle(
                                        fontSize: 18, 
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2F3542),
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_drop_down_circle,
                                      color: Color(0xFF336B87),
                                    ),
                                    children: scholar.playlists.map((playlist) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF5F9FC),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: ExpansionTile(
                                          backgroundColor: Color(0xFFF5F9FC),
                                          collapsedBackgroundColor: Color(0xFFF5F9FC),
                                          title: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF336B87),
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                child: Text(
                                                  '${playlist.videos.length} فيديو',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  playlist.title,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF2F3542),
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                          leading: const Icon(
                                            Icons.playlist_play_rounded,
                                            color: Color(0xFF336B87),
                                            size: 28,
                                          ),
                                          children: playlist.videos.map((video) => 
                                            VideoListItem(video: video, playlist: playlist)
                                          ).toList(),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SidebarMenu(
                isVisible: _isOptionsVisible,
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
          fetchScholars().then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("تم تحديث قائمة العلماء"),
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
              _buildOption(context, "المفضلة", Icons.favorite, () => Navigator.pushNamed(context, '/favorites')),
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

class VideoListItem extends StatefulWidget {
  final Video video;
  final PlayList playlist;

  const VideoListItem({super.key, required this.video, required this.playlist});

  @override
  _VideoListItemState createState() => _VideoListItemState();
}

class _VideoListItemState extends State<VideoListItem> {
  late bool isFavorite;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.video.isFavorite;
  }

  Future<void> toggleFavorite() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}update_favorite/'),
        body: json.encode({
          'id': widget.video.videoId,
          'est_favori': !isFavorite
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          isFavorite = !isFavorite;
          widget.video.isFavorite = isFavorite;
        });
      } else {
        throw Exception('فشل تحديث المفضلة');
      }
    } catch (e) {
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          widget.video.title,
          style: const TextStyle(
            color: Color(0xFF2F3542),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.right,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "مدة الفيديو: غير متاحة",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
          textAlign: TextAlign.right,
        ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isLoading 
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isFavorite ? Colors.red : Colors.grey,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: toggleFavorite,
                ),
            IconButton(
              icon: const Icon(
                Icons.play_circle_filled,
                color: Color(0xFF336B87),
                size: 36,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerPage(
                      video: widget.video,
                      playlist: widget.playlist,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}