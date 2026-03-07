import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../language.dart';
import '../models.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/shared.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Root
// ─────────────────────────────────────────────────────────────────────────────

class SurahDetailScreen extends ConsumerStatefulWidget {
  const SurahDetailScreen({
    super.key,
    required this.surahNumber,
    required this.totalSurahs,
  });
  final int surahNumber;
  final int totalSurahs;

  @override
  ConsumerState<SurahDetailScreen> createState() => _State();
}

class _State extends ConsumerState<SurahDetailScreen>
    with SingleTickerProviderStateMixin {
  late int _cur = widget.surahNumber;

  // One fade controller for surah switching — no slide needed
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1.0,
  );

  Future<void> _goTo(int n) async {
    if (n < 1 || n > widget.totalSurahs || n == _cur) return;
    HapticFeedback.lightImpact();
    await _fade.reverse();
    if (!mounted) return;
    setState(() => _cur = n);
    _fade.forward();
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  void _openSettings() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _SettingsSheet(
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings    = ref.watch(readerSettingsProvider);
    final args        = (id: _cur, edition: settings.language.edition);
    final detailAsync = ref.watch(surahDetailProvider(args));
    final isDark      = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: detailAsync.when(
          // ── loaded ───────────────────────────────────────────────────────
          data: (page) => FadeTransition(
            opacity: _fade,
            child: _DetailBody(
              cur: _cur,
              total: widget.totalSurahs,
              page: page,
              settings: settings,
              isDark: isDark,
              onPrev: _cur > 1 ? () => _goTo(_cur - 1) : null,
              onNext: _cur < widget.totalSurahs ? () => _goTo(_cur + 1) : null,
              onHome: () => Navigator.of(context).popUntil((r) => r.isFirst),
              onSettings: _openSettings,
            ),
          ),
          // ── loading — bounded by SafeArea via AppBackground ──────────────
          loading: () => _LoadingBody(isDark: isDark),
          // ── error ────────────────────────────────────────────────────────
          error: (e, _) => _ErrorBody(
            isDark: isDark,
            label: 'Gagal memuat Surah $_cur',
            detail: e.toString(),
            onRetry: () => ref.invalidate(surahDetailProvider(args)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading skeleton
// KEY FIX: wrapped in LayoutBuilder so Column is always bounded.
// ShimmerScope drives all boxes with a single AnimationController.
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ShimmerScope(
      // LayoutBuilder gives us a finite height → Column won't overflow
      child: LayoutBuilder(builder: (context, constraints) {
        final d = isDark;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // never expands beyond children
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // nav bar
              ShimmerBox(height: 48,  radius: 13, isDark: d),
              const SizedBox(height: 12),
              // hero
              ShimmerBox(height: 160, radius: 24, isDark: d),
              const SizedBox(height: 10),
              // bismillah
              ShimmerBox(height: 56,  radius: 18, isDark: d),
              const SizedBox(height: 10),
              // ayah cards — use remaining height, capped so we never overflow
              ShimmerBox(height: 150, radius: 20, isDark: d),
              const SizedBox(height: 10),
              ShimmerBox(height: 180, radius: 20, isDark: d),
              const SizedBox(height: 10),
              // only show 3rd card if screen is tall enough
              if (constraints.maxHeight > 680)
                ShimmerBox(height: 160, radius: 20, isDark: d),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail body — CustomScrollView
// ─────────────────────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.cur,
    required this.total,
    required this.page,
    required this.settings,
    required this.isDark,
    required this.onPrev,
    required this.onNext,
    required this.onHome,
    required this.onSettings,
  });

  final int cur, total;
  final SurahPageResponse page;
  final ReaderSettings settings;
  final bool isDark;
  final VoidCallback? onPrev, onNext;
  final VoidCallback onHome, onSettings;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        // nav bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: _NavBar(
              cur: cur, total: total,
              page: page, settings: settings, isDark: isDark,
              onPrev: onPrev, onNext: onNext,
              onHome: onHome, onSettings: onSettings,
            ),
          ),
        ),
        // hero
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: _HeroCard(cur: cur, page: page, settings: settings, isDark: isDark),
          ),
        ),
        // bismillah
        if (cur != 9)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: _BismillahCard(isDark: isDark),
            ),
          ),
        // ayah list — SliverList.builder is lazy, only builds visible items
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          sliver: SliverList.builder(
            itemCount: page.rows.length,
            itemBuilder: (ctx, i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RepaintBoundary(
                // TweenAnimationBuilder: no AnimationController per card
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  // items > 7 skip animation for perf (start at 1.0)
                  duration: i < 8
                      ? const Duration(milliseconds: 360)
                      : Duration.zero,
                  curve: Curves.easeOut,
                  builder: (_, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, (1 - v) * 10),
                      child: child,
                    ),
                  ),
                  child: _AyahCard(
                    row: page.rows[i],
                    settings: settings,
                    isDark: isDark,
                    staggerIndex: i,
                  ),
                ),
              ),
            ),
          ),
        ),
        // bottom nav
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 36),
            child: _BottomNav(
              cur: cur, total: total,
              settings: settings, isDark: isDark,
              onPrev: onPrev, onNext: onNext,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav bar
// ─────────────────────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.cur, required this.total,
    required this.page, required this.settings, required this.isDark,
    required this.onPrev, required this.onNext,
    required this.onHome, required this.onSettings,
  });
  final int cur, total;
  final SurahPageResponse page;
  final ReaderSettings settings;
  final bool isDark;
  final VoidCallback? onPrev, onNext, onHome, onSettings;

  String get _displayName {
    final idx = cur - 1;
    if (settings.language == AppLanguage.indonesian && idx < surahNamesId.length)
      return surahNamesId[idx];
    return page.englishName;
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _NavBtn(icon: Icons.home_rounded,          isDark: isDark, onTap: onHome),
      const SizedBox(width: 8),
      _NavBtn(icon: Icons.chevron_left_rounded,  isDark: isDark,
          onTap: onPrev, disabled: onPrev == null),
      const SizedBox(width: 8),
      Expanded(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
            child: Text(_displayName,
              key: ValueKey(cur),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins', fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.darkText : AppTheme.green900,
              ),
            ),
          ),
          Text('$cur / $total',
            style: TextStyle(
              fontFamily: 'Poppins', fontSize: 10,
              color: isDark ? AppTheme.darkSubtext : AppTheme.green900op40,
            ),
          ),
        ],
      )),
      const SizedBox(width: 8),
      _NavBtn(icon: Icons.chevron_right_rounded, isDark: isDark,
          onTap: onNext, disabled: onNext == null),
      const SizedBox(width: 8),
      _NavBtn(icon: Icons.tune_rounded, isDark: isDark,
          onTap: onSettings, accent: true),
    ]);
  }
}

