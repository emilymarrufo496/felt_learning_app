import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class LadybugAdditionGameScreen extends StatefulWidget {
  const LadybugAdditionGameScreen({super.key});

  @override
  State<LadybugAdditionGameScreen> createState() =>
      _LadybugAdditionGameScreenState();
}

class _LadybugAdditionGameScreenState extends State<LadybugAdditionGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _wiggleController;
  final Random _rng = Random();
  final AudioPlayer _player = AudioPlayer();

  late List<LadybugData> roundLadybugs;
  final List<LadybugData> basketLadybugs = [];

  int correctAnswer = 0;
  List<int> choices = [];

  bool answered = false;
  bool answeredCorrectly = false;

  @override
  void initState() {
    super.initState();

    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

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
    roundLadybugs = [
      LadybugData(
        asset: 'assets/images/one.png',
        dots: 1,
        baseX: 50,
        baseY: 200,
        phase: 0.0,
      ),
      LadybugData(
        asset: 'assets/images/two.png',
        dots: 2,
        baseX: 200,
        baseY: 300,
        phase: 0.8,
      ),
      LadybugData(
        asset: 'assets/images/three.png',
        dots: 3,
        baseX: 350,
        baseY: 200,
        phase: 1.6,
      ),
      LadybugData(
        asset: 'assets/images/four.png',
        dots: 4,
        baseX: 120,
        baseY: 420,
        phase: 2.4,
      ),
      LadybugData(
        asset: 'assets/images/five.png',
        dots: 5,
        baseX: 320,
        baseY: 420,
        phase: 3.2,
      ),
    ];

    basketLadybugs.clear();
    correctAnswer = 0;
    choices = [];
    answered = false;
    answeredCorrectly = false;

    setState(() {});
  }

  List<int> _makeTwoChoices(int correct) {
    int wrong;
    do {
      wrong = correct + (_rng.nextBool() ? 1 : -1);
      if (wrong < 1) wrong = correct + 2;
    } while (wrong == correct);

    final result = [correct, wrong]..shuffle(_rng);
    return result;
  }

  void _handleAnswer(int selected) {
    if (basketLadybugs.length != 2) return;
    if (answered) return;

    if (selected == correctAnswer) {
      _playCorrectSound();
      setState(() {
        answered = true;
        answeredCorrectly = true;
      });
    } else {
      _playWrongSound();
      setState(() {
        answered = false;
        answeredCorrectly = false;
      });
    }
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pickedCount = basketLadybugs.length;
    final canAnswer = pickedCount == 2;

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
                  line1: "Atrapa 2 mariquitas.",
                  line2: "Arrástralas a la canasta.",
                  subline: "Recogidas: $pickedCount / 2",
                ),
              ),
            ),
          ),

          Positioned(
            right: 18,
            bottom: 210,
            child: DragTarget<LadybugData>(
              onAcceptWithDetails: (details) {
                final bug = details.data;

                if (basketLadybugs.length >= 2 || answered) return;

                if (!basketLadybugs.contains(bug)) {
                  setState(() {
                    basketLadybugs.add(bug);

                    if (basketLadybugs.length == 2) {
                      correctAnswer =
                          basketLadybugs[0].dots + basketLadybugs[1].dots;
                      choices = _makeTwoChoices(correctAnswer);
                    }
                  });
                }
              },
              builder: (context, candidateData, rejectedData) {
                final highlight = candidateData.isNotEmpty;

                return SizedBox(
                  width: 300,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/addition_basket.png',
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
                      ...List.generate(basketLadybugs.length, (index) {
                        return Positioned(
                          left: 95 + (index * 48),
                          top: 78 + (index * 6),
                          child: Image.asset(
                            basketLadybugs[index].asset,
                            width: 70,
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: AnimatedBuilder(
              animation: _wiggleController,
              builder: (context, child) {
                final t = _wiggleController.value * 2 * pi;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        ...roundLadybugs
                            .where((bug) => !basketLadybugs.contains(bug))
                            .map((bug) {
                          final wiggleX = sin(t + bug.phase) * 12;
                          final wiggleY = cos(t + bug.phase) * 8;

                          return Positioned(
                            left: bug.baseX + wiggleX,
                            top: bug.baseY + wiggleY,
                            child: basketLadybugs.length >= 2
                                ? Transform.rotate(
                                    angle: sin(t + bug.phase) * 0.08,
                                    child: Image.asset(
                                      bug.asset,
                                      width: 110,
                                    ),
                                  )
                                : Draggable<LadybugData>(
                                    data: bug,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: Image.asset(
                                        bug.asset,
                                        width: 110,
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.25,
                                      child: Image.asset(
                                        bug.asset,
                                        width: 110,
                                      ),
                                    ),
                                    child: Transform.rotate(
                                      angle: sin(t + bug.phase) * 0.08,
                                      child: Image.asset(
                                        bug.asset,
                                        width: 110,
                                      ),
                                    ),
                                  ),
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          if (canAnswer)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _FeltChoices(
                    question:
                        "Recogiste 2 mariquitas.\n¿Cuántos puntos hay en total?",
                    a: choices[0],
                    b: choices[1],
                    disabled: answered,
                    onPick: _handleAnswer,
                    onNewRound: _newRound,
                    showNext: answeredCorrectly,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LadybugData {
  final String asset;
  final int dots;
  final double baseX;
  final double baseY;
  final double phase;

  LadybugData({
    required this.asset,
    required this.dots,
    required this.baseX,
    required this.baseY,
    required this.phase,
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
                'assets/images/two.png',
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