import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models.dart';
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
          // Pisahkan body ke widget sendiri → hanya body yang rebuild saat data
          data: (page) => _DetailBody(surahNumber: surahNumber, page: page),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorView(
            surahNumber: surahNumber,
            detail: e.toString(),
            onRetry: () => ref.invalidate(surahDetailProvider(surahNumber)),
          ),
        ),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.surahNumber, required this.page});

  final int surahNumber;
  final SurahPageResponse page;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _DetailHeader(
              surahNumber: surahNumber,
              name: page.name,
              englishName: page.englishName,
              englishNameTranslation: page.englishNameTranslation,
              revelationType: page.revelationType,
              ayahCount: page.numberOfAyahs,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
          sliver: SliverList.separated(
            itemCount: page.rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: _AyahCard(row: page.rows[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.surahNumber,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.ayahCount,
  });

  final int surahNumber;
  final String name;
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
        // ── Nav bar ────────────────────────────────────────────────────
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.white90,
                foregroundColor: AppTheme.green900,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                englishName,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Badge nomor — const decoration
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: AppTheme.white90,
                borderRadius: BorderRadius.all(Radius.circular(12)),
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

        // ── Hero card ──────────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppTheme.heroGradient,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.green800op30,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(name, textAlign: TextAlign.center, style: AppTheme.arabicHero),
              const SizedBox(height: 4),
              Text(
                englishNameTranslation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.white75,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              const Divider(color: AppTheme.white15, height: 1),
              const SizedBox(height: 14),
              // Wrap: pills tidak overflow di layar sempit
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  _MetaPill(
                    icon: Icons.place_outlined,
                    label: revelationType,
                    // warna berbeda: Meccan = teal, Medinan = amber
                    color: isMakki
                        ? const Color(0xFFB2F5EA) // tealAccent.shade100
                        : const Color(0xFFFEF3C7), // amber.shade100
                  ),
                  _MetaPill(
                    icon: Icons.format_list_numbered_rounded,
                    label: '$ayahCount Ayahs',
                    color: AppTheme.white85,
                  ),
                  const _MetaPill(
                    icon: Icons.translate_rounded,
                    label: 'en.asad',
                    color: AppTheme.white85,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Bismillah (kecuali Surah #9 At-Tawbah) ────────────────────
        if (surahNumber != 9)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(
              color: AppTheme.green800op07,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              border: Border.fromBorderSide(
                BorderSide(color: AppTheme.green800op12),
              ),
            ),
            child: const Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              textAlign: TextAlign.center,
              style: AppTheme.arabicBismillah,
            ),
          ),
      ],
    );
  }
}

// ── Meta pill ─────────────────────────────────────────────────────────────────

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
      decoration: const BoxDecoration(
        color: AppTheme.white12,
        borderRadius: BorderRadius.all(Radius.circular(99)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label, style: AppTheme.pillLabel.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ── Ayah card ─────────────────────────────────────────────────────────────────
class _AyahCard extends StatelessWidget {
  const _AyahCard({required this.row});

  final AyahRow row;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: AppTheme.green900op07),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AyahNumberRow(number: row.numberInSurah),
          _ArabicBlock(text: row.arabic),
          if (row.latin.isNotEmpty) _LatinBlock(text: row.latin),
          if (row.translation.isNotEmpty) _TranslationBlock(text: row.translation),
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
            decoration: const BoxDecoration(
              color: AppTheme.green800,
              borderRadius: BorderRadius.all(Radius.circular(9)),
            ),
            alignment: Alignment.center,
            child: Text('$number', style: AppTheme.ayahBadgeNumber),
          ),
          const Spacer(),
          Text(
            'Ayah $number',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.green900op38,
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

  static const _decoration = BoxDecoration(
    color: AppTheme.green800op045,
    border: Border.symmetric(
      horizontal: BorderSide(color: AppTheme.green900op07),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _decoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Text(
          text,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          softWrap: true,
          style: AppTheme.arabicAyah,
        ),
      ),
    );
  }
}

// ── Latin block ───────────────────────────────────────────────────────────────

class _LatinBlock extends StatelessWidget {
  const _LatinBlock({required this.text});
  final String text;

  static const _decoration = BoxDecoration(
    color: Color(0xFFF0FAF4),
    border: Border(
      bottom: BorderSide(color: AppTheme.green900op06),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _decoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel(label: 'Latin', color: AppTheme.green600op65),
            const SizedBox(height: 6),
            Text(text, softWrap: true, style: AppTheme.latinAyah),
          ],
        ),
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
          const _SectionLabel(label: 'Terjemahan', color: AppTheme.green600),
          const SizedBox(height: 6),
          Text(text, softWrap: true, style: AppTheme.translationAyah),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Accent bar
        Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(99)),
          ),
        ),
        const SizedBox(width: 7),
        Text(label, style: AppTheme.sectionLabel.copyWith(color: color)),
      ],
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.surahNumber,
    required this.detail,
    required this.onRetry,
  });

  final int surahNumber;
  final String detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('Failed to load surah #$surahNumber',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(detail),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}