import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:better_player/better_player.dart';
import 'package:get_it/get_it.dart';
import 'package:chat_application/service/navigation_service.dart';

enum Source { Network, Offline }

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  BetterPlayerController? _betterPlayerController;
  Source currentSource = Source.Network;

  final List<String> networkVideos = [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"
  ];

  List<String> downloadedVideos = [];

  bool isLoading = true;
  late NavigationService _navigationService;
  final GetIt _getIt = GetIt.instance;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    initializeVideoPlayer(currentSource, networkVideos[0]);
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Video Player",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          leading: IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () {
              _navigationService.pushNamed("/home");
            },
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              )
            : Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: _betterPlayerController != null
                        ? AspectRatio(
                            aspectRatio: 16 / 9,
                            child: BetterPlayer(
                              controller: _betterPlayerController!,
                            ),
                          )
                        : Container(
                            color: Colors.black,
                            child: const Center(
                              child: Text(
                                "Select a video to play",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                  ),
                  _sourceButtons(),
                  Expanded(
                    flex: 2,
                    child: _videoList(),
                  ),
                ],
              ),
        floatingActionButton: currentSource == Source.Network
            ? FloatingActionButton(
                onPressed: () {
                  downloadVideo(networkVideos[
                      0]); // download the currently playing network video
                },
                child: const Icon(Icons.download),
                backgroundColor: Colors.red,
              )
            : null,
      ),
    );
  }

  Widget _sourceButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  currentSource == Source.Network ? Colors.red : Colors.grey,
            ),
            child: const Text(
              "Network",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              setState(() {
                currentSource = Source.Network;
                initializeVideoPlayer(currentSource, networkVideos[0]);
              });
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  currentSource == Source.Offline ? Colors.red : Colors.grey,
            ),
            child: const Text(
              "Offline",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              setState(() {
                currentSource = Source.Offline;
                if (downloadedVideos.isNotEmpty) {
                  initializeVideoPlayer(currentSource, downloadedVideos[0]);
                } else {
                  initializeVideoPlayer(currentSource, '');
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _videoList() {
    List<String> videos =
        currentSource == Source.Network ? networkVideos : downloadedVideos;
    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('Video ${index + 1}'),
            trailing: const Icon(Icons.play_circle_fill, color: Colors.red),
            onTap: () {
              initializeVideoPlayer(currentSource, videos[index]);
            },
          ),
        );
      },
    );
  }

  void initializeVideoPlayer(Source source, String videoPath) {
    setState(() {
      isLoading = true;
    });

    BetterPlayerDataSource? dataSource;
    if (source == Source.Offline && videoPath.isNotEmpty) {
      dataSource =
          BetterPlayerDataSource(BetterPlayerDataSourceType.file, videoPath);
    } else if (source == Source.Network) {
      dataSource =
          BetterPlayerDataSource(BetterPlayerDataSourceType.network, videoPath);
    }

    if (dataSource != null) {
      _betterPlayerController = BetterPlayerController(
        const BetterPlayerConfiguration(),
        betterPlayerDataSource: dataSource,
      );
    } else {
      _betterPlayerController = null;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> downloadVideo(String url) async {
    try {
      PermissionStatus status = await Permission.storage.request();
      if (status.isGranted) {
        var dir = await getExternalStorageDirectory();
        if (dir != null) {
          String savePath =
              '${dir.path}/downloaded_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
          await Dio().download(url, savePath);

          setState(() {
            downloadedVideos.add(
                savePath); // Add the downloaded video to the downloadedVideos list
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video downloaded to $savePath')),
          );
        }
      } else if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied')),
        );
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    } catch (e) {
      print('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download failed')),
      );
    }
  }
}
