import 'package:flutter/material.dart';
import 'missing_letter_game.dart';
import 'spanish_rhyme_game.dart';

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
                          'SPANISH\nZONE',
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _EnglishCard(
  imagePath: 'assets/images/rhymezone.png',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SpanishRhymeGame(),
      ),
    );
  },
),
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
                      _EnglishPlaceholderCard(
                        title: 'Coming Soon',
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

class _EnglishPlaceholderCard extends StatelessWidget {
  final String title;

  const _EnglishPlaceholderCard({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 170,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.78),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.pink.shade200, width: 3),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}