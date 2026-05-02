import 'package:flutter/material.dart';
import '../subtraction_game.dart';
import 'ladybug_addition_game.dart';

class MathMenuScreen extends StatelessWidget {
  const MathMenuScreen({super.key});

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

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    iconSize: 30,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Header
                Center(
                  child: Image.asset(
                    'assets/images/header.png',
                    width: 420,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 35),

                // Cards
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _AnimatedMenuCard(
                              imagePath: 'assets/images/unknown.png',
                              width: 220,
                              onTap: () {
                                // no action yet
                              },
                            ),

                            const SizedBox(width: 36),

                            _AnimatedMenuCard(
                              imagePath: 'assets/images/subtraction.png',
                              width: 220,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const SubtractionGameScreen(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(width: 36),

                            _AnimatedMenuCard(
                              imagePath: 'assets/images/addition.png',
                              width: 220,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const LadybugAdditionGameScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedMenuCard extends StatefulWidget {
  final String imagePath;
  final double width;
  final VoidCallback onTap;

  const _AnimatedMenuCard({
    required this.imagePath,
    required this.width,
    required this.onTap,
  });

  @override
  State<_AnimatedMenuCard> createState() => _AnimatedMenuCardState();
}

class _AnimatedMenuCardState extends State<_AnimatedMenuCard> {
  double _scale = 1.0;

  Future<void> _handleTap() async {
    setState(() {
      _scale = 1.12;
    });

    await Future.delayed(const Duration(milliseconds: 120));

    if (!mounted) return;

    setState(() {
      _scale = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 70));

    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Image.asset(
          widget.imagePath,
          width: widget.width,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}