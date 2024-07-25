import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:chat_application/service/navigation_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum Source { Asset, Network }

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  CustomVideoPlayerController? _customVideoPlayerController;
  late CachedVideoPlayerController _videoPlayerController;

  Source currentSource = Source.Asset;

  final List<String> networkVideos = [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"
  ];

  final List<String> assetVideos = [
    "assets/videos/vedio1.mp4",
    "assets/videos/videofile.mp4",
  ];

  bool isLoading = true;
  late NavigationService _navigationService;
  @override
  void initState() {
    super.initState();
     _navigationService = _getIt.get<NavigationService>();
    initializeVideoPlayer(currentSource, networkVideos[0]);
  }
final GetIt _getIt = GetIt.instance;
  @override
  void dispose() {
    _customVideoPlayerController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Video Player",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          leading: IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () {_navigationService.pushNamed("/home");},
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              )
            : Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: _customVideoPlayerController != null
                        ? CustomVideoPlayer(
                            customVideoPlayerController:
                                _customVideoPlayerController!,
                          )
                        : Container(
                            color: Colors.black,
                            child: Center(
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
                child: Icon(Icons.download),
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
                  currentSource == Source.Asset ? Colors.red : Colors.grey,
            ),
            child: const Text(
              "Asset",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              setState(() {
                currentSource = Source.Asset;
                initializeVideoPlayer(currentSource, assetVideos[0]);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _videoList() {
    List<String> videos =
        currentSource == Source.Asset ? assetVideos : networkVideos;
    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('Video ${index + 1}'),
            trailing: Icon(Icons.play_circle_fill, color: Colors.red),
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

    if (source == Source.Asset) {
      _videoPlayerController = CachedVideoPlayerController.asset(videoPath);
    } else {
      _videoPlayerController = CachedVideoPlayerController.network(videoPath);
    }

    _videoPlayerController.initialize().then((_) {
      setState(() {
        isLoading = false;
        _customVideoPlayerController = CustomVideoPlayerController(
          context: context,
          videoPlayerController: _videoPlayerController,
        );
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      print('Video Player Error: $error');
    });
  }

  Future<void> downloadVideo(String url) async {
    try {
      if (await Permission.storage.request().isGranted) {
        var dir = await getExternalStorageDirectory();
        if (dir != null) {
          String savePath = '${dir.path}/downloaded_video.mp4';
          await Dio().download(url, savePath);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video downloaded to $savePath')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission denied')),
        );
      }
    } catch (e) {
      print('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed')),
      );
    }
  }
}
