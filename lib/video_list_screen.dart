import 'package:flutter/material.dart';

import 'chewie_player_screen.dart';
import 'video_player_screen.dart';

class VideoListScreen extends StatelessWidget {
  VideoListScreen({super.key});

  final List<String> videoUrls = [
    'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4',
    'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
    'https://samplelib.com/lib/preview/mp4/sample-10s.mp4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video List'),
      ),
      body: ListView.builder(
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.play_arrow, color: Colors.blueAccent),
            title: Text('Video ${index + 1}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(url: videoUrls[index],),
                  // builder: (context) => ChewiePlayer(url: videoUrls[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
