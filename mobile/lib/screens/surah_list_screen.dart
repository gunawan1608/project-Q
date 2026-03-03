import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme.dart';
import '../widgets/green_background.dart';
import 'surah_detail_screen.dart';

class SurahListScreen extends ConsumerWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahAsync = ref.watch(surahListProvider);

    return Scaffold(
      body: GreenBackground(
        child: surahAsync.when(
          data: (surah) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                    child: _Header(
                      total: surah.length,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: surah.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final s = surah[index];
                      return _SurahCard(
                        number: s.number,
                        englishName: s.englishName,
                        translation: s.englishNameTranslation,
                        revelationType: s.revelationType,
                        ayahCount: s.numberOfAyahs,
                        arabicName: s.name,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SurahDetailScreen(surahNumber: s.number),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text('Failed to load surah list', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(e.toString()),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(surahListProvider),
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.green800,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.menu_book_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Qur'an", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    '$total surahs • English translation',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.green900.withOpacity(0.65),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.green900.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: AppTheme.green800.withOpacity(0.9)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pick a surah to start reading.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _SurahCard extends StatelessWidget {
  const _SurahCard({
    required this.number,
    required this.englishName,
    required this.translation,
    required this.revelationType,
    required this.ayahCount,
    required this.arabicName,
    required this.onTap,
  });

  final int number;
  final String englishName;
  final String translation;
  final String revelationType;
  final int ayahCount;
  final String arabicName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.green800,
                      AppTheme.green600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      englishName,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$translation • $revelationType • $ayahCount ayahs',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.green900.withOpacity(0.62),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                arabicName,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
