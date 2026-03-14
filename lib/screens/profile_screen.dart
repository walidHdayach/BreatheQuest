import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/session_record.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'home_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const Map<String, String> badgeLabels = {
    'FIRST_SESSION': 'Première session',
    'STREAK_3': 'Série de 3 jours',
    'FOCUS_5': '5 sessions Focus',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final auth = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Progrès'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName ?? profile.email ?? 'Utilisateur',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          if (profile.email != null)
                            Text(
                              profile.email!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _StatChip(
                                icon: Icons.local_fire_department,
                                value: '${profile.streak}',
                                label: 'Série',
                              ),
                              const SizedBox(width: 16),
                              _StatChip(
                                icon: Icons.timer,
                                value: '${profile.totalMinutes}',
                                label: 'Minutes',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Badges',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.badges.map((id) {
                      return Chip(
                        avatar: Icon(
                          _badgeIcon(id),
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        label: Text(badgeLabels[id] ?? id),
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                      );
                    }).toList(),
                  ),
                  if (profile.badges.isEmpty)
                    Text(
                      'Complétez des sessions pour débloquer des badges.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Historique des sessions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ref.watch(_sessionHistoryProvider).when(
                        data: (sessions) {
                          if (sessions.isEmpty) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'Aucune session pour le moment.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: sessions.map((s) => _SessionTile(record: s)).toList(),
                          );
                        },
                        loading: () => const Center(child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        )),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await auth.signOut();
                        if (context.mounted) context.go('/login');
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Déconnexion'),
                      style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  IconData _badgeIcon(String id) {
    switch (id) {
      case 'FIRST_SESSION':
        return Icons.star;
      case 'STREAK_3':
        return Icons.local_fire_department;
      case 'FOCUS_5':
        return Icons.psychology;
      default:
        return Icons.emoji_events;
    }
  }
}

final _sessionHistoryProvider = StreamProvider((ref) {
  return ref.watch(firestoreServiceProvider).watchSessionHistory(limit: 15);
});

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatChip({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.primary, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primary)),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  final SessionRecord record;

  const _SessionTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final mode = record.mode;
    final createdAt = record.createdAt;
    final score = record.score;
    final cycles = record.cycles;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
          child: Text(
            mode.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text('$mode • $cycles cycles'),
        subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(createdAt)),
        trailing: Text('$score', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
      ),
    );
  }
}
