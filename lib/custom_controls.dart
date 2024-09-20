import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomControls extends StatefulWidget {
  final ChewieController? chewieController;
  const CustomControls({super.key, required this.chewieController});

  @override
  State<CustomControls> createState() => _CustomControlsState();
}

class _CustomControlsState extends State<CustomControls> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _chewieController = widget.chewieController!;
    _videoPlayerController = _chewieController.videoPlayerController;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Center(
            child: Chewie(controller: _chewieController),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: _buildCustomControls(),
          ),
        )
      ],
    );
  }

  Widget _buildCustomProgressBar() {
    return StreamBuilder<Duration?>(
      stream: _videoPlayerController.position.asStream(),
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = _videoPlayerController.value.duration;

        return Slider(
          value: position.inSeconds.toDouble(),
          max: duration.inSeconds.toDouble(),
          onChanged: (value) {
            _videoPlayerController.seekTo(Duration(seconds: value.toInt()));
          },
          activeColor: Colors.blue,
          inactiveColor: Colors.grey,
        );
      },
    );
  }

  Widget _buildCustomControls() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCustomProgressBar(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _videoPlayerController.value.isPlaying ? _videoPlayerController.pause() : _videoPlayerController.play();
                  });
                },
                icon: Icon(
                  _videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
              Text(
                _videoPlayerController.value.position.inSeconds.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                _videoPlayerController.value.duration.inSeconds.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  _chewieController.enterFullScreen();
                },
                icon: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
