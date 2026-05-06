import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'screens/english_zone_screen.dart';
import 'screens/math_menu_screen.dart';
import 'screens/rain_minigame_flow.dart';
import 'screens/water_cycle_order_game.dart';

void main() => runApp(const FeltApp());

class FeltApp extends StatelessWidget {
  const FeltApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _bobController;
  late final Animation<double> _bobY;

  final AudioPlayer _touchPlayer = AudioPlayer();

  Offset _sunPos = Offset.zero;
  bool _sunInitialized = false;

  bool _leftCloudGray = false;
  bool _rightCloudGray = false;

  @override
  void initState() {
    super.initState();

    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _bobY = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );
  }

  Future<void> _playTouchSound() async {
    await _touchPlayer.stop();
    await _touchPlayer.play(AssetSource('audio/touch.mp3'));
  }

  @override
  void dispose() {
    _bobController.dispose();
    _touchPlayer.dispose();
    super.dispose();
  }

  void _openMiniGame() {
    _playTouchSound();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RainLessonPlaceholderScreen(),
      ),
    );
  }

  void _openOrderGame() {
    _playTouchSound();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const WaterCycleOrderGame(),
      ),
    );
  }

  void _openEnglishZone() {
    _playTouchSound();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => const EnglishZoneScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _openMathMenu() {
    _playTouchSound();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => const MathMenuScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _tapLeftCloud() {
    _playTouchSound();
    setState(() {
      _leftCloudGray = !_leftCloudGray;
    });
    _openMiniGame();
  }

  void _tapRightCloud() {
    _playTouchSound();
    setState(() {
      _rightCloudGray = !_rightCloudGray;
    });
    _openOrderGame();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final fieldsHeight = h * 0.45;
        final strawberrySize = w * 0.36;
        final sunSize = w * 0.18;

        if (!_sunInitialized) {
          _sunPos = Offset(w * 0.78, h * 0.04);
          _sunInitialized = true;
        }

        return Scaffold(
          body: Stack(
            children: [
              Container(color: const Color(0xFF8FD6E8)),

              Positioned(
                left: 0,
                right: 0,
                bottom: fieldsHeight - 5,
                child: Image.asset(
                  'assets/images/mountain.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),

              _cloud(
                left: w * 0.13,
                top: h * 0.08,
                width: w * 0.30,
                isGray: _leftCloudGray,
                onTap: _tapLeftCloud,
              ),

              _cloud(
                left: w * 0.59,
                top: h * 0.08,
                width: w * 0.30,
                isGray: _rightCloudGray,
                onTap: _tapRightCloud,
              ),

              Positioned(
                left: _sunPos.dx,
                top: _sunPos.dy,
                child: GestureDetector(
                  onTapDown: (_) => _playTouchSound(),
                  onPanStart: (_) => _playTouchSound(),
                  onPanUpdate: (details) {
                    setState(() {
                      _sunPos = Offset(
                        (_sunPos.dx + details.delta.dx).clamp(0.0, w - sunSize),
                        (_sunPos.dy + details.delta.dy).clamp(0.0, h - sunSize),
                      );
                    });
                  },
                  child: Image.asset(
                    'assets/images/sun.png',
                    width: sunSize,
                    height: sunSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              AnimatedBuilder(
                animation: _bobController,
                builder: (context, child) {
                  return Positioned(
                    left: (w - strawberrySize) / 2,
                    top: (h * 0.15) + _bobY.value,
                    child: child!,
                  );
                },
                child: GestureDetector(
                  onTap: _openEnglishZone,
                  child: Image.asset(
                    'assets/images/strawberry.png',
                    width: strawberrySize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: fieldsHeight,
                child: GestureDetector(
                  onTap: _openMathMenu,
                  child: Image.asset(
                    'assets/images/fields.png',
                    width: double.infinity,
                    height: fieldsHeight,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cloud({
    required double left,
    required double top,
    required double width,
    required bool isGray,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: ColorFiltered(
          colorFilter: isGray
              ? const ColorFilter.matrix([
                  0.33, 0.33, 0.33, 0, 0,
                  0.33, 0.33, 0.33, 0, 0,
                  0.33, 0.33, 0.33, 0, 0,
                  0, 0, 0, 1, 0,
                ])
              : const ColorFilter.mode(
                  Colors.transparent,
                  BlendMode.multiply,
                ),
          child: Image.asset(
            'assets/images/clouds.png',
            width: width,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}