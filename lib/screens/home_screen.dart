import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

final userProfileProvider = StreamProvider((ref) {
  return ref.watch(firestoreServiceProvider).watchUserProfile();
});

final weeklyStatsProvider = FutureProvider((ref) async {
  return ref.read(firestoreServiceProvider).getThisWeekStats();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BreatheQuest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Bonjour${user?.displayName != null && user!.displayName!.isNotEmpty ? ', ${user.displayName}' : ''}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.tagline,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _StreakCard(
                streak: profile?.streak ?? 0,
                lastSessionAt: profile?.lastSessionAt,
              ),
              const SizedBox(height: 16),
              ref.watch(weeklyStatsProvider).when(
                    data: (stats) => _WeeklyStatsCard(
                      sessions: stats.sessions,
                      minutes: stats.minutes,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
              const SizedBox(height: 24),
              Text(
                'Choisir une session',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...AppConstants.sessionConfigs.entries.map((e) {
                final config = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SessionCard(
                    title: config.name,
                    subtitle: config.description,
                    onTap: () => context.push('/session/${config.id}'),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  final DateTime? lastSessionAt;

  const _StreakCard({required this.streak, this.lastSessionAt});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department, color: AppTheme.primary, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streak jour${streak != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.primary,
                        ),
                  ),
                  Text(
                    'Série en cours',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (lastSessionAt != null)
                    Text(
                      'Dernière session : ${_formatDate(lastSessionAt!)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(d.year, d.month, d.day);
    final diff = today.difference(sessionDay).inDays;
    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Hier';
    if (diff < 7) return 'Il y a $diff jours';
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _WeeklyStatsCard extends StatelessWidget {
  final int sessions;
  final int minutes;

  const _WeeklyStatsCard({required this.sessions, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppTheme.primary, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cette semaine',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '$sessions session${sessions != 1 ? 's' : ''} • $minutes min',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SessionCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                child: const Icon(Icons.air, color: AppTheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
