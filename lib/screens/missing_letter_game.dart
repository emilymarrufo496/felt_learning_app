import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MissingLetterGameScreen extends StatefulWidget {
  const MissingLetterGameScreen({super.key});

  @override
  State<MissingLetterGameScreen> createState() =>
      _MissingLetterGameScreenState();
}

class _MissingLetterGameScreenState extends State<MissingLetterGameScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.26);
  final AudioPlayer _player = AudioPlayer();

  late final List<SpellingWord> words;

  int selectedIndex = 0;
  bool inPuzzle = false;

  SpellingWord? currentWord;
  PuzzleRound? currentRound;

  bool completed = false;
  int currentSlotIndex = 0;
  int currentRoundIndex = 0;

  @override
  void initState() {
    super.initState();

    words = [
      SpellingWord(
        name: 'cat',
        cardImage: 'assets/images/card_cat.png',
        rounds: [
          PuzzleRound.missingLetter(
            puzzleImage: 'assets/images/card_c_t.png',
            correctLetters: ['A'],
            choices: ['A', 'K', 'T'],
            slotOffsets: const [Offset(0.50, 0.77)],
          ),
          PuzzleRound.missingLetter(
            puzzleImage: 'assets/images/card_at.png',
            correctLetters: ['C'],
            choices: ['A', 'C', 'T'],
            slotOffsets: const [Offset(0.22, 0.77)],
          ),
          PuzzleRound.fullWord(
            puzzleImage: 'assets/images/card_cat.png',
            correctLetters: ['C', 'A', 'T'],
            choices: ['C', 'A', 'T', 'K'],
            slotOffsets: const [
              Offset(0.22, 0.77),
              Offset(0.50, 0.77),
              Offset(0.78, 0.77),
            ],
          ),
        ],
      ),
      SpellingWord(
        name: 'dog',
        cardImage: 'assets/images/card_dog.png',
        rounds: [
          PuzzleRound.missingLetter(
            puzzleImage: 'assets/images/card_og.png',
            correctLetters: ['D'],
            choices: ['D', 'O', 'G'],
            slotOffsets: const [Offset(0.20, 0.77)],
          ),
          PuzzleRound.missingLetter(
            puzzleImage: 'assets/images/card_do.png',
            correctLetters: ['G'],
            choices: ['D', 'O', 'G'],
            slotOffsets: const [Offset(0.76, 0.77)],
          ),
          PuzzleRound.fullWord(
            puzzleImage: 'assets/images/card_dog.png',
            correctLetters: ['D', 'O', 'G'],
            choices: ['D', 'O', 'G', 'K'],
            slotOffsets: const [
              Offset(0.22, 0.77),
              Offset(0.50, 0.77),
              Offset(0.78, 0.77),
            ],
          ),
        ],
      ),
      SpellingWord(
        name: 'horse',
        cardImage: 'assets/images/card_horse.png',
        rounds: [
          PuzzleRound.missingLetter(
            puzzleImage: 'assets/images/card_orse.png',
            correctLetters: ['H'],
            choices: ['H', 'O', 'R'],
            slotOffsets: const [Offset(0.15, 0.77)],
          ),
          PuzzleRound.fullWord(
            puzzleImage: 'assets/images/card_horse.png',
            correctLetters: ['H', 'O', 'R', 'S', 'E'],
            choices: ['H', 'O', 'R', 'S', 'E', 'D', 'G', 'K'],
            slotOffsets: const [
              Offset(0.15, 0.77),
              Offset(0.32, 0.77),
              Offset(0.49, 0.77),
              Offset(0.66, 0.77),
              Offset(0.83, 0.77),
            ],
          ),
        ],
      ),
    ];
  }

  Future<void> _playCorrectSound() async {
    await _player.stop();
    await _player.play(AssetSource('audio/correct.mp3'));
  }

  Future<void> _playWrongSound() async {
    await _player.stop();
    await _player.play(AssetSource('audio/wrong.mp3'));
  }

  void _startPuzzle(SpellingWord word) {
    setState(() {
      currentWord = word;
      currentRoundIndex = 0;
      currentRound = word.rounds[currentRoundIndex];
      inPuzzle = true;
      completed = false;
      currentSlotIndex = 0;
    });
  }

  void _backToCards() {
    setState(() {
      inPuzzle = false;
      currentWord = null;
      currentRound = null;
      completed = false;
      currentSlotIndex = 0;
      currentRoundIndex = 0;
    });
  }

  void _nextRoundSameWord() {
    if (currentWord == null) return;

    if (currentRoundIndex < currentWord!.rounds.length - 1) {
      setState(() {
        currentRoundIndex++;
        currentRound = currentWord!.rounds[currentRoundIndex];
        completed = false;
        currentSlotIndex = 0;
      });
    } else {
      setState(() {
        inPuzzle = false;
        currentWord = null;
        currentRound = null;
        completed = false;
        currentSlotIndex = 0;
        currentRoundIndex = 0;
      });
    }
  }

  void _handleDroppedLetter(String droppedLetter, int slotIndex) {
    if (currentRound == null || completed) return;
    if (slotIndex != currentSlotIndex) return;

    final neededLetter = currentRound!.correctLetters[slotIndex];

    if (droppedLetter == neededLetter) {
      _playCorrectSound();

      if (slotIndex == currentRound!.correctLetters.length - 1) {
        setState(() {
          currentSlotIndex++;
          completed = true;
        });
      } else {
        setState(() {
          currentSlotIndex++;
        });
      }
    } else {
      _playWrongSound();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return inPuzzle ? _buildPuzzleView() : _buildCardSelectionView();
  }

  Widget _buildCardSelectionView() {
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
                  line1: 'Pick a word.',
                  line2: 'Swipe and tap a card to start.',
                  subline: 'Spelling Zone',
                  iconAsset: 'assets/images/card_cat.png',
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 145, bottom: 50),
            child: Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: const MaterialScrollBehavior().copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: words.length,
                      padEnds: false,
                      onPageChanged: (index) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final word = words[index];
                        final isSelected = index == selectedIndex;

                        return GestureDetector(
                          onTap: () => _startPuzzle(word),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            margin: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: isSelected ? 18 : 58,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 220),
                                    scale: isSelected ? 1.0 : 0.82,
                                    child: Image.asset(
                                      word.cardImage,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  word.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: isSelected ? 20 : 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleView() {
    final round = currentRound!;

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
                  onTap: _backToCards,
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
                  line1: round.type == PuzzleType.fullWord
                      ? 'Spell the word.'
                      : 'Finish the word.',
                  line2: 'Drag the letter into the spot.',
                  subline: 'Word: ${currentWord!.name}',
                  iconAsset: currentWord!.cardImage,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 145, 20, 20),
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const cardRatio = 2 / 3;
                      final cardHeight =
                          min(constraints.maxHeight * 0.72, 520.0);
                      final cardWidth = cardHeight * cardRatio;

                      return Center(
                        child: SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.asset(
                                  round.puzzleImage,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              for (int i = 0; i < round.slotOffsets.length; i++)
                                _buildDropSlot(
                                  slotIndex: i,
                                  offset: round.slotOffsets[i],
                                  cardWidth: cardWidth,
                                  cardHeight: cardHeight,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 18,
                  runSpacing: 14,
                  children: round.choices.map((letter) {
                    return _LetterDraggable(
                      letter: letter,
                      enabled: !completed,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: _backToCards,
                      child: const Text('Back to Cards'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: completed ? _nextRoundSameWord : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropSlot({
    required int slotIndex,
    required Offset offset,
    required double cardWidth,
    required double cardHeight,
  }) {
    final bool isFilled = slotIndex < currentSlotIndex;
    final String placedLetter =
        isFilled ? currentRound!.correctLetters[slotIndex] : '';

    return Positioned(
      left: (offset.dx * cardWidth) - 38,
      top: (offset.dy * cardHeight) - 38,
      child: DragTarget<String>(
        onWillAcceptWithDetails: (_) =>
            !completed && slotIndex == currentSlotIndex,
        onAcceptWithDetails: (details) {
          _handleDroppedLetter(details.data, slotIndex);
        },
        builder: (context, candidateData, rejectedData) {
          final highlight =
              candidateData.isNotEmpty && slotIndex == currentSlotIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: highlight
                  ? Colors.pink.withOpacity(0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: isFilled
                ? Image.asset(
                    'assets/images/$placedLetter.png',
                    width: 62,
                    height: 62,
                    fit: BoxFit.contain,
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

enum PuzzleType {
  missingLetter,
  fullWord,
}

class SpellingWord {
  final String name;
  final String cardImage;
  final List<PuzzleRound> rounds;

  SpellingWord({
    required this.name,
    required this.cardImage,
    required this.rounds,
  });
}

class PuzzleRound {
  final PuzzleType type;
  final String puzzleImage;
  final List<String> correctLetters;
  final List<String> choices;
  final List<Offset> slotOffsets;

  PuzzleRound.missingLetter({
    required this.puzzleImage,
    required this.correctLetters,
    required this.choices,
    required this.slotOffsets,
  }) : type = PuzzleType.missingLetter;

  PuzzleRound.fullWord({
    required this.puzzleImage,
    required this.correctLetters,
    required this.choices,
    required this.slotOffsets,
  }) : type = PuzzleType.fullWord;
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
              child: Image.asset(
                iconAsset,
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
                  '$line1  $line2',
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

class _LetterDraggable extends StatelessWidget {
  final String letter;
  final bool enabled;

  const _LetterDraggable({
    required this.letter,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/$letter.png',
      width: 84,
      height: 84,
      fit: BoxFit.contain,
    );

    if (!enabled) {
      return Opacity(opacity: 0.55, child: image);
    }

    return Draggable<String>(
      data: letter,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 96,
          height: 96,
          child: Image.asset(
            'assets/images/$letter.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.30,
        child: image,
      ),
      child: image,
    );
  }
}