import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SpanishRhymeGame extends StatefulWidget {
  const SpanishRhymeGame({super.key});

  @override
  State<SpanishRhymeGame> createState() => _SpanishRhymeGameState();
}

class _SpanishRhymeGameState extends State<SpanishRhymeGame> {
  final List<_RhymeQuestion> _questions = const [
    _RhymeQuestion(
      imageAsset: 'assets/images/card_cat.png',
      pictureWord: 'gato',
      correctAnswer: 'pato',
      options: ['pato', 'sol', 'mesa'],
    ),
    _RhymeQuestion(
      imageAsset: 'assets/images/card_dog.png',
      pictureWord: 'perro',
      correctAnswer: 'cerro',
      options: ['cerro', 'casa', 'flor'],
    ),
    _RhymeQuestion(
      imageAsset: 'assets/images/card_horse.png',
      pictureWord: 'caballo',
      correctAnswer: 'gallo',
      options: ['gallo', 'luna', 'árbol'],
    ),
    _RhymeQuestion(
      imageAsset: 'assets/images/apple.png',
      pictureWord: 'manzana',
      correctAnswer: 'campana',
      options: ['campana', 'perro', 'nube'],
    ),
  ];

  late List<_RhymeQuestion> _shuffledQuestions;
  late _RhymeQuestion _currentQuestion;
  late List<String> _currentOptions;

  int _index = 0;
  String? _message;
  bool? _isCorrect;

  late final AudioPlayer _correctPlayer;
  late final AudioPlayer _wrongPlayer;

  @override
  void initState() {
    super.initState();

    _correctPlayer = AudioPlayer();
    _wrongPlayer = AudioPlayer();

    _shuffledQuestions = List<_RhymeQuestion>.from(_questions)
      ..shuffle(Random());
    _loadQuestion();
  }

  void _loadQuestion() {
    _currentQuestion = _shuffledQuestions[_index];
    _currentOptions = List<String>.from(_currentQuestion.options)
      ..shuffle(Random());

    _message = null;
    _isCorrect = null;
  }

  Future<void> _playCorrect() async {
    await _correctPlayer.stop();
    await _correctPlayer.play(AssetSource('audio/correct.mp3'));
  }

  Future<void> _playWrong() async {
    await _wrongPlayer.stop();
    await _wrongPlayer.play(AssetSource('audio/wrong.mp3'));
  }

  Future<void> _chooseAnswer(String answer) async {
    final correct = answer == _currentQuestion.correctAnswer;

    setState(() {
      _isCorrect = correct;
      _message = correct ? '✅ ¡Correcto!' : '❌ Inténtalo otra vez.';
    });

    if (correct) {
      await _playCorrect();
    } else {
      await _playWrong();
    }
  }

  void _nextQuestion() {
    setState(() {
      if (_index < _shuffledQuestions.length - 1) {
        _index++;
      } else {
        _index = 0;
        _shuffledQuestions.shuffle(Random());
      }
      _loadQuestion();
    });
  }

  @override
  void dispose() {
    _correctPlayer.dispose();
    _wrongPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = '${_index + 1}/${_shuffledQuestions.length}';

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
                  iconAsset: 'assets/images/apple.png',
                  line1: 'Rimas en español',
                  line2: 'Escoge la palabra que rima.',
                  subline: 'Pregunta: $progress',
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
                    child: Center(
                      child: _FeltCard(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '¿Qué palabra rima con "${_currentQuestion.pictureWord}"?',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  _currentQuestion.imageAsset,
                                  height: 220,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 18),

                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 12,
                                runSpacing: 12,
                                children: _currentOptions.map((option) {
                                  return _AnswerButton(
                                    label: option,
                                    onTap: () => _chooseAnswer(option),
                                  );
                                }).toList(),
                              ),

                              if (_message != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  _message!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: _isCorrect == true
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                  ),
                                ),
                              ],

                              if (_isCorrect == true) ...[
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _nextQuestion,
                                  child: const Text('Siguiente'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
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
}

class _RhymeQuestion {
  final String imageAsset;
  final String pictureWord;
  final String correctAnswer;
  final List<String> options;

  const _RhymeQuestion({
    required this.imageAsset,
    required this.pictureWord,
    required this.correctAnswer,
    required this.options,
  });
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
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