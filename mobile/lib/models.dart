class SurahSummary {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  const SurahSummary({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  static SurahSummary fromJson(Map<String, dynamic> json) => SurahSummary(
        number: (json['number'] as num).toInt(),
        name: (json['name'] as String?) ?? '',
        englishName: (json['englishName'] as String?) ?? '',
        englishNameTranslation:
            (json['englishNameTranslation'] as String?) ?? '',
        numberOfAyahs: (json['numberOfAyahs'] as num?)?.toInt() ?? 0,
        revelationType: (json['revelationType'] as String?) ?? '',
      );
}

class AyahRow {
  final int numberInSurah;
  final String arabic;
  final String latin;       
  final String translation; 

  const AyahRow({
    required this.numberInSurah,
    required this.arabic,
    required this.latin,
    required this.translation,
  });
}

class _RawAyah {
  final int numberInSurah;
  final String text;
  const _RawAyah(this.numberInSurah, this.text);

  factory _RawAyah.fromJson(Map<String, dynamic> j) => _RawAyah(
        (j['numberInSurah'] as num?)?.toInt() ?? 0,
        (j['text'] as String?) ?? '',
      );
}

List<_RawAyah> _parseAyahs(Map<String, dynamic>? data) {
  if (data == null) return const [];
  final list = (data['ayahs'] as List?) ?? const [];
  return list
      .whereType<Map<String, dynamic>>()
      .map(_RawAyah.fromJson)
      .toList(growable: false);
}

Map<String, dynamic> _dataOf(Map<String, dynamic>? wrapper) =>
    (wrapper?['data'] as Map<String, dynamic>?) ?? const {};

class SurahPageResponse {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;
  final String edition;

  final List<AyahRow> rows;

  const SurahPageResponse({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.edition,
    required this.rows,
  });

  static SurahPageResponse fromJson(Map<String, dynamic> json) {
    final arabicData   = _dataOf(json['arabic']          as Map<String, dynamic>?);
    final transData    = _dataOf(json['translation']      as Map<String, dynamic>?);
    final tlitData     = _dataOf(json['transliteration']  as Map<String, dynamic>?);

    final arabicAyahs  = _parseAyahs(arabicData);
    final transAyahs   = _parseAyahs(transData);
    final tlitAyahs    = _parseAyahs(tlitData);

    final count    = arabicAyahs.length;
    final transLen = transAyahs.length;
    final tlitLen  = tlitAyahs.length;

    final rows = List<AyahRow>.generate(count, (i) {
      return AyahRow(
        numberInSurah: arabicAyahs[i].numberInSurah,
        arabic:        arabicAyahs[i].text,
        latin:         i < tlitLen  ? tlitAyahs[i].text  : '',
        translation:   i < transLen ? transAyahs[i].text : '',
      );
    }, growable: false);

    return SurahPageResponse(
      number:                  (arabicData['number'] as num?)?.toInt() ?? 0,
      name:                    (arabicData['name'] as String?) ?? '',
      englishName:             (arabicData['englishName'] as String?) ?? '',
      englishNameTranslation:  (arabicData['englishNameTranslation'] as String?) ?? '',
      revelationType:          (arabicData['revelationType'] as String?) ?? '',
      numberOfAyahs:           (arabicData['numberOfAyahs'] as num?)?.toInt() ?? count,
      edition:                 (json['edition'] as String?) ?? 'en.asad',
      rows:                    rows,
    );
  }
}