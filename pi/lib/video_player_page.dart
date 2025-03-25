
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'scholars_page.dart';

class VideoPlayerPage extends StatefulWidget {
  final Video video;
  final PlayList playlist;

  const VideoPlayerPage({
    super.key,
    required this.video,
    required this.playlist,
  });

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _offlineController;
  bool isOffline = false;
  bool isLoading = true;
  bool isFullScreen = false;
  String? errorMessage;
  int currentVideoIndex = 0;
  bool isPlaylistExpanded = false;

  @override
  void initState() {
    super.initState();
    _findCurrentVideoIndex();
    _initializePlayer();
    
    // Set preferred orientations for the video player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _findCurrentVideoIndex() {
    for (int i = 0; i < widget.playlist.videos.length; i++) {
      if (widget.playlist.videos[i].videoId == widget.video.videoId) {
        currentVideoIndex = i;
        break;
      }
    }
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.video.localPath != null && File(widget.video.localPath!).existsSync()) {
        debugPrint("✅ تشغيل فيديو محلي: ${widget.video.localPath}");
        isOffline = true;
        _offlineController = VideoPlayerController.file(File(widget.video.localPath!));
        await _offlineController!.initialize();
        _offlineController!.play();
        setState(() => isLoading = false);
        return;
      }

      debugPrint("🔍 URL الفيديو من API: ${widget.video.downloadUrl}");
      String? videoId = YoutubePlayer.convertUrlToId(widget.video.downloadUrl);

