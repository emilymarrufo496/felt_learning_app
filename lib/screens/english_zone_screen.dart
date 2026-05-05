import 'package:flutter/material.dart';
import 'missing_letter_game.dart';
import 'spanish_video_screen.dart'; // 👈 NEW IMPORT

class EnglishZoneScreen extends StatelessWidget {
  const EnglishZoneScreen({super.key});

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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

                  const SizedBox(height: 8),

                  // HEADER
                  Image.asset(
                    'assets/images/english_zone_title.png',
                    height: 180,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        width: 320,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.pink.shade100.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'ENGLISH\nZONE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  // ICON ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // LEFT (RHYME)
                      _EnglishCard(
                        imagePath: 'assets/images/rhymezone.png',
                        onTap: () {
                          // rhyming game later
                        },
                      ),

                      // MIDDLE (SPELLING)
                      _EnglishCard(
                        imagePath: 'assets/images/spelling.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MissingLetterGameScreen(),
                            ),
                          );
                        },
                      ),

                      // RIGHT (VIDEO)
                      _EnglishCard(
                        imagePath: 'assets/images/spanish_icon.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SpanishVideoScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnglishCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _EnglishCard({
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 170,
        height: 170,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}