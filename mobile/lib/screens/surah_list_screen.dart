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
          data: (surah) => _SurahListBody(surah: surah),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorView(
            message: 'Failed to load surah list',
            detail: e.toString(),
            onRetry: () => ref.invalidate(surahListProvider),
          ),
        ),
      ),
    );
  }
}

// ── Body terpisah agar hanya rebuild saat data berubah ───────────────────────

class _SurahListBody extends StatelessWidget {
  const _SurahListBody({required this.surah});
  final List surah;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      // physics default sudah ClampingScrollPhysics di Android,
      // BouncingScrollPhysics di iOS — tidak perlu override
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: _Header(),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          sliver: SliverList.separated(
            itemCount: surah.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final s = surah[index];
              // RepaintBoundary per card: scroll tidak memicu repaint seluruh list
              return RepaintBoundary(
                child: _SurahCard(
                  number: s.number,
                  englishName: s.englishName,
                  translation: s.englishNameTranslation,
                  revelationType: s.revelationType,
                  ayahCount: s.numberOfAyahs,
                  arabicName: s.name,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          SurahDetailScreen(surahNumber: s.number),
                    ),
                  ),
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

/// Header adalah const widget — tidak pernah rebuild.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppTheme.heroGradient,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.green800op35,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: const Column(
            children: [
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  height: 2.0,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'In the name of Allah, the Most Gracious, the Most Merciful',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppTheme.white75,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16),
              Divider(color: AppTheme.white15, height: 1),
              SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  _Pill(icon: Icons.menu_book_rounded,  label: 'Al-Quran'),
                  _Pill(icon: Icons.translate_rounded,   label: 'English Translation'),
                  _Pill(icon: Icons.abc_rounded,         label: 'Latin Transliteration'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'All Surahs',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppTheme.green900op50,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: const BoxDecoration(
        color: AppTheme.white15,
        borderRadius: BorderRadius.all(Radius.circular(99)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.white90),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTheme.pillLabel.copyWith(color: AppTheme.white90),
          ),
        ],
      ),
    );
  }
}

// ── Surah card ────────────────────────────────────────────────────────────────

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
    final isMakki = revelationType.toLowerCase() == 'meccan';
    final tt = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  gradient: AppTheme.badgeGradient,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$number',
                  style: tt.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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
                      style: tt.titleMedium?.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 5,
                      runSpacing: 3,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          translation,
                          style: tt.bodyMedium?.copyWith(
                            color: AppTheme.green900op55,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        _RevChip(isMakki: isMakki, label: revelationType),
                        Text(
                          '$ayahCount ayahs',
                          style: tt.bodyMedium?.copyWith(
                            color: AppTheme.green900op45,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              SizedBox(
                width: 70,
                child: Text(
                  arabicName,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.arabicListTile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevChip extends StatelessWidget {
  const _RevChip({required this.isMakki, required this.label});
  final bool isMakki;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: isMakki
            ? AppTheme.green800op10
            : const Color(0x26F59E0B), // amber @ 15%
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Text(
        label,
        style: AppTheme.sectionLabel.copyWith(
          fontSize: 10,
          letterSpacing: 0.3,
          color: isMakki ? AppTheme.green800 : const Color(0xFF92400E),
        ),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.detail,
    required this.onRetry,
  });

  final String message;
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
          Text(message, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(detail),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}