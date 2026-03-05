import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../language.dart';
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
    final lang = ref.watch(languageProvider);

    return Scaffold(
      body: GreenBackground(
        child: detailAsync.when(
          data: (page) => _DetailBody(surahNumber: surahNumber, page: page, lang: lang),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorView(
            label: '${lang.strings.failedLoadDetail} #$surahNumber',
            detail: e.toString(),
            retryLabel: lang.strings.retry,
            onRetry: () => ref.invalidate(surahDetailProvider(surahNumber)),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.surahNumber, required this.page, required this.lang});

  final int surahNumber;
  final SurahPageResponse page;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final s = lang.strings;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _DetailHeader(surahNumber: surahNumber, page: page, lang: lang),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
          sliver: SliverList.separated(
            itemCount: page.rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: _AyahCard(
                  row: page.rows[index],
                  ayahLabel: s.ayahLabel,
                  latinLabel: s.latinLabel,
                  translationLabel: s.translationLabel,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _DetailHeader extends ConsumerWidget {
  const _DetailHeader({required this.surahNumber, required this.page, required this.lang});

  final int surahNumber;
  final SurahPageResponse page;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = lang.strings;
    final isMakki = page.revelationType.toLowerCase() == 'meccan';
    final isId = lang == AppLanguage.indonesian;
    final idx = surahNumber - 1;

    final navName = isId && idx < surahNamesId.length
        ? surahNamesId[idx]
        : page.englishName;
    final heroTranslation = isId && idx < surahTranslationsId.length
        ? surahTranslationsId[idx]
        : page.englishNameTranslation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Nav bar: ← nama  |  #N  toggle ──────────────────────────
        Row(
          children: [
            // Tombol back
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
            // Nama surah — mengisi sisa ruang
            Expanded(
              child: Text(
                navName,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Nomor surah
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: AppTheme.white90,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Text(
                '#$surahNumber',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            // Toggle EN/ID — di nav bar, tidak ada overlap
            const _LangToggle(),
          ],
        ),
        const SizedBox(height: 12),

        // ── Hero card ────────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppTheme.heroGradient,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: AppTheme.green800op30, blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Nama Arab — penuh, tidak ada widget lain di baris ini
              Text(page.name, textAlign: TextAlign.center, style: AppTheme.arabicHero),
              const SizedBox(height: 6),
              Text(
                heroTranslation,
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
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  _MetaPill(
                    icon: Icons.place_outlined,
                    label: isMakki ? s.revelationMeccan : s.revelationMedian,
                    color: isMakki ? const Color(0xFFB2F5EA) : const Color(0xFFFEF3C7),
                  ),
                  _MetaPill(
                    icon: Icons.format_list_numbered_rounded,
                    label: '${page.numberOfAyahs} ${s.ayahsCount}',
                    color: AppTheme.white85,
                  ),
                  _MetaPill(
                    icon: Icons.translate_rounded,
                    label: lang.fullLabel,
                    color: AppTheme.white85,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Bismillah — kecuali At-Taubah #9
        if (surahNumber != 9)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(
              color: AppTheme.green800op07,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              border: Border.fromBorderSide(BorderSide(color: AppTheme.green800op12)),
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

// ── Language toggle ───────────────────────────────────────────────────────────

class _LangToggle extends ConsumerWidget {
  const _LangToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = ref.watch(languageProvider) == AppLanguage.english;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.green800,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.green900op08),
        boxShadow: const [
          BoxShadow(color: AppTheme.green800op30, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangChip(
            label: 'EN',
            active: isEn,
            onTap: () => ref.read(languageProvider.notifier).state = AppLanguage.english,
          ),
          _LangChip(
            label: 'ID',
            active: !isEn,
            onTap: () => ref.read(languageProvider.notifier).state = AppLanguage.indonesian,
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? AppTheme.green800 : Colors.white.withOpacity(0.6),
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

// ── Meta pill ─────────────────────────────────────────────────────────────────

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label, required this.color});
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
  const _AyahCard({
    required this.row,
    required this.ayahLabel,
    required this.latinLabel,
    required this.translationLabel,
  });

  final AyahRow row;
  final String ayahLabel;
  final String latinLabel;
  final String translationLabel;

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
          _AyahNumberRow(number: row.numberInSurah, ayahLabel: ayahLabel),
          _ArabicBlock(text: row.arabic),
          if (row.latin.isNotEmpty) _LatinBlock(text: row.latin, label: latinLabel),
          if (row.translation.isNotEmpty) _TranslationBlock(text: row.translation, label: translationLabel),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _AyahNumberRow extends StatelessWidget {
  const _AyahNumberRow({required this.number, required this.ayahLabel});
  final int number;
  final String ayahLabel;

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
            '$ayahLabel $number',
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

class _ArabicBlock extends StatelessWidget {
  const _ArabicBlock({required this.text});
  final String text;

  static const _deco = BoxDecoration(
    color: AppTheme.green800op045,
    border: Border.symmetric(horizontal: BorderSide(color: AppTheme.green900op07)),
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _deco,
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

class _LatinBlock extends StatelessWidget {
  const _LatinBlock({required this.text, required this.label});
  final String text;
  final String label;

  static const _deco = BoxDecoration(
    color: Color(0xFFF0FAF4),
    border: Border(bottom: BorderSide(color: AppTheme.green900op06)),
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _deco,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(label: label, color: AppTheme.green600op65),
            const SizedBox(height: 6),
            Text(text, softWrap: true, style: AppTheme.latinAyah),
          ],
        ),
      ),
    );
  }
}

class _TranslationBlock extends StatelessWidget {
  const _TranslationBlock({required this.text, required this.label});
  final String text;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: label, color: AppTheme.green600),
          const SizedBox(height: 6),
          Text(text, softWrap: true, style: AppTheme.translationAyah),
        ],
      ),
    );
  }
}

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
            borderRadius: const BorderRadius.all(Radius.circular(99)),
          ),
        ),
        const SizedBox(width: 7),
        Text(label, style: AppTheme.sectionLabel.copyWith(color: color)),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.label, required this.detail, required this.retryLabel, required this.onRetry});
  final String label;
  final String detail;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(label, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(detail),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}