/// Nav button — PressScale (TweenAnimationBuilder, no controller)
class _NavBtn extends StatelessWidget {
  const _NavBtn({
    required this.icon, required this.isDark, required this.onTap,
    this.disabled = false, this.accent = false,
  });
  final IconData icon;
  final bool isDark, disabled, accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = accent
        ? AppTheme.green700
        : disabled
            ? (isDark ? AppTheme.darkSurface  : const Color(0xFFF5F5F5))
            : (isDark ? AppTheme.darkCard     : Colors.white);
    final Color fg = accent
        ? Colors.white
        : disabled
            ? (isDark ? AppTheme.darkBorder  : const Color(0xFFCCCCCC))
            : (isDark ? AppTheme.darkSubtext : AppTheme.green800);
    final Color bd = accent
        ? AppTheme.green700
        : disabled
            ? (isDark ? AppTheme.darkBorder  : const Color(0xFFDDDDDD))
            : (isDark ? AppTheme.darkBorder  : AppTheme.green900op08);

    return PressScale(
      onTap: disabled ? null : onTap,
      enabled: !disabled,
      scale: 0.87,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bd),
          boxShadow: accent
              ? const [BoxShadow(
                  color: AppTheme.green800op30,
                  blurRadius: 8, offset: Offset(0, 3))]
              : const [],
        ),
        child: Icon(icon, size: 18, color: fg),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero card
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.cur, required this.page,
    required this.settings, required this.isDark,
  });
  final int cur;
  final SurahPageResponse page;
  final ReaderSettings settings;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final idx     = cur - 1;
    final isId    = settings.language == AppLanguage.indonesian;
    final trans   = isId && idx < surahTranslationsId.length
        ? surahTranslationsId[idx] : page.englishNameTranslation;
    final isMakki = page.revelationType.toLowerCase() == 'meccan';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF065F46), Color(0xFF064E3B)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(
          color: AppTheme.green900op30, blurRadius: 18, offset: Offset(0, 7))],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
          child: Text(page.name,
            key: ValueKey(cur),
            textAlign: TextAlign.center,
            style: AppTheme.arabicHero,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
          child: Text(trans,
            key: ValueKey('$cur-$trans'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppTheme.white75, height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(height: 1, color: AppTheme.white15),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8, runSpacing: 6,
          children: [
            _MetaPill(
              icon: Icons.place_outlined,
              label: isMakki ? 'Makkiyah' : 'Madaniyah',
              color: isMakki ? const Color(0xFFB2F5EA) : const Color(0xFFFEF3C7),
            ),
            _MetaPill(
              icon: Icons.format_list_numbered_rounded,
              label: '${page.numberOfAyahs} Ayat',
              color: AppTheme.white75,
            ),
            _MetaPill(
              icon: Icons.translate_rounded,
              label: settings.language.fullLabel,
              color: AppTheme.white75,
            ),
          ],
        ),
      ]),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon, required this.label, required this.color});
  final IconData icon; final String label; final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: const BoxDecoration(
      color: AppTheme.white12,
      borderRadius: BorderRadius.all(Radius.circular(99)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 5),
      Text(label,
        style: AppTheme.pillLabel.copyWith(color: color, fontSize: 10)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bismillah
// ─────────────────────────────────────────────────────────────────────────────

class _BismillahCard extends StatelessWidget {
  const _BismillahCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    decoration: BoxDecoration(
      color: isDark ? AppTheme.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.green900op06),
    ),
    child: Text(
      'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
      textAlign: TextAlign.center,
      style: isDark ? AppTheme.arabicBismillahDark : AppTheme.arabicBismillah,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Ayah card
// • Press highlight via setState (no AnimationController)
// • staggerIndex only used if < 8; beyond that no animation
// ─────────────────────────────────────────────────────────────────────────────

class _AyahCard extends StatefulWidget {
  const _AyahCard({
    required this.row, required this.settings,
    required this.isDark, required this.staggerIndex,
  });
  final AyahRow row;
  final ReaderSettings settings;
  final bool isDark;
  final int staggerIndex;

  @override
  State<_AyahCard> createState() => _AyahCardState();
}

class _AyahCardState extends State<_AyahCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.isDark;
    final s = widget.settings;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown:  (_) => setState(() => _pressed = true),
      onTapUp:    (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: _pressed
              ? (d ? AppTheme.darkElevated : const Color(0xFFF4FCF8))
              : (d ? AppTheme.darkCard     : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _pressed
                ? (d ? AppTheme.accentop20 : AppTheme.accentop10)
                : (d ? AppTheme.darkBorder : AppTheme.green900op06),
            width: _pressed ? 1.5 : 1,
          ),
          boxShadow: [BoxShadow(
            color: d ? Colors.black26 : AppTheme.green900op06,
            blurRadius: _pressed ? 3 : 9,
            offset: _pressed ? const Offset(0, 1) : const Offset(0, 3),
          )],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── number row ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(children: [
                Container(
                  width: 34, height: 34,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${widget.row.numberInSurah}',
                    style: AppTheme.ayahBadgeNumber,
                  ),
                ),
                const Spacer(),
                Text('Ayat ${widget.row.numberInSurah}',
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 10,
                    fontWeight: FontWeight.w500, letterSpacing: 0.3,
                    color: d ? AppTheme.darkSubtext : AppTheme.green900op40,
                  ),
                ),
              ]),
            ),
            // ── arabic ──────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: d ? AppTheme.darkElevated : const Color(0xFFF0FDF9),
                border: Border.symmetric(horizontal: BorderSide(
                    color: d ? AppTheme.darkBorder : AppTheme.green900op06)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Text(
                widget.row.arabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                softWrap: true,
                style: d ? AppTheme.arabicAyahDark : AppTheme.arabicAyah,
              ),
            ),
            // ── latin ────────────────────────────────────────────────────
            if (s.showLatin && widget.row.latin.isNotEmpty)
              _SubBlock(
                label: 'LATIN', text: widget.row.latin,
                isDark: d, isItalic: true,
                showDivider:
                    s.showTranslation && widget.row.translation.isNotEmpty,
                accent: d
                    ? AppTheme.accentLight.withOpacity(.7)
                    : AppTheme.green600.withOpacity(.65),
                textColor: d ? AppTheme.darkSubtext : AppTheme.green900op40,
              ),
            // ── translation ──────────────────────────────────────────────
            if (s.showTranslation && widget.row.translation.isNotEmpty)
              _SubBlock(
                label: s.language == AppLanguage.indonesian
                    ? 'TERJEMAHAN' : 'TRANSLATION',
                text: widget.row.translation,
                isDark: d, isItalic: false, showDivider: false,
                accent: d ? AppTheme.accentLight : AppTheme.green600,
                textColor: d ? AppTheme.darkText : AppTheme.green900op85,
              ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _SubBlock extends StatelessWidget {
  const _SubBlock({
    required this.label, required this.text, required this.isDark,
    required this.isItalic, required this.showDivider,
    required this.accent, required this.textColor,
  });
  final String label, text;
  final bool isDark, isItalic, showDivider;
  final Color accent, textColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
    decoration: showDivider
        ? BoxDecoration(border: Border(bottom: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.green900op06)))
        : null,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 3, height: 12,
          decoration: BoxDecoration(
            color: accent, borderRadius: BorderRadius.circular(99)),
        ),
        const SizedBox(width: 7),
        Text(label, style: AppTheme.sectionLabel.copyWith(color: accent)),
      ]),
      const SizedBox(height: 6),
      Text(text, softWrap: true, style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: isItalic ? 13 : 14,
        height:    isItalic ? 1.9 : 1.8,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        color: textColor, letterSpacing: 0.1,
      )),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom navigation prev / next
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.cur, required this.total,
    required this.settings, required this.isDark,
    required this.onPrev, required this.onNext,
  });
  final int cur, total;
  final ReaderSettings settings;
  final bool isDark;
  final VoidCallback? onPrev, onNext;

  String _name(int n) {
    final idx = n - 1;
    if (settings.language == AppLanguage.indonesian &&
        idx < surahNamesId.length) return surahNamesId[idx];
    return 'Surah $n';
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: isDark ? AppTheme.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.green900op06),
    ),
    padding: const EdgeInsets.all(4),
    child: Row(children: [
      Expanded(child: _BottomBtn(
        icon: Icons.chevron_left_rounded,
        label: onPrev != null ? _name(cur - 1) : '–',
        sublabel: 'Sebelumnya',
        enabled: onPrev != null,
        isDark: isDark, onTap: onPrev, iconLeft: true,
      )),
      Container(
        width: 1, height: 38,
        color: isDark ? AppTheme.darkBorder : AppTheme.green900op06,
      ),
      Expanded(child: _BottomBtn(
        icon: Icons.chevron_right_rounded,
        label: onNext != null ? _name(cur + 1) : '–',
        sublabel: 'Berikutnya',
        enabled: onNext != null,
        isDark: isDark, onTap: onNext, iconLeft: false,
      )),
    ]),
  );
}

