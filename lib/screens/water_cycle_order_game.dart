import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';

class WaterCycleOrderGame extends StatefulWidget {
  const WaterCycleOrderGame({super.key});

  @override
  State<WaterCycleOrderGame> createState() => _WaterCycleOrderGameState();
}

class _WaterCycleOrderGameState extends State<WaterCycleOrderGame> {
  late final VideoPlayerController _controller;
  bool _hasStartedGame = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/videos/rain_stages.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
      });

    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (!_controller.value.isInitialized || _hasStartedGame) return;

    final finished =
        _controller.value.position >= _controller.value.duration &&
        !_controller.value.isPlaying;

    if (finished) {
  _controller.pause();
  _controller.seekTo(Duration.zero);

  setState(() {
    _hasStartedGame = true;
  });
}
  }

  void _skipVideo() {
  if (_hasStartedGame) return;

  if (_controller.value.isInitialized) {
    _controller.pause();
    _controller.seekTo(Duration.zero);
  }

  setState(() {
    _hasStartedGame = true;
  });
}

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _hasStartedGame
        ? const _WaterCycleOrderGameBody()
        : _WaterCycleVideoIntro(
            controller: _controller,
            onSkip: _skipVideo,
          );
  }
}

class _WaterCycleVideoIntro extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onSkip;

  const _WaterCycleVideoIntro({
    required this.controller,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isReady = controller.value.isInitialized;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFCFE8FF)),
          _SkyCloudsLayer(),

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
                  line1: 'Lección del ciclo del agua',
                  line2: 'Mira el video antes de jugar.',
                  subline: isReady ? 'Video listo' : 'Cargando video...',
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 120, 14, 16),
              child: Center(
                child: _FeltCard(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxVideoHeight = constraints.maxHeight * 0.6;

                      return SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isReady)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: maxVideoHeight,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: AspectRatio(
                                    aspectRatio: controller.value.aspectRatio,
                                    child: VideoPlayer(controller),
                                  ),
                                ),
                              )
                            else
                              const SizedBox(
                                height: 220,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            const SizedBox(height: 14),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                ElevatedButton(
                                  onPressed: isReady
                                      ? () {
                                          if (controller.value.isPlaying) {
                                            controller.pause();
                                          } else {
                                            controller.play();
                                          }
                                        }
                                      : null,
                                  child: Text(
                                    isReady && controller.value.isPlaying
                                        ? 'Pausar'
                                        : 'Reproducir',
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: isReady
                                      ? () {
                                          controller.seekTo(Duration.zero);
                                          controller.play();
                                        }
                                      : null,
                                  child: const Text('Repetir'),
                                ),
                                ElevatedButton(
                                  onPressed: isReady ? onSkip : null,
                                  child: const Text('Saltar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
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

class _WaterCycleOrderGameBody extends StatefulWidget {
  const _WaterCycleOrderGameBody();

  @override
  State<_WaterCycleOrderGameBody> createState() =>
      _WaterCycleOrderGameBodyState();
}

class _WaterCycleOrderGameBodyState extends State<_WaterCycleOrderGameBody> {
  final List<_StageItem> correctOrder = const [
    _StageItem(
      word: 'Evaporación',
      imageAsset: 'assets/images/evaporation.png',
    ),
    _StageItem(
      word: 'Condensación',
      imageAsset: 'assets/images/condensation.png',
    ),
    _StageItem(
      word: 'Precipitación',
      imageAsset: 'assets/images/precipitation.png',
    ),
    _StageItem(
      word: 'Acumulación',
      imageAsset: 'assets/images/collection.png',
    ),
  ];

  late List<_StageItem> shuffled;
  final List<_StageItem> userOrder = [];

  String? _resultMessage;
  bool? _isCorrect;

  late final AudioPlayer _correctPlayer;
  late final AudioPlayer _wrongPlayer;

  @override
  void initState() {
    super.initState();
    _correctPlayer = AudioPlayer();
    _wrongPlayer = AudioPlayer();
    _resetGame();
  }

  Future<void> _playCorrect() async {
    await _correctPlayer.stop();
    await _correctPlayer.play(AssetSource('audio/correct.mp3'));
  }

  Future<void> _playWrong() async {
    await _wrongPlayer.stop();
    await _wrongPlayer.play(AssetSource('audio/wrong.mp3'));
  }

  void _resetGame() {
    setState(() {
      shuffled = List<_StageItem>.from(correctOrder)..shuffle(Random());
      userOrder.clear();
      _resultMessage = null;
      _isCorrect = null;
    });
  }

  Future<void> _checkAnswer() async {
    if (userOrder.length != correctOrder.length) {
      setState(() {
        _resultMessage = 'Primero coloca las 4 etapas.';
        _isCorrect = false;
      });
      await _playWrong();
      return;
    }

    bool correct = true;
    for (int i = 0; i < correctOrder.length; i++) {
      if (userOrder[i].word != correctOrder[i].word) {
        correct = false;
        break;
      }
    }

    setState(() {
      _isCorrect = correct;
      _resultMessage =
          correct ? '✅ ¡Orden correcto!' : '❌ Inténtalo otra vez.';
    });

    if (correct) {
      await _playCorrect();
    } else {
      await _playWrong();
    }
  }

  @override
  void dispose() {
    _correctPlayer.dispose();
    _wrongPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFCFE8FF)),
          _SkyCloudsLayer(),

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
                  line1: 'Ordena el ciclo del agua',
                  line2: 'Arrastra las etapas en el orden correcto.',
                  subline: 'Colocadas: ${userOrder.length}/4',
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 120, 14, 16),
              child: Column(
                children: [
                  _FeltCard(
                    child: Column(
                      children: [
                        const Text(
                          'Pon las imágenes en el orden correcto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(4, (index) {
                            return DragTarget<_StageItem>(
                              onWillAcceptWithDetails: (details) {
                                return userOrder.length == index &&
                                    !userOrder.any(
                                      (item) => item.word == details.data.word,
                                    );
                              },
                              onAcceptWithDetails: (details) {
                                final item = details.data;
                                if (userOrder.length == index &&
                                    !userOrder.any(
                                      (existing) => existing.word == item.word,
                                    )) {
                                  setState(() {
                                    userOrder.add(item);
                                    _resultMessage = null;
                                    _isCorrect = null;
                                  });
                                }
                              },
                              builder: (context, candidates, rejects) {
                                final filled = index < userOrder.length;
                                final highlighted = candidates.isNotEmpty;

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 120),
                                  width: 78,
                                  height: 96,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF6E9).withOpacity(
                                      highlighted ? 0.98 : 0.92,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.brown.withOpacity(
                                        highlighted ? 0.65 : 0.35,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  child: filled
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              userOrder[index].imageAsset,
                                              width: 42,
                                              height: 42,
                                              fit: BoxFit.contain,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              userOrder[index].word,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black.withOpacity(
                                                0.35,
                                              ),
                                            ),
                                          ),
                                        ),
                                );
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: shuffled.map((item) {
                          final alreadyPlaced = userOrder.any(
                            (placed) => placed.word == item.word,
                          );

                          return Opacity(
                            opacity: alreadyPlaced ? 0.35 : 1,
                            child: Draggable<_StageItem>(
                              data: item,
                              maxSimultaneousDrags: alreadyPlaced ? 0 : 1,
                              feedback: Material(
                                color: Colors.transparent,
                                child: _PictureStageChip(item: item),
                              ),
                              childWhenDragging: _PictureStageChip(
                                item: item,
                                faded: true,
                              ),
                              child: _PictureStageChip(
                                item: item,
                                disabled: alreadyPlaced,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _FeltCard(
                    child: Column(
                      children: [
                        if (_resultMessage != null) ...[
                          Text(
                            _resultMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: _isCorrect == null
                                  ? Colors.black
                                  : (_isCorrect!
                                      ? Colors.green.shade800
                                      : Colors.red.shade800),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: _resetGame,
                              child: const Text('Reiniciar'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _checkAnswer,
                              child: const Text('Revisar respuesta'),
                            ),
                          ],
                        ),
                        if (_isCorrect == true) ...[
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Volver'),
                          ),
                        ],
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
}

class _StageItem {
  final String word;
  final String imageAsset;

  const _StageItem({
    required this.word,
    required this.imageAsset,
  });
}

class _PictureStageChip extends StatelessWidget {
  final _StageItem item;
  final bool disabled;
  final bool faded;

  const _PictureStageChip({
    required this.item,
    this.disabled = false,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = (disabled || faded) ? 0.55 : 0.92;

    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            item.imageAsset,
            width: 52,
            height: 52,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 6),
          Text(
            item.word,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.black.withOpacity(disabled ? 0.55 : 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkyCloudsLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
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
      },
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