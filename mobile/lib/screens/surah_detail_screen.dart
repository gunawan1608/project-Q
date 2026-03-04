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
            final transliteration = page.transliteration;
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
                      final tl = (transliteration != null &&
                              index < transliteration.ayahs.length)
                          ? transliteration.ayahs[index]
                          : null;
                      return _AyahCard(
                        numberInSurah: a.numberInSurah,
                        arabic: a.text,
                        transliteration: tl?.text,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

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
        // ── Nav bar ──────────────────────────────────────────────
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
            // FIX: use Flexible so long names don't overflow
            Flexible(
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
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Hero card ─────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.green800, AppTheme.green900],
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
                // FIX: Wrap replaces Row so pills never overflow
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MetaPill(
                      icon: Icons.place_outlined,
                      label: revelationType,
                      color: isMakki
                          ? Colors.tealAccent.shade100
                          : Colors.amber.shade100,
                    ),
                    _MetaPill(
                      icon: Icons.format_list_numbered_rounded,
                      label: '$ayahCount Ayahs',
                      color: Colors.white.withOpacity(0.85),
                    ),
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

        // ── Bismillah (skip for At-Tawbah #9) ─────────────────────
        if (surahNumber != 9)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: AppTheme.green800.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.green800.withOpacity(0.12)),
            ),
            child: const Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 24,
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

// ─────────────────────────────────────────────────────────────────────────────
// Meta pill
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Ayah card  ─  Arabic → Latin → Terjemahan
// ─────────────────────────────────────────────────────────────────────────────

class _AyahCard extends StatelessWidget {
  const _AyahCard({
    required this.numberInSurah,
    required this.arabic,
    this.transliteration,
    this.translation,
  });

  final int numberInSurah;
  final String arabic;
  final String? transliteration;
  final String? translation;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppTheme.green900.withOpacity(0.07)),
      ),
      // FIX: use intrinsic Column instead of fixed-height containers
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AyahNumberRow(number: numberInSurah),
          _ArabicBlock(text: arabic),
          if (transliteration != null && transliteration!.isNotEmpty)
            _LatinBlock(text: transliteration!),
          if (translation != null && translation!.isNotEmpty)
            _TranslationBlock(text: translation!),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// ── Ayah number row ───────────────────────────────────────────────────────────

class _AyahNumberRow extends StatelessWidget {
  const _AyahNumberRow({required this.number});
  final int number;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.green800,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Ayah $number',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.green900.withOpacity(0.38),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Arabic block ──────────────────────────────────────────────────────────────

class _ArabicBlock extends StatelessWidget {
  const _ArabicBlock({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      // FIX: no fixed height — let the text decide its own height
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.green800.withOpacity(0.045),
        border: Border.symmetric(
          horizontal:
              BorderSide(color: AppTheme.green900.withOpacity(0.07)),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.right,
        // FIX: explicit RTL direction so the widget never tries to clip
        textDirection: TextDirection.rtl,
        softWrap: true,
        style: const TextStyle(
          fontFamily: 'Amiri',
          // Slightly reduced from 28 → 26 to give more wrapping room on
          // narrow phones while still feeling generous.
          fontSize: 26,
          height: 2.3,
          color: AppTheme.green900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Latin / transliteration block ────────────────────────────────────────────

class _LatinBlock extends StatelessWidget {
  const _LatinBlock({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAF4),
        border: Border(
          bottom: BorderSide(color: AppTheme.green900.withOpacity(0.06)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
            label: 'Latin',
            color: AppTheme.green600.withOpacity(0.65),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            softWrap: true,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              height: 1.9,
              fontStyle: FontStyle.italic,
              color: AppTheme.green900.withOpacity(0.68),
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Translation block ─────────────────────────────────────────────────────────

class _TranslationBlock extends StatelessWidget {
  const _TranslationBlock({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
            label: 'Terjemahan',
            color: AppTheme.green600,
          ),
          const SizedBox(height: 6),
          Text(
            text,
            softWrap: true,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 1.8,
              color: AppTheme.green900.withOpacity(0.85),
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared label widget ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}