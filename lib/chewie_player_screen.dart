import 'package:chewei_test/custom_controls.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class ChewiePlayer extends StatefulWidget {
  final String url;
  const ChewiePlayer({super.key, required this.url});

  @override
  State<ChewiePlayer> createState() => _ChewiePlayerState();
}

class _ChewiePlayerState extends State<ChewiePlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _setLandScapeMode();
  }

  void _initPlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );
    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: true,
      fullScreenByDefault: true,
      // autoInitialize: true,
      showControlsOnInitialize: false,
      showControls: false,
      allowMuting: false,
       customControls: CustomControls(chewieController: _chewieController),
      progressIndicatorDelay: const Duration(milliseconds: 500),

      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            'Error: $errorMessage',
            style: const TextStyle(color: Colors.red),
          ),
        );
      },

      //no need yet
      // controlsSafeAreaMinimum: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      // allowedScreenSleep: false,
      // overlay: const Positioned(
      //   top: 10,
      //   left: 10,
      //   child: Icon(
      //     Icons.info,
      //     color: Colors.white,
      //   ),
      // ),
      // additionalOptions: (context) {}
      // startAt: const Duration(seconds: 10),

      //try later

      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.blueAccent,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.white,
      //   bufferedColor: const Color.fromARGB(255, 185, 183, 183),
      // ),
      // cupertinoProgressColors: ChewieProgressColors(
      //   playedColor: Colors.blueAccent,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.white,
      //   bufferedColor: const Color.fromARGB(255, 185, 183, 183),
      // ),
      placeholder: const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      ),
    );
    setState(() {});
  }



  void _setLandScapeMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _skipBackward() {
    final currentPosition = _videoPlayerController!.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    _videoPlayerController!.seekTo(newPosition);
  }

  void _skipForward() {
    final currentPosition = _videoPlayerController!.value.position;
    final newPosition = currentPosition + const Duration(seconds: 10);
    _videoPlayerController!.seekTo(newPosition);
  }

  // void _toggleControlsVisibility() {
  //   setState(() {
  //     _showControls = !_showControls;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _chewieController != null && _videoPlayerController!.value.isInitialized
          ? AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: Chewie(
                controller: _chewieController!,
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      // body: OrientationBuilder(
      //   builder: (context, orientation) {
      //     return Stack(
      //       alignment: Alignment.center,
      //       children: [
      //         if (_chewieController != null && _videoPlayerController!.value.isInitialized)
      //           AspectRatio(
      //             aspectRatio: _videoPlayerController!.value.aspectRatio,
      //             child: Chewie(controller: _chewieController!),
      //           )
      //         else
      //           const Center(
      //             child: CircularProgressIndicator(),
      //           ),

      //         // Skip Backward
      //         Positioned(
      //           left: 20,
      //           bottom: 40,
      //           child: IconButton(
      //             onPressed: () {
      //               _skipBackward();
      //             },
      //             icon: const Icon(
      //               Icons.replay_10,
      //               size: 36,
      //               color: Colors.white,
      //             ),
      //           ),
      //         ),
      //         // Skip Forward
      //         Positioned(
      //           right: 20,
      //           bottom: 40,
      //           child: IconButton(
      //             onPressed: () {
      //               _skipForward();
      //             },
      //             icon: const Icon(
      //               Icons.forward_10,
      //               size: 36,
      //               color: Colors.white,
      //             ),
      //           ),
      //         ),
      //       ],
      //     );
      //   },
      // ),
    );
  }
}
