import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SpanishVideoScreen extends StatefulWidget {
  const SpanishVideoScreen({super.key});

  @override
  State<SpanishVideoScreen> createState() => _SpanishVideoScreenState();
}

class _SpanishVideoScreenState extends State<SpanishVideoScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/videos/spanish_video.mp4',
    )
      ..initialize().then((_) {
        setState(() {});
        _controller.play(); // auto play
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black87),
                    ),
                  ),
                ),

                const Spacer(),

                // 🎬 VIDEO PLAYER
                _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: VideoPlayer(_controller),
                        ),
                      )
                    : const CircularProgressIndicator(),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}