import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../services/firestore_service.dart';
import '../services/coach_tips_service.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final String mode;
  final int durationSec;
  final int cycles;
  final int score;

  const ResultScreen({
    super.key,
    required this.mode,
    required this.durationSec,
    required this.cycles,
    required this.score,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _saved = false;
  String? _coachTip;
  bool _loadingTip = false;
  String? _selectedConcern;

  SessionConfig get _config =>
      AppConstants.sessionConfigs[widget.mode] ?? AppConstants.sessionConfigs['calm']!;

  @override
  void initState() {
    super.initState();
    _saveSession();
  }

  Future<void> _saveSession() async {
    if (_saved) return;
    await ref.read(firestoreServiceProvider).saveSession(
          mode: widget.mode,
          durationSec: widget.durationSec,
          breathPattern: _config.breathPattern,
          score: widget.score,
          cycles: widget.cycles,
        );
    if (mounted) setState(() => _saved = true);
  }

  Future<void> _loadCoachTip() async {
    setState(() => _loadingTip = true);
    final tip = await ref.read(coachTipsServiceProvider).getTip(
          mode: widget.mode,
          userConcern: _selectedConcern,
        );
    if (mounted) {
      setState(() {
        _coachTip = tip;
        _loadingTip = false;
      });
    }
  }

  void _shareSession() {
    final config = AppConstants.sessionConfigs[widget.mode] ?? AppConstants.sessionConfigs['calm']!;
    final text = 'J\'ai fait ${widget.cycles} cycles en mode ${config.name} sur BreatheQuest. '
        'Score : ${widget.score}/100. Respire. Joue. Récupère.';
    Share.share(text, subject: 'Ma session BreatheQuest');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Résultat')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text(
                'Session ${_config.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _ScoreRow(label: 'Score', value: '${widget.score}/100'),
                      const Divider(),
                      _ScoreRow(label: 'Cycles', value: '${widget.cycles}'),
                      _ScoreRow(label: 'Durée', value: '${widget.durationSec}s'),
                    ],
                  ),
                ),
              ),
              if (_saved)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Session enregistrée', style: TextStyle(color: AppTheme.primary)),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _shareSession,
                  icon: const Icon(Icons.share),
                  label: const Text('Partager ma session'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Conseil du coach',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _ConcernChip(
                    label: 'Stress',
                    value: 'stress',
                    selected: _selectedConcern == 'stress',
                    onTap: () => setState(() => _selectedConcern = _selectedConcern == 'stress' ? null : 'stress'),
                  ),
                  _ConcernChip(
                    label: 'Énergie',
                    value: 'energy',
                    selected: _selectedConcern == 'energy',
                    onTap: () => setState(() => _selectedConcern = _selectedConcern == 'energy' ? null : 'energy'),
                  ),
                  _ConcernChip(
                    label: 'Sommeil',
                    value: 'sleep',
                    selected: _selectedConcern == 'sleep',
                    onTap: () => setState(() => _selectedConcern = _selectedConcern == 'sleep' ? null : 'sleep'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loadingTip ? null : _loadCoachTip,
                  icon: _loadingTip
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lightbulb_outline),
                  label: const Text('Voir le conseil'),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home),
                  label: const Text('Retour à l\'accueil'),
                ),
              ),
              if (_coachTip != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb, color: AppTheme.primary),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_coachTip!, style: Theme.of(context).textTheme.bodyMedium)),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String value;

  const _ScoreRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primary)),
        ],
      ),
    );
  }
}

class _ConcernChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _ConcernChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primary.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primary,
    );
  }
}
