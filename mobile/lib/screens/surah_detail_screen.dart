import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme.dart';
import '../widgets/green_background.dart';

class SurahDetailScreen extends ConsumerWidget {
  const SurahDetailScreen({super.key, required this.surahNumber});

  final int surahNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(surahDetailProvider(surahNumber));

    return Scaffold(
      body: GreenBackground(
        child: detailAsync.when(
          data: (page) {
            final arabic = page.arabic;
            final translation = page.translation;
            final count = arabic.ayahs.length;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                    child: _DetailHeader(
                      surahNumber: surahNumber,
                      arabicName: arabic.name,
                      englishName: arabic.englishName,
                      englishNameTranslation: arabic.englishNameTranslation,
                      revelationType: arabic.revelationType,
                      ayahCount: arabic.numberOfAyahs,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: count,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final a = arabic.ayahs[index];
                      final t = index < translation.ayahs.length ? translation.ayahs[index] : null;
                      return _AyahCard(
                        numberInSurah: a.numberInSurah,
                        arabic: a.text,
                        translation: t?.text,
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
                Text('Failed to load surah detail', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(e.toString()),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(surahDetailProvider(surahNumber)),
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

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.surahNumber,
    required this.arabicName,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.ayahCount,
  });

  final int surahNumber;
  final String arabicName;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int ayahCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.85),
                foregroundColor: AppTheme.green900,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$englishName',
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.green900.withOpacity(0.06)),
              ),
              child: Text(
                '$surahNumber',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(englishNameTranslation, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text(
                            '$revelationType • $ayahCount ayahs • en.asad',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.green900.withOpacity(0.62),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      arabicName,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 26,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AyahCard extends StatelessWidget {
  const _AyahCard({
    required this.numberInSurah,
    required this.arabic,
    required this.translation,
  });

  final int numberInSurah;
  final String arabic;
  final String? translation;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.green800.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '$numberInSurah',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.green900,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.green800,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Ayah',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(
              arabic,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
                height: 1.8,
              ),
            ),
            if (translation != null) ...[
              const SizedBox(height: 12),
              Divider(color: AppTheme.green900.withOpacity(0.06), height: 1),
              const SizedBox(height: 12),
              Text(
                translation!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: AppTheme.green900.withOpacity(0.80),
                    ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
