import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SubtractionGameScreen extends StatefulWidget {
  const SubtractionGameScreen({super.key});

  @override
  State<SubtractionGameScreen> createState() => _SubtractionGameScreenState();
}

class _SubtractionGameScreenState extends State<SubtractionGameScreen> {
  static const int startApples = 10;

  final _rng = Random();
  final AudioPlayer _player = AudioPlayer();

  int taken = 2;
  int remaining = startApples;

  final List<_Apple> apples = [];

  late int correctAnswer;
  late List<int> choices;

  bool answered = false;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  Future<void> _playCorrectSound() async {
    await _player.stop();
    await _player.play(AssetSource('audio/correct.mp3'));
  }

  Future<void> _playWrongSound() async {
    await _player.stop();
    await _player.play(AssetSource('audio/wrong.mp3'));
  }

  void _newRound() {
    taken = _rng.nextInt(4) + 2; // 2..5
    remaining = startApples;

    apples
      ..clear()
      ..addAll(_spawnApplesPerfectSlots(startApples));

    correctAnswer = startApples - taken;
    choices = _makeTwoChoices(correctAnswer);

    answered = false;

    setState(() {});
  }

  List<_Apple> _spawnApplesPerfectSlots(int count) {
    const xCenters = <double>[
      0.13,
      0.46,
      0.70,
      0.91,
    ];

    const ySlots = <double>[
      0.52,
      0.63,
      0.74,
    ];

    final perPanel = <int>[3, 3, 2, 2];
    final slots = <Offset>[];

    for (int p = 0; p < xCenters.length; p++) {
      final x = xCenters[p];
      final n = perPanel[p];

      final ys =
          (n == 3) ? [ySlots[0], ySlots[1], ySlots[2]] : [ySlots[0], ySlots[2]];

      for (int i = 0; i < n; i++) {
        final jx = (_rng.nextDouble() * 0.012 - 0.006);
        final jy = (_rng.nextDouble() * 0.014 - 0.007);

        slots.add(Offset(x + jx, ys[i] + jy));
      }
    }

    final used = slots.take(count).toList();

    return List.generate(
      used.length,
      (i) => _Apple(id: i, x: used[i].dx, y: used[i].dy),
    );
  }

  List<int> _makeTwoChoices(int correct) {
    int distractor = correct + (_rng.nextBool() ? 1 : -1);

    if (distractor < 0) distractor = correct + 2;
    if (distractor > 10) distractor = correct - 2;
    if (distractor == correct) distractor = (correct == 0) ? 1 : correct - 1;

    final list = [correct, distractor]..shuffle(_rng);
    return list;
  }

  void _onAppleDropped(int appleId) {
    if (answered) return;

    final idx = apples.indexWhere((a) => a.id == appleId);
    if (idx == -1) return;

    final alreadyTaken = startApples - remaining;
    if (alreadyTaken >= taken) return;

    setState(() {
      apples.removeAt(idx);
      remaining--;
    });
  }

  void _choose(int value) {
    final nowTaken = startApples - remaining;
    if (nowTaken != taken) return;

    if (value == correctAnswer) {
      _playCorrectSound();
    } else {
      _playWrongSound();
    }

    setState(() {
      answered = true;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nowTaken = startApples - remaining;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fields.png',
              fit: BoxFit.cover,
            ),
          ),

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
                  line1: "Había $startApples manzanas.",
                  line2: "Arrastra $taken a la canasta.",
                  subline: "Recogidas: $nowTaken / $taken",
                ),
              ),
            ),
          ),

          Positioned(
            right: 18,
            bottom: 18,
            child: DragTarget<int>(
              onAcceptWithDetails: (details) => _onAppleDropped(details.data),
              builder: (context, candidateData, rejectedData) {
                final highlight = candidateData.isNotEmpty;

                return SizedBox(
                  width: 300,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/basket.png',
                        width: 300,
                        height: 240,
                        fit: BoxFit.contain,
                      ),
                      if (highlight)
                        Container(
                          width: 300,
                          height: 240,
                          decoration: BoxDecoration(
                            color: Colors.brown.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              final appleSize = (w * 0.12).clamp(54.0, 86.0);

              return Stack(
                children: [
                  for (final a in apples)
                    Positioned(
                      left: (a.x * w) - (appleSize / 2),
                      top: (a.y * h) - (appleSize / 2),
                      child: Draggable<int>(
                        data: a.id,
                        feedback: Opacity(
                          opacity: 0.85,
                          child: Image.asset(
                            'assets/images/apple.png',
                            width: appleSize,
                            height: appleSize,
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.25,
                          child: Image.asset(
                            'assets/images/apple.png',
                            width: appleSize,
                            height: appleSize,
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/apple.png',
                          width: appleSize,
                          height: appleSize,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          if (nowTaken == taken)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _FeltChoices(
                    question:
                        "Había $startApples manzanas y quitaste $taken.\n¿Cuántas manzanas quedan?",
                    a: choices[0],
                    b: choices[1],
                    disabled: answered,
                    onPick: _choose,
                    onNewRound: _newRound,
                    showNext: answered,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Apple {
  final int id;
  final double x;
  final double y;

  _Apple({
    required this.id,
    required this.x,
    required this.y,
  });
}

class _FeltPrompt extends StatelessWidget {
  final String line1;
  final String line2;
  final String subline;

  const _FeltPrompt({
    required this.line1,
    required this.line2,
    required this.subline,
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
              child: Image.asset(
                'assets/images/apple.png',
                fit: BoxFit.contain,
              ),
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
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

  const _FeltIconButton({
    required this.icon,
    required this.onTap,
  });

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

class _FeltChoices extends StatelessWidget {
  final String question;
  final int a;
  final int b;
  final bool disabled;
  final void Function(int) onPick;
  final VoidCallback onNewRound;
  final bool showNext;

  const _FeltChoices({
    required this.question,
    required this.a,
    required this.b,
    required this.disabled,
    required this.onPick,
    required this.onNewRound,
    required this.showNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(12),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChoiceButton(
                label: "$a",
                onTap: disabled ? null : () => onPick(a),
              ),
              const SizedBox(width: 12),
              _ChoiceButton(
                label: "$b",
                onTap: disabled ? null : () => onPick(b),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: onNewRound,
                child: const Text("Nueva ronda"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: showNext ? onNewRound : null,
                child: const Text("Siguiente"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _ChoiceButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}