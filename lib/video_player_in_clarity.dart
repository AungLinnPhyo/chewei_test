import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/utils/constants/api_route_constants.dart';
import '../../../../core/utils/constants/app_color_constants.dart';
import '../../../../core/utils/constants/app_size_constants.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  const VideoPlayerScreen({super.key, required this.url});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _showControls = false;
  bool _autoPlay = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse("${ApiRouteConstants.strapiPhotoBaseUrl}${widget.url}"),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..initialize().then((_) {
        setState(() {
          _isLoading = false;
          if (_autoPlay) {
            _controller.play();
            _isPlaying = true;
          }
        });
      }).catchError((error) {
        log('faild to initialize video: $error');
        setState(() {
          _isLoading = false;
        });
      });

    _controller.addListener(() {
      if (_controller.value.hasError) {
        log('Video Player Error: ${_controller.value.errorDescription}');
        // Display error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing video: ${_controller.value.errorDescription}')),
        );
      }
    });
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // enter full-screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // Exit full-screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]); // Reset to portrait mode
  }

  @override
  void dispose() {
    _controller.dispose();

    _exitFullScreen();
    super.dispose();
  }

  void _togglePlayPause() {
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

  String _formatDuration(Duration position) {
    final minutes = position.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = position.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            _enterFullScreen();
          } else {
            _exitFullScreen();
          }

          return Center(
            child: _controller.value.isInitialized
                ? GestureDetector(
                    onTap: _toggleControlsVisibility,
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
                        SizedBox(
                          width: orientation == Orientation.landscape ? MediaQuery.of(context).size.width : null,
                          height: orientation == Orientation.landscape ? MediaQuery.of(context).size.height : null,
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                        if (_isLoading) const CircularProgressIndicator(),
                        if (_showControls)
                          Positioned(
                            top: 20,
                            left: 20,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                              onPressed: () => context.pop(),
                            ),
                          ),
                        if (_showControls)
                          Center(
                            child: IconButton(
                              iconSize: 60.0,
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: _togglePlayPause,
                            ),
                          ),
                        // Progress Bar and Duration
                        if (_showControls)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: AppColors.redColor,
                                    inactiveTrackColor: AppColors.greyColor,
                                    thumbColor: AppColors.redColor,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
                                  ),
                                  child: ValueListenableBuilder(
                                    valueListenable: _controller,
                                    builder: (context, value, child) {
                                      return Slider(
                                        value: _controller.value.position.inSeconds.toDouble(),
                                        min: 0.0,
                                        max: _controller.value.duration.inSeconds.toDouble(),
                                        onChanged: (value) {
                                          setState(() {
                                            _controller.seekTo(
                                              Duration(seconds: value.toInt()),
                                            );
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingFromScreenEdge),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ValueListenableBuilder(
                                        valueListenable: _controller,
                                        builder: (context, value, child) {
                                          return Text(
                                            '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
                                            style: const TextStyle(color: AppColors.whiteColor),
                                          );
                                        },
                                      ),
                                      // Fullscreen button
                                      IconButton(
                                        onPressed: () {
                                          if (orientation == Orientation.portrait) {
                                            _enterFullScreen();
                                          } else {
                                            SystemChrome.setPreferredOrientations([
                                              DeviceOrientation.portraitUp,
                                              DeviceOrientation.portraitDown,
                                            ]);
                                            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                                          }
                                        },
                                        icon: const Icon(Icons.fullscreen, color: AppColors.whiteColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
