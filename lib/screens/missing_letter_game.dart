import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MissingLetterGameScreen extends StatefulWidget {
  const MissingLetterGameScreen({super.key});

  @override
  State<MissingLetterGameScreen> createState() =>
      _MissingLetterGameScreenState();
}

class _MissingLetterGameScreenState extends State<MissingLetterGameScreen> {
  final AudioPlayer _player = AudioPlayer();

  late final List<SpellingWord> words;

  int selectedIndex = -1;
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
        name: 'gato',
        cardImage: 'assets/images/card_cat.png',
        rounds: [
          PuzzleRound(
            cardImage: 'assets/images/card_cat.png',
            targetLetters: ['G', 'A', 'T', 'O'],
            draggableSlotIndexes: [1],
            choices: ['A', 'G', 'O', 'T'],
            slotOffsets: const [
              Offset(0.18, 0.77),
              Offset(0.39, 0.77),
              Offset(0.60, 0.77),
              Offset(0.81, 0.77),
            ],
          ),
          PuzzleRound(
            cardImage: 'assets/images/card_cat.png',
            targetLetters: ['G', 'A', 'T', 'O'],
            draggableSlotIndexes: [0],
            choices: ['G', 'A', 'T', 'O'],
            slotOffsets: const [
              Offset(0.18, 0.77),
              Offset(0.39, 0.77),
              Offset(0.60, 0.77),
              Offset(0.81, 0.77),
            ],
          ),
          PuzzleRound(
            cardImage: 'assets/images/card_cat.png',
            targetLetters: ['G', 'A', 'T', 'O'],
            draggableSlotIndexes: [0, 1, 2, 3],
            choices: ['G', 'A', 'T', 'O', 'P', 'R'],
            slotOffsets: const [
              Offset(0.18, 0.77),
              Offset(0.39, 0.77),
              Offset(0.60, 0.77),
              Offset(0.81, 0.77),
            ],
          ),
        ],
      ),
      SpellingWord(
        name: 'perro',
        cardImage: 'assets/images/card_dog.png',
        rounds: [
          PuzzleRound(
            cardImage: 'assets/images/card_dog.png',
            targetLetters: ['P', 'E', 'R', 'R', 'O'],
            draggableSlotIndexes: [0],
            choices: ['P', 'E', 'R', 'O'],
            slotOffsets: const [
              Offset(0.12, 0.77),
              Offset(0.30, 0.77),
              Offset(0.48, 0.77),
              Offset(0.66, 0.77),
              Offset(0.84, 0.77),
            ],
          ),
          PuzzleRound(
            cardImage: 'assets/images/card_dog.png',
            targetLetters: ['P', 'E', 'R', 'R', 'O'],
            draggableSlotIndexes: [4],
            choices: ['P', 'E', 'R', 'O'],
            slotOffsets: const [
              Offset(0.12, 0.77),
              Offset(0.30, 0.77),
              Offset(0.48, 0.77),
              Offset(0.66, 0.77),
              Offset(0.84, 0.77),
            ],
          ),
          PuzzleRound(
            cardImage: 'assets/images/card_dog.png',
            targetLetters: ['P', 'E', 'R', 'R', 'O'],
            draggableSlotIndexes: [0, 1, 2, 3, 4],
            choices: ['P', 'E', 'R', 'R', 'O', 'G', 'A'],
            slotOffsets: const [
              Offset(0.12, 0.77),
              Offset(0.30, 0.77),
              Offset(0.48, 0.77),
              Offset(0.66, 0.77),
              Offset(0.84, 0.77),
            ],
          ),
        ],
      ),
      SpellingWord(
        name: 'caballo',
        cardImage: 'assets/images/card_horse.png',
        rounds: [
          PuzzleRound(
            cardImage: 'assets/images/card_horse.png',
            targetLetters: ['C', 'A', 'B', 'A', 'L', 'L', 'O'],
            draggableSlotIndexes: [0],
            choices: ['C', 'A', 'B', 'O'],
            slotOffsets: const [
              Offset(0.08, 0.77),
              Offset(0.22, 0.77),
              Offset(0.36, 0.77),
              Offset(0.50, 0.77),
              Offset(0.64, 0.77),
              Offset(0.78, 0.77),
              Offset(0.92, 0.77),
            ],
          ),
          PuzzleRound(
            cardImage: 'assets/images/card_horse.png',
            targetLetters: ['C', 'A', 'B', 'A', 'L', 'L', 'O'],
            draggableSlotIndexes: [6],
            choices: ['C', 'A', 'L', 'O'],
            slotOffsets: const [
              Offset(0.08, 0.77),
              Offset(0.22, 0.77),
              Offset(0.36, 0.77),
              Offset(0.50, 0.77),
              Offset(0.64, 0.77),
              Offset(0.78, 0.77),
              Offset(0.92, 0.77),
            ],
          ),
          PuzzleRound(
            cardImage: 'assets/images/card_horse.png',
            targetLetters: ['C', 'A', 'B', 'A', 'L', 'L', 'O'],
            draggableSlotIndexes: [0, 1, 2, 3, 4, 5, 6],
            choices: ['C', 'A', 'B', 'A', 'L', 'L', 'O', 'G', 'P'],
            slotOffsets: const [
              Offset(0.08, 0.77),
              Offset(0.22, 0.77),
              Offset(0.36, 0.77),
              Offset(0.50, 0.77),
              Offset(0.64, 0.77),
              Offset(0.78, 0.77),
              Offset(0.92, 0.77),
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
      _backToCards();
    }
  }

  void _handleDroppedLetter(String droppedLetter, int slotIndex) {
    if (currentRound == null || completed) return;

    final activeSlot = currentRound!.draggableSlotIndexes[currentSlotIndex];
    if (slotIndex != activeSlot) return;

    final neededLetter = currentRound!.targetLetters[slotIndex];

    if (droppedLetter == neededLetter) {
      _playCorrectSound();

      if (currentSlotIndex == currentRound!.draggableSlotIndexes.length - 1) {
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
                  line1: 'Escoge una tarjeta.',
                  line2: 'Pasa el mouse y toca para empezar.',
                  subline: 'Zona de palabras',
                  iconAsset: 'assets/images/card_cat.png',
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 155),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(words.length, (index) {
                  final word = words[index];
                  final isHovered = index == selectedIndex;

                  return MouseRegion(
                    onEnter: (_) => setState(() => selectedIndex = index),
                    onExit: (_) => setState(() => selectedIndex = -1),
                    child: GestureDetector(
                      onTap: () => _startPuzzle(word),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutBack,
                        scale: isHovered ? 1.12 : 1.0,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          width: 260,
                          height: 390,
                          child: Image.asset(
                            word.cardImage,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
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
                  line1: round.isFullWord
                      ? 'Forma la palabra.'
                      : 'Completa la palabra.',
                  line2: round.isFullWord
                      ? 'Arrastra las letras al lugar correcto.'
                      : 'Arrastra la letra al lugar correcto.',
                  subline: 'Palabra: ${currentWord!.name}',
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
                                  round.cardImage,
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
                      child: const Text('Regresar'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: completed ? _nextRoundSameWord : null,
                      child: const Text('Siguiente'),
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
    final round = currentRound!;
    final isDraggableSlot = round.draggableSlotIndexes.contains(slotIndex);
    final draggableOrder = round.draggableSlotIndexes.indexOf(slotIndex);
    final isFilledDraggable =
        isDraggableSlot && draggableOrder < currentSlotIndex;

    final shouldShowLetter = !isDraggableSlot || isFilledDraggable;
    final placedLetter = round.targetLetters[slotIndex];

    return Positioned(
      left: (offset.dx * cardWidth) - 38,
      top: (offset.dy * cardHeight) - 38,
      child: DragTarget<String>(
        onWillAcceptWithDetails: (_) {
          if (completed) return false;
          if (currentSlotIndex >= round.draggableSlotIndexes.length) {
            return false;
          }
          return slotIndex == round.draggableSlotIndexes[currentSlotIndex];
        },
        onAcceptWithDetails: (details) {
          _handleDroppedLetter(details.data, slotIndex);
        },
        builder: (context, candidateData, rejectedData) {
          final highlight =
              candidateData.isNotEmpty &&
              currentSlotIndex < round.draggableSlotIndexes.length &&
              slotIndex == round.draggableSlotIndexes[currentSlotIndex];

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
            child: shouldShowLetter
                ? _LetterTile(letter: placedLetter, size: 62)
                : Container(
                    width: 58,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B2A3A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
          );
        },
      ),
    );
  }
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
  final String cardImage;
  final List<String> targetLetters;
  final List<int> draggableSlotIndexes;
  final List<String> choices;
  final List<Offset> slotOffsets;

  PuzzleRound({
    required this.cardImage,
    required this.targetLetters,
    required this.draggableSlotIndexes,
    required this.choices,
    required this.slotOffsets,
  });

  bool get isFullWord => draggableSlotIndexes.length == targetLetters.length;
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
    final tile = _LetterTile(letter: letter, size: 84);

    if (!enabled) {
      return Opacity(opacity: 0.55, child: tile);
    }

    return Draggable<String>(
      data: letter,
      feedback: Material(
        color: Colors.transparent,
        child: _LetterTile(letter: letter, size: 84),
      ),
      childWhenDragging: Opacity(
        opacity: 0.30,
        child: tile,
      ),
      child: tile,
    );
  }
}

class _LetterTile extends StatelessWidget {
  final String letter;
  final double size;

  const _LetterTile({
    required this.letter,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/$letter.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                color: Colors.black26,
              ),
            ],
          ),
          child: Text(
            letter,
            style: TextStyle(
              fontSize: size * 0.42,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        );
      },
    );
  }
}