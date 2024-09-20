import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final bool autoPlay;
  const VideoPlayerScreen({
    super.key,
    required this.url,
    this.autoPlay = true,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();

    // Set orientation to landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // Hide system UI for full-screen immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    )..initialize().then((_) {
        if (widget.autoPlay) {
          _controller.play();
          _isPlaying = true;
        }
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();

    // Restore system UI and orientation on exit
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Set orientation back to normal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _togglePlayPause() {
    // setState(() {
    //   if (_controller.value.isPlaying) {
    //     _controller.pause();
    //   } else {
    //     _controller.play();
    //   }
    // });
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? _controller.play() : _controller.pause();
    });
  }

  void _rewind() {
    final currentPosition = _controller.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    _controller.seekTo(newPosition > Duration.zero ? newPosition : Duration.zero);
  }

  void _fastForward() {
    final currentPosition = _controller.value.position;
    final maxPosition = _controller.value.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);
    _controller.seekTo(newPosition < maxPosition ? newPosition : maxPosition);
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Video Player Example'),
        // ),
        body: OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        } else {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }

        return Center(
          child: _controller.value.isInitialized
              ? GestureDetector(
                  // onDoubleTap: _togglePlayPause,
                  onTap: _toggleControlsVisibility,
                  // onPanUpdate: (details) {
                  //   if (details.localPosition.dx < MediaQuery.of(context).size.width / 3) {
                  //     if (details.delta.dy > 0) {
                  //       log('rewind');
                  //       _rewind();
                  //     }
                  //   } else if (details.localPosition.dx > 2 * MediaQuery.of(context).size.width / 3) {
                  //     if (details.delta.dy > 0) {
                  //       log('fast forward');
                  //       _fastForward();
                  //     }
                  //   }
                  // },
                  onDoubleTapDown: (details) {
                    // Determine where the double tap occurred
                    if (details.localPosition.dx < MediaQuery.of(context).size.width / 2) {
                      _rewind(); // Left side double-tap
                    } else {
                      _fastForward(); // Right side double-tap
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      if (_showControls)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                          ),
                        ),
                      if (_showControls) _buildControls(),
                    ],
                  ),
                )
              : const CircularProgressIndicator(),
        );
      },
    ));
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.replay_10,
            color: Colors.white,
            size: 30,
          ),
          onPressed: _rewind,
        ),
        IconButton(
          icon: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 30,
          ),
          onPressed: _togglePlayPause,
        ),
        IconButton(
          icon: const Icon(
            Icons.forward_10,
            color: Colors.white,
            size: 30,
          ),
          onPressed: _fastForward,
        ),
      ],
    );
  }
}
