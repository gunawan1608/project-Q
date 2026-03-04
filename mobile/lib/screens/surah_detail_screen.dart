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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                  sliver: SliverList.separated(
                    itemCount: count,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final a = arabic.ayahs[index];
                      final t = index < translation.ayahs.length
                          ? translation.ayahs[index]
                          : null;
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
                Text('Failed to load surah detail',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(e.toString()),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(surahDetailProvider(surahNumber)),
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
    final isMakki = revelationType.toLowerCase() == 'meccan';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top nav bar
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                foregroundColor: AppTheme.green900,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                englishName,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '#$surahNumber',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Surah info card — dark green hero
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.green800,
                AppTheme.green900,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.green800.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Arabic name large
                Text(
                  arabicName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 36,
                    height: 1.6,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  englishNameTranslation,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.75),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Divider(color: Colors.white.withOpacity(0.15), height: 1),
                const SizedBox(height: 14),
                // Meta pills
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MetaPill(
                      icon: Icons.place_outlined,
                      label: revelationType,
                      color: isMakki
                          ? Colors.tealAccent.shade100
                          : Colors.amber.shade100,
                    ),
                    const SizedBox(width: 8),
                    _MetaPill(
                      icon: Icons.format_list_numbered_rounded,
                      label: '$ayahCount Ayahs',
                      color: Colors.white.withOpacity(0.85),
                    ),
                    const SizedBox(width: 8),
                    _MetaPill(
                      icon: Icons.translate_rounded,
                      label: 'en.asad',
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Bismillah (for all surahs except At-Tawbah #9)
        if (surahNumber != 9)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: AppTheme.green800.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.green800.withOpacity(0.12)),
            ),
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
                height: 2.0,
                color: AppTheme.green800,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppTheme.green900.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header row ──────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // Ayah number badge
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppTheme.green800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$numberInSurah',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Ayah label
                  Text(
                    'Ayah $numberInSurah',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.green900.withOpacity(0.45),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            // ── Arabic text block ────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: AppTheme.green800.withOpacity(0.05),
                border: Border.symmetric(
                  horizontal: BorderSide(
                      color: AppTheme.green900.withOpacity(0.07)),
                ),
              ),
              child: Text(
                arabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 26,        // bigger for comfort
                  height: 2.2,         // generous line height for Arabic
                  color: AppTheme.green900,
                  letterSpacing: 0.3,
                ),
              ),
            ),

            // ── Translation block ────────────────────────────
            if (translation != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppTheme.green600,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Translation',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.green800.withOpacity(0.6),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Translation text
                    Text(
                      translation!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,        // readable size
                        height: 1.75,        // comfortable line spacing
                        color: AppTheme.green900.withOpacity(0.82),
                        letterSpacing: 0.1,
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
}