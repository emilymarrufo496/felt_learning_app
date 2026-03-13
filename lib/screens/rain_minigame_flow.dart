import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class RainLessonPlaceholderScreen extends StatefulWidget {
  const RainLessonPlaceholderScreen({super.key});

  @override
  State<RainLessonPlaceholderScreen> createState() =>
      _RainLessonPlaceholderScreenState();
}

class _RainLessonPlaceholderScreenState
    extends State<RainLessonPlaceholderScreen> {
  Timer? _timer;
  int _secondsLeft = 2;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft = (_secondsLeft - 1).clamp(0, 9999));
      if (_secondsLeft == 0) _goToMatching();
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
      MaterialPageRoute(
        builder: (_) => const RainStagesMatchingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFCFE8FF)),
          const _SkyCloudsLayer(),

          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: _FeltIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _FeltPrompt(
                  iconAsset: 'assets/images/clouds.png',
                  line1: "Rain Lesson",
                  line2: "Stages of rain in a cloud.",
                  subline: "Continuing in: $_secondsLeft",
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 120, 14, 16),
              child: Center(
                child: _FeltCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud, size: 60),
                      const SizedBox(height: 10),
                      const Text(
                        'Lesson playing…',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: _goToMatching,
                        child: const Text('Continue to Matching'),
                      ),
                    ],
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

class RainStagesMatchingScreen extends StatefulWidget {
  const RainStagesMatchingScreen({super.key});

  @override
  State<RainStagesMatchingScreen> createState() =>
      _RainStagesMatchingScreenState();
}

class _RainStagesMatchingScreenState
    extends State<RainStagesMatchingScreen> {
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
    final matchedCount = _matched.length;
    final total = _items.length;
    final allMatched = matchedCount == total;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFCFE8FF)),
          const _SkyCloudsLayer(),

          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: _FeltIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _FeltPrompt(
                  iconAsset: 'assets/images/clouds.png',
                  line1: "Stages of Rain",
                  line2: "Drag each word onto the matching image.",
                  subline: "Matched: $matchedCount / $total",
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 120, 14, 16),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) =>
                                _buildTargetRow(_items[i]),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                    child: _FeltWordChip(word: word),
                                  ),
                                  childWhenDragging:
                                      _FeltWordChip(word: word, faded: true),
                                  child: _FeltWordChip(
                                      word: word, disabled: done),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (allMatched)
                    _FeltCard(
                      child: Column(
                        children: [
                          const Text(
                            'Great job! You matched them all.',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Back to Scene'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetRow(_MatchItem item) {
    final isMatched = _matched.contains(item.word);

    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => !isMatched,
      onAcceptWithDetails: (details) {
        final incoming = details.data;
        if (incoming == item.word) {
          setState(() => _matched.add(item.word));
        }
      },
      builder: (context, candidates, rejects) {
        final highlight = candidates.isNotEmpty && !isMatched;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6E9)
                .withOpacity(highlight ? 0.98 : 0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.brown.withOpacity(highlight ? 0.60 : 0.35),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 14,
                offset: Offset(0, 7),
                color: Colors.black26,
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset(item.imageAsset,
                  width: 56, height: 56, fit: BoxFit.contain),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isMatched ? item.word : 'Drop here',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MatchItem {
  final String word;
  final String imageAsset;
  const _MatchItem({required this.word, required this.imageAsset});
}

class _SkyCloudsLayer extends StatelessWidget {
  const _SkyCloudsLayer();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;
      final cloudBig = w * 0.44;
      final cloudSmall = w * 0.36;

      return Stack(
        children: [
          Positioned(
            left: w * 0.08,
            top: h * 0.08,
            child: Image.asset(
              'assets/images/clouds.png',
              width: cloudBig,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: w * 0.52,
            top: h * 0.11,
            child: Image.asset(
              'assets/images/clouds.png',
              width: cloudSmall,
              fit: BoxFit.contain,
            ),
          ),
        ],
      );
    });
  }
}

class _FeltCard extends StatelessWidget {
  final Widget child;
  const _FeltCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E9).withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.brown.withOpacity(0.35), width: 2),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 7),
            color: Colors.black26,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FeltWordChip extends StatelessWidget {
  final String word;
  final bool disabled;
  final bool faded;

  const _FeltWordChip({required this.word, this.disabled = false, this.faded = false});

  @override
  Widget build(BuildContext context) {
    final opacity = (disabled || faded) ? 0.55 : 0.92;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E9).withOpacity(opacity),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.brown.withOpacity(0.30), width: 2),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 5),
            color: Colors.black26,
          ),
        ],
      ),
      child: Text(
        word,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: Colors.black.withOpacity(disabled ? 0.55 : 1),
        ),
      ),
    );
  }
}

class _FeltPrompt extends StatelessWidget {
  final String line1;
  final String line2;
  final String subline;
  final String iconAsset;

  const _FeltPrompt({
    required this.line1,
    required this.line2,
    required this.subline,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E9).withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.brown.withOpacity(0.35), width: 2),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 7),
            color: Colors.black26,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(iconAsset, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$line1  $line2",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  subline,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeltIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FeltIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6E9).withOpacity(0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, 5),
                color: Colors.black26,
              ),
            ],
          ),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}