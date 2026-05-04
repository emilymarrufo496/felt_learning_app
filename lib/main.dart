import 'package:flutter/material.dart';

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
  bool _cloudsGrey = false;

  Offset _sunPos = const Offset(0, 0);
  bool _sunInitialized = false;

  late final AnimationController _bobController;
  late final Animation<double> _bobY;

  @override
  void initState() {
    super.initState();

    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _bobY = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bobController.dispose();
    super.dispose();
  }

  void _openMiniGame() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RainLessonPlaceholderScreen(),
      ),
    );
  }

  void _openOrderGame() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const WaterCycleOrderGame(),
      ),
    );
  }

  void _openEnglishZone() {
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final fieldsHeight = h * 0.30;
        final strawberrySize = w * 0.52;
        final sunSize = w * 0.12;
        final cloudBig = w * 0.44;
        final cloudSmall = w * 0.36;

        if (!_sunInitialized) {
          _sunPos = Offset(w * 0.80, h * 0.05);
          _sunInitialized = true;
        }

        return Scaffold(
          body: Stack(
            children: [
              // SKY
              Container(color: const Color(0xFFCFE8FF)),

              // CLOUD 1 -> rain lesson + matching game
              _cloud(
                left: w * 0.08,
                top: h * 0.08,
                width: cloudBig,
                grey: _cloudsGrey,
                onTap: _openMiniGame,
              ),

              // CLOUD 2 -> water cycle ordering game
              _cloud(
                left: w * 0.52,
                top: h * 0.11,
                width: cloudSmall,
                grey: _cloudsGrey,
                onTap: _openOrderGame,
              ),

              // SUN
              Positioned(
                left: _sunPos.dx,
                top: _sunPos.dy,
                child: GestureDetector(
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
                  ),
                ),
              ),

              // STRAWBERRY -> English zone
              AnimatedBuilder(
                animation: _bobController,
                builder: (context, child) {
                  return Positioned(
                    left: (w - strawberrySize) / 2,
                    top: (h * 0.34) + _bobY.value,
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

              // FIELDS -> Math menu
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: _openMathMenu,
                  child: SizedBox(
                    height: fieldsHeight,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/fields.png',
                      fit: BoxFit.cover,
                    ),
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
    required bool grey,
    required VoidCallback onTap,
  }) {
    const greyMatrix = <double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0, 0, 0, 1, 0,
    ];

    final cloudImage = Image.asset(
      'assets/images/clouds.png',
      width: width,
      fit: BoxFit.contain,
    );

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: grey
            ? ColorFiltered(
                colorFilter: const ColorFilter.matrix(greyMatrix),
                child: cloudImage,
              )
            : cloudImage,
      ),
    );
  }
}