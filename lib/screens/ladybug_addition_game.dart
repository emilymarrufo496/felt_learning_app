import 'dart:math';
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
    setState(() {
      answered = true;
      answeredCorrectly = selected == correctAnswer;
    });

    if (answeredCorrectly) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        _newRound();
      });
    }
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canAnswer = basketLadybugs.length == 2;

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _wiggleController,
          builder: (context, child) {
            final t = _wiggleController.value * 2 * pi;

            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background.jpg',
                    fit: BoxFit.cover,
                  ),
                ),

                const Positioned(
                  top: 20,
                  left: 24,
                  right: 24,
                  child: Text(
                    'Catch the Ladybugs!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A3E2B),
                    ),
                  ),
                ),

                Positioned(
                  top: 68,
                  left: 24,
                  right: 24,
                  child: Text(
                    canAnswer
                        ? 'How many spots are there altogether?'
                        : 'Pick any 2 ladybugs and drag them into the basket.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF7A5C47),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Positioned(
                  bottom: 45,
                  right: 20,
                  child: DragTarget<LadybugData>(
                    onAcceptWithDetails: (details) {
                      final bug = details.data;

                      if (basketLadybugs.length >= 2) return;

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
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/addition_basket.png',
                            width: 250,
                          ),
                          ...List.generate(basketLadybugs.length, (index) {
                            return Positioned(
                              left: 55 + (index * 45),
                              top: 40 + (index * 8),
                              child: Image.asset(
                                basketLadybugs[index].asset,
                                width: 75,
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),

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

                if (canAnswer)
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 180,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: choices.map((choice) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ElevatedButton(
                            onPressed: answered ? null : () => _handleAnswer(choice),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 34,
                                vertical: 18,
                              ),
                              backgroundColor: const Color(0xFFFFE7EF),
                              foregroundColor: const Color(0xFF7A3E48),
                              textStyle: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text('$choice'),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                if (answered)
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 120,
                    child: Text(
                      answeredCorrectly ? 'Yay! Great job!' : 'Try again!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: answeredCorrectly
                            ? const Color(0xFF4E8A3A)
                            : const Color(0xFFC45A5A),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
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