/// Bottom button — PressScale (no AnimationController)
class _BottomBtn extends StatelessWidget {
  const _BottomBtn({
    required this.icon, required this.label, required this.sublabel,
    required this.enabled, required this.isDark,
    required this.onTap, required this.iconLeft,
  });
  final IconData icon; final String label, sublabel;
  final bool enabled, isDark, iconLeft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = enabled
        ? (isDark ? AppTheme.darkText    : AppTheme.green900)
        : (isDark ? AppTheme.darkBorder  : const Color(0xFFCCCCCC));
    final sub = enabled
        ? (isDark ? AppTheme.darkSubtext : AppTheme.green900op40)
        : (isDark ? AppTheme.darkBorder  : const Color(0xFFDDDDDD));

    final textCol = Column(
      crossAxisAlignment: iconLeft
          ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(sublabel, style: TextStyle(
          fontFamily: 'Poppins', fontSize: 9,
          color: sub, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(label,
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
              fontWeight: FontWeight.w600, color: fg)),
      ],
    );

    return PressScale(
      onTap: onTap, enabled: enabled, scale: 0.96,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: iconLeft
            ? Row(children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 4),
                Flexible(child: textCol),
              ])
            : Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Flexible(child: textCol),
                const SizedBox(width: 4),
                Icon(icon, size: 18, color: fg),
              ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsSheet extends ConsumerWidget {
  const _SettingsSheet({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings  = ref.watch(readerSettingsProvider);
    final notifier  = ref.read(readerSettingsProvider.notifier);
    final dark      = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: dark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: dark ? AppTheme.darkBorder : AppTheme.green900op06),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(dark ? .4 : .1),
          blurRadius: 30, offset: const Offset(0, -4),
        )],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // handle
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: dark ? AppTheme.darkBorder : AppTheme.green900op12,
              borderRadius: BorderRadius.circular(99)),
          )),
          const SizedBox(height: 18),
          // title
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.all(Radius.circular(10))),
              child: const Icon(Icons.tune_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Text('Pengaturan Tampilan',
              style: TextStyle(
                fontFamily: 'Poppins', fontSize: 16,
                fontWeight: FontWeight.w700,
                color: dark ? AppTheme.darkText : AppTheme.green900)),
          ]),

          const SizedBox(height: 22),
          _SheetLabel('BAHASA', dark),
          const SizedBox(height: 10),

          Row(children: [
            Expanded(child: _LangOption(
              label: 'English', sublabel: 'Muhammad Asad',
              active: settings.language == AppLanguage.english,
              isDark: dark,
              onTap: () => notifier.state =
                  settings.copyWith(language: AppLanguage.english),
            )),
            const SizedBox(width: 8),
            Expanded(child: _LangOption(
              label: 'Indonesia', sublabel: 'Kemenag RI',
              active: settings.language == AppLanguage.indonesian,
              isDark: dark,
              onTap: () => notifier.state =
                  settings.copyWith(language: AppLanguage.indonesian),
            )),
          ]),

          const SizedBox(height: 20),
          _SheetLabel('KONTEN', dark),
          const SizedBox(height: 10),

          _ToggleRow(
            icon: Icons.abc_rounded,
            label: 'Transliterasi Latin',
            sublabel: 'Teks latin di bawah Arab',
            value: settings.showLatin, isDark: dark,
            onChanged: (v) =>
                notifier.state = settings.copyWith(showLatin: v),
          ),
          const SizedBox(height: 8),
          _ToggleRow(
            icon: Icons.translate_rounded,
            label: 'Terjemahan',
            sublabel: 'Tampilkan terjemahan ayat',
            value: settings.showTranslation, isDark: dark,
            onChanged: (v) =>
                notifier.state = settings.copyWith(showTranslation: v),
          ),

          const SizedBox(height: 20),
          _SheetLabel('TAMPILAN', dark),
          const SizedBox(height: 10),

          _ToggleRow(
            icon: dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            label:    dark ? 'Mode Terang' : 'Mode Gelap',
            sublabel: dark
                ? 'Beralih ke tampilan terang'
                : 'Beralih ke tampilan gelap',
            value: dark, isDark: dark,
            onChanged: (v) =>
                ref.read(themeModeProvider.notifier).state =
                    v ? ThemeMode.dark : ThemeMode.light,
          ),
        ],
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.label, this.isDark);
  final String label; final bool isDark;
  @override
  Widget build(BuildContext context) => Text(label,
    style: TextStyle(
      fontFamily: 'Poppins', fontSize: 10,
      fontWeight: FontWeight.w700, letterSpacing: 1.0,
      color: isDark ? AppTheme.darkSubtext : AppTheme.green900op40,
    ),
  );
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.label, required this.sublabel,
    required this.active, required this.isDark, required this.onTap,
  });
  final String label, sublabel;
  final bool active, isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PressScale(
    onTap: onTap, scale: 0.95,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active
            ? (isDark ? AppTheme.accentop20 : AppTheme.accentop10)
            : (isDark ? AppTheme.darkElevated : const Color(0xFFF9F9F9)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? AppTheme.green700
              : (isDark ? AppTheme.darkBorder : AppTheme.green900op08),
          width: active ? 1.5 : 1,
        ),
      ),
      child: Row(children: [
        Icon(
          active
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_off_rounded,
          size: 16,
          color: active ? AppTheme.green700
              : (isDark ? AppTheme.darkSubtext : AppTheme.green900op40),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600,
            color: active
                ? (isDark ? AppTheme.accentLight : AppTheme.green800)
                : (isDark ? AppTheme.darkText    : AppTheme.green900))),
          Text(sublabel, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 10,
            color: isDark ? AppTheme.darkSubtext : AppTheme.green900op40)),
        ])),
      ]),
    ),
  );
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon, required this.label, required this.sublabel,
    required this.value, required this.isDark, required this.onChanged,
  });
  final IconData icon; final String label, sublabel;
  final bool value, isDark; final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final d = isDark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: value
            ? (d ? AppTheme.accentop20 : AppTheme.accentop10)
            : (d ? AppTheme.darkElevated : const Color(0xFFF9F9F9)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? AppTheme.green700
              : (d ? AppTheme.darkBorder : AppTheme.green900op06),
          width: value ? 1.5 : 1,
        ),
      ),
      child: Row(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: value ? AppTheme.green700
                : (d ? AppTheme.darkCard : Colors.white),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: value ? AppTheme.green700
                : (d ? AppTheme.darkBorder : AppTheme.green900op08)),
          ),
          child: Icon(icon, size: 16,
            color: value ? Colors.white
                : (d ? AppTheme.darkSubtext : AppTheme.green900op40)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600,
            color: d ? AppTheme.darkText : AppTheme.green900)),
          Text(sublabel, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 10,
            color: d ? AppTheme.darkSubtext : AppTheme.green900op40)),
        ])),
        Switch(
          value: value, onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppTheme.green700,
          inactiveThumbColor:
              d ? AppTheme.darkSubtext : const Color(0xFFBBBBBB),
          inactiveTrackColor:
              d ? AppTheme.darkElevated : const Color(0xFFEEEEEE),
          trackOutlineColor:
              WidgetStateProperty.all(Colors.transparent),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.isDark, required this.label,
    required this.detail, required this.onRetry,
  });
  final bool isDark; final String label, detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.wifi_off_rounded, size: 52,
        color: isDark ? AppTheme.darkSubtext : AppTheme.green900op40),
      const SizedBox(height: 16),
      Text(label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(detail,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 24),
      PressScale(
        onTap: onRetry, scale: 0.94,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 13),
          decoration: BoxDecoration(
            gradient: AppTheme.accentGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(
              color: AppTheme.green800op30,
              blurRadius: 12, offset: Offset(0, 4))],
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
            SizedBox(width: 8),
            Text('Coba Lagi', style: TextStyle(
              fontFamily: 'Poppins', fontSize: 14,
              fontWeight: FontWeight.w600, color: Colors.white)),
          ]),
        ),
      ),
    ]),
  ));
}