      if (videoId == null || videoId.isEmpty) {
        setState(() {
          errorMessage = '⚠ رابط الفيديو غير صالح!';
          isLoading = false;
        });
        return;
      }

      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
          forceHD: false,
        ),
      );

      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('❌ خطأ في تشغيل الفيديو: $e');
      setState(() {
        errorMessage = '⚠ حدث خطأ أثناء تحميل الفيديو';
        isLoading = false;
      });
    }
  }

  void _toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
      if (isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    });
  }

  void _playNextVideo() {
    if (currentVideoIndex < widget.playlist.videos.length - 1) {
      currentVideoIndex++;
      _changeVideo(widget.playlist.videos[currentVideoIndex]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("هذا آخر فيديو في القائمة"),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        )
      );
    }
  }

  void _playPreviousVideo() {
    if (currentVideoIndex > 0) {
      currentVideoIndex--;
      _changeVideo(widget.playlist.videos[currentVideoIndex]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("هذا أول فيديو في القائمة"),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        )
      );
    }
  }

  void _changeVideo(Video video) {
    setState(() {
      isLoading = true;
    });

    // Dispose current controllers
    _youtubeController?.dispose();
    _offlineController?.dispose();
    _youtubeController = null;
    _offlineController = null;

    // Navigate to new video
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(
          video: video,
          playlist: widget.playlist,
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF336B87)),
            ),
            SizedBox(height: 16),
            Text(
              "جاري تحميل الفيديو...",
              style: TextStyle(
                color: isFullScreen ? Colors.white : Colors.black87,
                fontSize: 16,
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
              color: Colors.red,
              size: 60,
            ),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                _initializePlayer();
              },
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

    if (isOffline && _offlineController != null && _offlineController!.value.isInitialized) {
      return Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _offlineController!.value.aspectRatio,
            child: VideoPlayer(_offlineController!),
          ),
          if (!isFullScreen)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                color: Colors.black54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        _offlineController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          _offlineController!.value.isPlaying
                              ? _offlineController!.pause()
                              : _offlineController!.play();
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _toggleFullScreen,
                    ),
                  ],
                ),
              ),
            ),
          if (isFullScreen)
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: Icon(
                  Icons.fullscreen_exit,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: _toggleFullScreen,
              ),
            ),
        ],
      );
    } else if (!isOffline && _youtubeController != null) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Color(0xFF336B87),
          progressColors: const ProgressBarColors(
            playedColor: Color(0xFF336B87),
            handleColor: Color(0xFF336B87),
          ),
          onEnded: (_) {
            // Auto-play next video
            if (currentVideoIndex < widget.playlist.videos.length - 1) {
              _playNextVideo();
            }
          },
        ),
        builder: (context, player) {
          return player;
        },
      );
    }

    return Center(
      child: Text(
        "لا يمكن تشغيل الفيديو",
        style: TextStyle(
          color: Colors.red,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildPlaylistSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        title: Text(
          "قائمة التشغيل: ${widget.playlist.title}",
          style: TextStyle(
            color: Color(0xFF336B87),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.right,
        ),
        subtitle: Text(
          "الفيديو ${currentVideoIndex + 1} من ${widget.playlist.videos.length}",
          textAlign: TextAlign.right,
        ),
        leading: Icon(
          Icons.playlist_play,
          color: Color(0xFF336B87),
          size: 36,
        ),
        children: [
          Container(
            height: 200,
            child: ListView.builder(
              itemCount: widget.playlist.videos.length,
              itemBuilder: (context, index) {
                final video = widget.playlist.videos[index];
                final isCurrentVideo = index == currentVideoIndex;
                
                return ListTile(
                  tileColor: isCurrentVideo ? Color(0xFFE6F2F8) : null,
                  leading: CircleAvatar(
                    backgroundColor: isCurrentVideo ? Color(0xFF336B87) : Colors.grey.shade400,
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    video.title,
                    style: TextStyle(
                      fontWeight: isCurrentVideo ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentVideo ? Color(0xFF336B87) : Colors.black87,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: isCurrentVideo
                    ? Icon(Icons.play_circle_filled, color: Color(0xFF336B87))
                    : Icon(Icons.play_circle_outline, color: Colors.grey),
                  onTap: () {
                    if (index != currentVideoIndex) {
                      _changeVideo(video);
                    }
                  },
                );
              },
            ),
          ),
        ],
        onExpansionChanged: (expanded) {
          setState(() {
            isPlaylistExpanded = expanded;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: _buildVideoPlayer(),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (isFullScreen) {
          _toggleFullScreen();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.video.title,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: Color(0xFF336B87),
          elevation: 0,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: Container(
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
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: _buildVideoPlayer(),
                ),
              ),
              if (!isLoading && errorMessage == null) Expanded(
                child: ListView(
                  children: [
                    // Video title and info
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.video.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2F3542),
                            ),
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                widget.video.isFavorite ? "• في المفضلة" : "",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "من قائمة: ${widget.playlist.title}",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Playback controls
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildControlButton(
                            icon: Icons.skip_previous,
                            onPressed: _playPreviousVideo,
                            label: "السابق",
                          ),
                          _buildControlButton(
                            icon: isOffline && _offlineController != null
                                ? (_offlineController!.value.isPlaying ? Icons.pause : Icons.play_arrow)
                                : Icons.play_arrow,
                            onPressed: () {
                              if (isOffline && _offlineController != null) {
                                setState(() {
                                  _offlineController!.value.isPlaying
                                      ? _offlineController!.pause()
                                      : _offlineController!.play();
                                });
                              }
                            },
                            label: isOffline && _offlineController != null && _offlineController!.value.isPlaying
                                ? "إيقاف"
                                : "تشغيل",
                            isPrimary: true,
                          ),
                          _buildControlButton(
                            icon: Icons.skip_next,
                            onPressed: _playNextVideo,
                            label: "التالي",
                          ),
                        ],
                      ),
                    ),
                    
                    // Playlist section
                    _buildPlaylistSection(),
                    
                    // Additional options
                    Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildOptionTile(
                            icon: widget.video.isFavorite ? Icons.favorite : Icons.favorite_border,
                            title: "إضافة إلى المفضلة",
                            subtitle: widget.video.isFavorite ? "تم الإضافة إلى المفضلة" : "إضافة هذا الفيديو إلى المفضلة",
                            iconColor: widget.video.isFavorite ? Colors.red : Colors.grey,
                            onTap: () {
                              // Toggle favorite status
                              Navigator.pop(context, {
                                'videoId': widget.video.videoId,
                                'toggleFavorite': true,
                              });
                            },
                          ),
                          Divider(),
                          _buildOptionTile(
                            icon: Icons.fullscreen,
                            title: "عرض بملء الشاشة",
                            subtitle: "مشاهدة الفيديو في وضع ملء الشاشة",
                            onTap: _toggleFullScreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String label,
    bool isPrimary = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(isPrimary ? 16 : 12),
            backgroundColor: isPrimary ? Color(0xFF336B87) : Colors.grey.shade200,
            foregroundColor: isPrimary ? Colors.white : Color(0xFF336B87),
          ),
          child: Icon(
            icon,
            size: isPrimary ? 36 : 24,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isPrimary ? Color(0xFF336B87) : Colors.grey.shade700,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = const Color(0xFF336B87),
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.chevron_left,
              color: Colors.grey,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _offlineController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }
}