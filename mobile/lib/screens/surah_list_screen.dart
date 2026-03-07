import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../language.dart';
import '../models.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/shared.dart';
import 'surah_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Root
// ─────────────────────────────────────────────────────────────────────────────

class SurahListScreen extends ConsumerWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: AppBackground(
        child: ref.watch(surahListProvider).when(
          data:    (s)  => _Body(surahs: s),
          loading: ()   => _LoadingView(isDark: isDark),
          error:   (e, _) => _ErrorView(
            message: 'Gagal memuat daftar surah',
            detail:  e.toString(),
            onRetry: () => ref.invalidate(surahListProvider),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading — single controller, pulsing text
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatefulWidget {
  const _LoadingView({required this.isDark});
  final bool isDark;
  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      FadeTransition(
        opacity: CurvedAnimation(parent: _c, curve: Curves.easeInOut),
        child: const Text('بِسْمِ اللَّهِ', style: TextStyle(
          fontFamily: 'Amiri', fontSize: 34, color: AppTheme.green700)),
      ),
      const SizedBox(height: 24),
      SizedBox(width: 24, height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: widget.isDark ? AppTheme.accentLight : AppTheme.green700,
        )),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.surahs});
  final List<SurahSummary> surahs;
  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body>
    with SingleTickerProviderStateMixin {
  final _searchCtrl  = TextEditingController();
  final _scrollCtrl  = ScrollController();
  final _searchFocus = FocusNode();
  bool  _showSearch  = false;

  // header entrance — one controller, disposed cleanly
  late final AnimationController _enter = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 550),
  )..forward();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _searchFocus.dispose();
    _enter.dispose();
    super.dispose();
  }

  List<SurahSummary> _filter(String q) {
    if (q.isEmpty) return widget.surahs;
    final lo = q.toLowerCase();
    return widget.surahs.where((s) {
      final idx = s.number - 1;
      final id  = idx < surahNamesId.length
          ? surahNamesId[idx].toLowerCase() : '';
      return s.englishName.toLowerCase().contains(lo) ||
          s.name.contains(lo) || id.contains(lo) ||
          s.number.toString() == lo;
    }).toList(growable: false);
  }

  void _toggleSearch() {
    HapticFeedback.lightImpact();
    setState(() {
      _showSearch = !_showSearch;
      if (_showSearch) {
        Future.delayed(const Duration(milliseconds: 220),
            () { if (mounted) _searchFocus.requestFocus(); });
      } else {
        _searchCtrl.clear();
        ref.read(searchQueryProvider.notifier).state = '';
        _searchFocus.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final query    = ref.watch(searchQueryProvider);
    final filtered = _filter(query);
    final isDark   = Theme.of(context).brightness == Brightness.dark;

    return Column(children: [
      // ── Top bar ─────────────────────────────────────────────────────────
      AnimatedBuilder(
        animation: _enter,
        builder: (_, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: _enter, curve: const Interval(0, .7, curve: Curves.easeOut)),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -.2), end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _enter,
              curve: const Interval(0, .7, curve: Curves.easeOutCubic))),
            child: child,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Row(children: [
            // Logo — static, no controller needed
            Container(
              width: 42, height: 42,
              decoration: const BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.all(Radius.circular(13)),
              ),
              alignment: Alignment.center,
              child: const Text('ق', style: TextStyle(
                fontFamily: 'Amiri', fontSize: 24,
                color: Colors.white, height: 1)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Al-Qur'an", style: TextStyle(
                fontFamily: 'Poppins', fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.darkText : AppTheme.green900,
                height: 1.2)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (c, a) =>
                    FadeTransition(opacity: a, child: c),
                child: Text(
                  query.isNotEmpty
                      ? '${filtered.length} hasil'
                      : '${widget.surahs.length} Surah',
                  key: ValueKey(query.isNotEmpty),
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                      color: isDark
                          ? AppTheme.darkSubtext : AppTheme.green900op40),
                ),
              ),
            ])),
            _TopBtn(
              icon: _showSearch ? Icons.close_rounded : Icons.search_rounded,
              isDark: isDark, active: _showSearch, onTap: _toggleSearch),
            const SizedBox(width: 8),
            _TopBtn(
              icon: isDark
                  ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              isDark: isDark,
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(themeModeProvider.notifier).state =
                    isDark ? ThemeMode.light : ThemeMode.dark;
              }),
          ]),
        ),
      ),

      // ── Search bar — ClipRect prevents overflow when height == 0 ────────
      AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        height: _showSearch ? 60 : 0,
        child: ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: _SearchField(
                  ctrl: _searchCtrl, focus: _searchFocus, isDark: isDark,
                  onChanged: (v) =>
                      ref.read(searchQueryProvider.notifier).state = v,
                ),
              ),
            ),
          ),
        ),
      ),

      const SizedBox(height: 12),

      // ── Hero banner — collapses via AnimatedSize ─────────────────────────
      AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: (_showSearch && query.isNotEmpty)
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: const _HeroBanner(),
              ),
      ),

      // ── Section label ────────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
        child: Row(children: [
          Container(
            width: 3, height: 14,
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(99)),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (c, a) =>
                FadeTransition(opacity: a, child: c),
            child: Text(
              query.isNotEmpty ? '${filtered.length} hasil' : 'Semua Surah',
              key: ValueKey(query.isEmpty),
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                  fontWeight: FontWeight.w600, letterSpacing: 0.6,
                  color: isDark
                      ? AppTheme.darkSubtext : AppTheme.green900op40),
            ),
          ),
        ]),
      ),

      // ── List ─────────────────────────────────────────────────────────────
      Expanded(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (c, a) =>
              FadeTransition(opacity: a, child: c),
          child: (filtered.isEmpty && query.isNotEmpty)
              ? _EmptySearch(isDark: isDark, query: query)
              : _SurahList(
                  key: ValueKey(query),
                  surahs:     filtered,
                  totalCount: widget.surahs.length,
                  isDark:     isDark,
                  scrollCtrl: _scrollCtrl,
                ),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List — extracted to avoid full Column rebuilds on each keystroke
// ─────────────────────────────────────────────────────────────────────────────

class _SurahList extends StatelessWidget {
  const _SurahList({
    super.key,
    required this.surahs,
    required this.totalCount,
    required this.isDark,
    required this.scrollCtrl,
  });
  final List<SurahSummary> surahs;
  final int  totalCount;
  final bool isDark;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller:  scrollCtrl,
      padding:     const EdgeInsets.fromLTRB(20, 0, 20, 40),
      itemCount:   surahs.length,
      cacheExtent: 800, // pre-build items just off screen
      itemBuilder: (ctx, i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _SurahCard(
          surah:        surahs[i],
          isDark:       isDark,
          staggerIndex: i,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(ctx).push(SlidePageRoute(
              child: SurahDetailScreen(
                surahNumber: surahs[i].number,
                totalSurahs: totalCount,
              ),
            ));
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top icon button — no state needed
// ─────────────────────────────────────────────────────────────────────────────

class _TopBtn extends StatelessWidget {
  const _TopBtn({
    required this.icon,   required this.isDark,
    required this.onTap,  this.active = false,
  });
  final IconData icon; final bool isDark, active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PressScale(
    onTap: onTap, scale: 0.87,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: active
            ? (isDark ? AppTheme.accentop20 : AppTheme.accentop10)
            : (isDark ? AppTheme.darkCard   : Colors.white),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: active ? AppTheme.green700
              : (isDark ? AppTheme.darkBorder : AppTheme.green900op08),
          width: active ? 1.5 : 1,
        ),
        boxShadow: const [BoxShadow(
          color: AppTheme.green900op06, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Icon(icon, size: 18,
          color: active ? AppTheme.green700
              : (isDark ? AppTheme.darkSubtext : AppTheme.green800)),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Search field
// ─────────────────────────────────────────────────────────────────────────────

class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.ctrl,  required this.focus,
    required this.isDark, required this.onChanged,
  });
  final TextEditingController ctrl;
  final FocusNode focus;
  final bool isDark;
  final ValueChanged<String> onChanged;
  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focus.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() => _focused = widget.focus.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 46,
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused ? AppTheme.green700
              : (widget.isDark ? AppTheme.darkBorder : AppTheme.green900op08),
          width: _focused ? 1.5 : 1,
        ),
        boxShadow: _focused ? [BoxShadow(
          color: AppTheme.green700.withOpacity(.13),
          blurRadius: 10, offset: const Offset(0, 3),
        )] : const [],
      ),
      child: Row(children: [
        const SizedBox(width: 14),
        Icon(Icons.search_rounded, size: 18,
            color: _focused ? AppTheme.green700
                : (widget.isDark ? AppTheme.darkSubtext : AppTheme.green900op40)),
        const SizedBox(width: 10),
        Expanded(child: TextField(
          controller: widget.ctrl,
          focusNode:  widget.focus,
          onChanged:  widget.onChanged,
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
              color: widget.isDark ? AppTheme.darkText : AppTheme.green900),
          decoration: InputDecoration(
            hintText:  'Cari nama atau nomor surah...',
            hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                color: widget.isDark
                    ? AppTheme.darkSubtext : AppTheme.green900op40),
            border: InputBorder.none, isDense: true,
          ),
        )),
        // clear button — no state, just ValueListenableBuilder
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.ctrl,
          builder: (_, val, __) => val.text.isEmpty
              ? const SizedBox.shrink()
              : GestureDetector(
                  onTap: () { widget.ctrl.clear(); widget.onChanged(''); },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.close_rounded, size: 16,
                        color: widget.isDark
                            ? AppTheme.darkSubtext : AppTheme.green900op40),
                  ),
                ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero banner — fully const, zero rebuilds
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF065F46), Color(0xFF064E3B)],
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [BoxShadow(
        color: AppTheme.green900op30, blurRadius: 20, offset: Offset(0, 8))],
    ),
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
    child: const Column(children: [
      Text('بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Amiri', fontSize: 26, height: 2.0,
            color: Colors.white, letterSpacing: 0.5)),
      SizedBox(height: 2),
      Text('In the name of Allah, the Most Gracious, the Most Merciful',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
            color: AppTheme.white75,
            fontStyle: FontStyle.italic, height: 1.5)),
      SizedBox(height: 16),
      Divider(color: AppTheme.white15, height: 1),
      SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Pill(icon: Icons.menu_book_rounded, label: '114 Surah'),
        SizedBox(width: 8),
        _Pill(icon: Icons.translate_rounded, label: 'EN / ID'),
        SizedBox(width: 8),
        _Pill(icon: Icons.abc_rounded,       label: 'Latin'),
      ]),
    ]),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon; final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: const BoxDecoration(color: AppTheme.white15,
        borderRadius: BorderRadius.all(Radius.circular(99))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppTheme.white90),
      const SizedBox(width: 5),
      Text(label, style: AppTheme.pillLabel.copyWith(color: AppTheme.white90)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Surah card
// • Stagger entrance: TweenAnimationBuilder — no extra controller per item
// • Press scale: PressScale widget
// • RepaintBoundary isolates each card's repaint layer
// ─────────────────────────────────────────────────────────────────────────────

class _SurahCard extends StatelessWidget {
  const _SurahCard({
    required this.surah,
    required this.isDark,
    required this.staggerIndex,
    required this.onTap,
  });
  final SurahSummary surah;
  final bool         isDark;
  final int          staggerIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final idx     = surah.number - 1;
    final name    = idx < surahNamesId.length
        ? surahNamesId[idx] : surah.englishName;
    final trans   = idx < surahTranslationsId.length
        ? surahTranslationsId[idx] : surah.englishNameTranslation;
    final isMakki = surah.revelationType.toLowerCase() == 'meccan';
    final d       = isDark;

    // Only stagger the first 12 items; items beyond that start fully visible
    final delay = staggerIndex < 12
        ? Duration(milliseconds: staggerIndex * 25) : Duration.zero;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      // ignore: avoid_redundant_argument_values
      curve: Curves.easeOut,
      // delay hack: use a Future to start builder after delay
      // Actually: start with value=0, and we pad via key + didUpdateWidget
      // Simpler: just use a direct approach with the delay baked in
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 12),
          child: child,
        ),
      ),
      child: RepaintBoundary(
        child: PressScale(
          onTap:  onTap,
          scale:  0.968,
          downMs: 80,
          upMs:   220,
          child: _CardContent(
            surah: surah, name: name, trans: trans,
            isMakki: isMakki, isDark: d),
        ),
      ),
    );
  }
}

