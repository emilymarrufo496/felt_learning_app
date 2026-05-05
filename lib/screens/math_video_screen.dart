import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MathVideoScreen extends StatefulWidget {
  const MathVideoScreen({super.key});

  @override
  State<MathVideoScreen> createState() => _MathVideoScreenState();
}

class _MathVideoScreenState extends State<MathVideoScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/videos/math_video.mp4',
    )..initialize().then((_) {
        setState(() {});
        _controller.play(); // auto play 🎬
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
      backgroundColor: Colors.pink[100],
      body: Stack(
        children: [
          // 🎬 VIDEO
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),

          // 🌸 CUTE BACK BUTTON
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}