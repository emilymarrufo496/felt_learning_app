import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Screen 1: Placeholder "lesson" (acts like the 45s video screen)
/// This automatically transitions to the matching game after a short delay,
/// or immediately when the user taps "Continue".
class RainLessonPlaceholderScreen extends StatefulWidget {
  const RainLessonPlaceholderScreen({super.key});

  @override
  State<RainLessonPlaceholderScreen> createState() => _RainLessonPlaceholderScreenState();
}

class _RainLessonPlaceholderScreenState extends State<RainLessonPlaceholderScreen> {
  Timer? _timer;
  int _secondsLeft = 2; // change to 45 later if you want the same pacing

  @override
  void initState() {
    super.initState();

    // Countdown timer (purely cosmetic)
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft = (_secondsLeft - 1).clamp(0, 9999));
      if (_secondsLeft == 0) {
        _goToMatching();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToMatching() {
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RainStagesMatchingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(begin: const Offset(0, 0.06), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOut));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: animation.drive(tween), child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rain Lesson')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder visual (swap later with VideoPlayer)
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(),
              ),
              alignment: Alignment.center,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud, size: 56),
                  SizedBox(height: 10),
                  Text('Lesson playing…', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 6),
                  Text('Stages of rain in a cloud', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Continuing in $_secondsLeft…',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _goToMatching,
              child: const Text('Continue to Matching'),
            ),
            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen 2: Matching game (drag word onto picture)
class RainStagesMatchingScreen extends StatefulWidget {
  const RainStagesMatchingScreen({super.key});

  @override
  State<RainStagesMatchingScreen> createState() => _RainStagesMatchingScreenState();
}

class _RainStagesMatchingScreenState extends State<RainStagesMatchingScreen> {
  // Use placeholders for now; swap to your real assets later.
  // If you don't have images yet, see NOTE in _buildTargetRow().
  final List<_MatchItem> _items = const [
    _MatchItem(word: 'Evaporation', imageAsset: 'assets/images/evaporation.png'),
    _MatchItem(word: 'Condensation', imageAsset: 'assets/images/condensation.png'),
    _MatchItem(word: 'Precipitation', imageAsset: 'assets/images/precipitation.png'),
    _MatchItem(word: 'Collection', imageAsset: 'assets/images/collection.png'),
  ];

  late final List<String> _words;
  final Set<String> _matched = {};

  @override
  void initState() {
    super.initState();
    _words = _items.map((e) => e.word).toList()..shuffle(Random());
  }

  @override
  Widget build(BuildContext context) {
    final allMatched = _matched.length == _items.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Match the Rain Stages')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Drag each word onto the correct picture.', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            Expanded(
              child: Row(
                children: [
                  // Left: image targets
                  Expanded(
                    child: ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _buildTargetRow(context, _items[i]),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Right: draggable words
                  Expanded(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _words.map((word) {
                        final done = _matched.contains(word);
                        return Opacity(
                          opacity: done ? 0.35 : 1,
                          child: Draggable<String>(
                            data: word,
                            feedback: Material(
                              color: Colors.transparent,
                              child: _WordChip(word: word),
                            ),
                            childWhenDragging: _WordChip(word: word, faded: true),
                            child: _WordChip(word: word, disabled: done),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            if (allMatched) ...[
              const SizedBox(height: 12),
              const Text('🎉 You matched them all!'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Scene'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTargetRow(BuildContext context, _MatchItem item) {
    final isMatched = _matched.contains(item.word);

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => !isMatched,
      onAcceptWithDetails: (details) {
        final incoming = details.data;
        if (incoming == item.word) {
          setState(() => _matched.add(item.word));
          _snack('✅ Correct!');
        } else {
          _snack('❌ Try again');
        }
      },
      builder: (context, candidates, rejects) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(),
          ),
          child: Row(
            children: [
              // NOTE:
              // If you don't have the images yet, Image.asset will crash.
              // Replace Image.asset with the placeholder Container below.
              Image.asset(item.imageAsset, width: 56, height: 56, fit: BoxFit.contain),

              // Placeholder if needed:
              // Container(
              //   width: 56,
              //   height: 56,
              //   alignment: Alignment.center,
              //   decoration: BoxDecoration(
              //     border: Border.all(),
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: const Icon(Icons.image),
              // ),

              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isMatched ? item.word : 'Drop here',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isMatched ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final bool disabled;
  final bool faded;
  const _WordChip({required this.word, this.disabled = false, this.faded = false});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(word),
      backgroundColor: (disabled || faded)
          ? Theme.of(context).disabledColor.withOpacity(0.2)
          : null,
    );
  }
}

class _MatchItem {
  final String word;
  final String imageAsset;
  const _MatchItem({required this.word, required this.imageAsset});
}