// Card content is a pure StatelessWidget — cheaply recreated
class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.surah,  required this.name,
    required this.trans,  required this.isMakki,
    required this.isDark,
  });
  final SurahSummary surah;
  final String name, trans;
  final bool isMakki, isDark;

  @override
  Widget build(BuildContext context) {
    final d = isDark;
    return Container(
      decoration: BoxDecoration(
        color: d ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: d ? AppTheme.darkBorder : AppTheme.green900op06),
        boxShadow: [BoxShadow(
          color: d ? Colors.black26 : AppTheme.green900op06,
          blurRadius: 8, offset: const Offset(0, 2),
        )],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        // badge
        Container(
          width: 44, height: 44,
          decoration: const BoxDecoration(
            gradient: AppTheme.accentGradient,
            borderRadius: BorderRadius.all(Radius.circular(13)),
          ),
          alignment: Alignment.center,
          child: Text('${surah.number}', style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 14,
            fontWeight: FontWeight.w700, color: Colors.white)),
        ),
        const SizedBox(width: 14),
        // info
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(fontFamily: 'Poppins', fontSize: 15,
              fontWeight: FontWeight.w600,
              color: d ? AppTheme.darkText : AppTheme.green900)),
          const SizedBox(height: 3),
          Text(trans, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                  color: d ? AppTheme.darkSubtext : AppTheme.green900op40)),
          const SizedBox(height: 6),
          Row(children: [
            _MiniTag(
                label: isMakki ? 'Makkiyah' : 'Madaniyah',
                isDark: d, isMakki: isMakki),
            const SizedBox(width: 6),
            Text('${surah.numberOfAyahs} Ayat',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 10,
                    color: d ? AppTheme.darkSubtext : AppTheme.green900op40)),
          ]),
        ])),
        const SizedBox(width: 8),
        // Arabic name
        Text(surah.name,
            style: d ? AppTheme.arabicListTileDark : AppTheme.arabicListTile),
      ]),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({
    required this.label, required this.isDark, required this.isMakki});
  final String label; final bool isDark, isMakki;

  @override
  Widget build(BuildContext context) {
    final Color bg = isDark
        ? (isMakki ? const Color(0x2210B981) : const Color(0x22F59E0B))
        : (isMakki ? AppTheme.accentop10     : const Color(0x1AF59E0B));
    final Color fg = isDark
        ? (isMakki ? AppTheme.accentLight : AppTheme.goldLight)
        : (isMakki ? AppTheme.green700    : const Color(0xFF92400E));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg,
          borderRadius: BorderRadius.circular(5)),
      child: Text(label, style: TextStyle(
        fontFamily: 'Poppins', fontSize: 9,
        fontWeight: FontWeight.w700, letterSpacing: 0.3, color: fg)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty search
// ─────────────────────────────────────────────────────────────────────────────

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.isDark, required this.query});
  final bool isDark; final String query;

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.search_off_rounded, size: 52,
          color: isDark ? AppTheme.darkBorder : AppTheme.green900op20),
      const SizedBox(height: 14),
      Text('Tidak ditemukan', style: TextStyle(
        fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600,
        color: isDark ? AppTheme.darkText : AppTheme.green900)),
      const SizedBox(height: 6),
      Text('"$query" tidak cocok dengan surah apapun',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
              color: isDark ? AppTheme.darkSubtext : AppTheme.green900op40)),
    ]),
  ));
}

// ─────────────────────────────────────────────────────────────────────────────
// Error
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message, required this.detail, required this.onRetry});
  final String message, detail; final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final d = Theme.of(context).brightness == Brightness.dark;
    return Center(child: Padding(padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.wifi_off_rounded, size: 52,
            color: d ? AppTheme.darkSubtext : AppTheme.green900op40),
        const SizedBox(height: 16),
        Text(message, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(detail, textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        PressScale(
          onTap: onRetry, scale: 0.94,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(14)),
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
}