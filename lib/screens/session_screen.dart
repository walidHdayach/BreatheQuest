import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../services/firestore_service.dart';
import '../widgets/breathing_circle.dart';

class SessionScreen extends ConsumerStatefulWidget {
  final String mode;

  const SessionScreen({super.key, required this.mode});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  Timer? _timer;
  int _elapsedSec = 0;
  int _cyclesCompleted = 0;
  bool _isInhale = true;
  bool _isPaused = false;
  bool _hasStopped = false;

  SessionConfig get _config =>
      AppConstants.sessionConfigs[widget.mode] ?? AppConstants.sessionConfigs['calm']!;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPaused || _hasStopped) return;
      setState(() {
        _elapsedSec++;
        if (_elapsedSec >= _config.totalDurationSec) _finishSession();
      });
    });
  }

  void _onBreathPhase(bool isInhale) {
    if (_isInhale && !isInhale) {
      setState(() => _cyclesCompleted++);
    }
    _isInhale = isInhale;
  }

  void _finishSession() {
    _timer?.cancel();
    _hasStopped = true;
    final score = _computeScore();
    if (!mounted) return;
    context.go('/result', extra: {
      'mode': widget.mode,
      'durationSec': _elapsedSec,
      'cycles': _cyclesCompleted,
      'score': score,
    });
  }

  int _computeScore() {
    int score = 0;
    final expectedCycles = _config.totalDurationSec ~/ (_config.inhaleSec + _config.exhaleSec);
    if (expectedCycles > 0) {
      final completionRatio = _cyclesCompleted / expectedCycles;
      score = (60 * completionRatio).round();
    }
    score += (_cyclesCompleted * 5).clamp(0, 40);
    return score.clamp(0, 100);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phaseText = _isInhale ? 'Inspirez' : 'Expirez';
    final remaining = _config.totalDurationSec - _elapsedSec;

    return Scaffold(
      appBar: AppBar(
        title: Text(_config.name),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              phaseText,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: BreathingCircle(
                inhaleSec: _config.inhaleSec,
                exhaleSec: _config.exhaleSec,
                paused: _isPaused,
                onBreathPhase: _onBreathPhase,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${remaining}s',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
            ),
            Text(
              'Cycles : $_cyclesCompleted',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: () {
                    setState(() {
                      _isPaused = !_isPaused;
                      if (_isPaused) {
                        _timer?.cancel();
                      } else {
                        _startTimer();
                      }
                    });
                  },
                  icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                ),
                const SizedBox(width: 24),
                TextButton.icon(
                  onPressed: () => _showExitDialog(),
                  icon: const Icon(Icons.stop),
                  label: const Text('Arrêter'),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitter la session ?'),
        content: const Text('La session ne sera pas enregistrée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continuer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }
}
