import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  _DownloadsPageState createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  List<LocalVideo> _downloadedVideos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedVideos();
  }

  Future<void> _loadDownloadedVideos() async {
    setState(() => _isLoading = true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savedVideosFile = File('${directory.path}/saved_videos.json');

      if (await savedVideosFile.exists()) {
        String content = await savedVideosFile.readAsString();

        if (content.trim().isNotEmpty) {  
          List<dynamic> data = jsonDecode(content);
          setState(() {
            _downloadedVideos = data.map((video) => LocalVideo.fromJson(video)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ أثناء تحميل الفيديوهات المحفوظة: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفيديوهات المحملة'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _downloadedVideos.isEmpty
              ? const Center(child: Text('لا توجد فيديوهات محملة'))
              : ListView.builder(
                  itemCount: _downloadedVideos.length,
                  itemBuilder: (context, index) {
                    final video = _downloadedVideos[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(video.title),
                        leading: Icon(
                          video.isDownloaded ? Icons.download_done : Icons.download,
                          color: video.isDownloaded ? Colors.green : Colors.grey,
                        ),
                        onTap: () {
                          if (File(video.path).existsSync()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OfflineVideoPlayer(videoPath: video.path),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('⚠ ملف الفيديو غير موجود!')),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class OfflineVideoPlayer extends StatefulWidget {
  final String videoPath;
  const OfflineVideoPlayer({super.key, required this.videoPath});

  @override
  _OfflineVideoPlayerState createState() => _OfflineVideoPlayerState();
}

class _OfflineVideoPlayerState extends State<OfflineVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isControllerInitialized = false; 

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final file = File(widget.videoPath);
      if (!file.existsSync()) {
        throw Exception("⚠ الملف غير موجود");
      }

      _controller = VideoPlayerController.file(file);
      await _controller.initialize();
      setState(() {
        _isControllerInitialized = true;
      });
    } catch (e) {
      debugPrint("❌ خطأ أثناء تحميل الفيديو: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠ حدث خطأ أثناء تحميل الفيديو')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تشغيل الفيديو")),
      body: Center(
        child: _isControllerInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: _isControllerInitialized
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                });
              },
              child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
            )
          : null, 
    );
  }

  @override
  void dispose() {
    if (_isControllerInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }
}

class LocalVideo {
  final String title;
  final String path;
  final String videoId;
  final String thumbnailPath;
  final bool isDownloaded;

  LocalVideo({
    required this.title,
    required this.path,
    required this.videoId,
    required this.thumbnailPath,
    required this.isDownloaded,
  });

  factory LocalVideo.fromJson(Map<String, dynamic> json) {
    return LocalVideo(
      title: json['title'] ?? "بدون عنوان",
      path: json['local_path'] ?? "",
      videoId: json['video_id'] ?? "",
      thumbnailPath: json['thumbnail_path'] ?? "",
      isDownloaded: File(json['local_path'] ?? "").existsSync(),
    );
  }
}