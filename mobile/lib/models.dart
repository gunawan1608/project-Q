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

  factory SurahSummary.fromJson(Map<String, dynamic> json) {
    return SurahSummary(
      number: (json['number'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      englishName: (json['englishName'] as String?) ?? '',
      englishNameTranslation: (json['englishNameTranslation'] as String?) ?? '',
      numberOfAyahs: (json['numberOfAyahs'] as num?)?.toInt() ?? 0,
      revelationType: (json['revelationType'] as String?) ?? '',
    );
  }
}

class Ayah {
  final int numberInSurah;
  final String text;

  const Ayah({
    required this.numberInSurah,
    required this.text,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      numberInSurah: (json['numberInSurah'] as num?)?.toInt() ?? 0,
      text: (json['text'] as String?) ?? '',
    );
  }
}

class SurahDetail {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;
  final List<Ayah> ayahs;

  const SurahDetail({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.ayahs,
  });

  factory SurahDetail.fromJson(Map<String, dynamic> json) {
    final ayahsJson = (json['ayahs'] as List?) ?? const [];
    return SurahDetail(
      number: (json['number'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      englishName: (json['englishName'] as String?) ?? '',
      englishNameTranslation: (json['englishNameTranslation'] as String?) ?? '',
      revelationType: (json['revelationType'] as String?) ?? '',
      numberOfAyahs: (json['numberOfAyahs'] as num?)?.toInt() ?? 0,
      ayahs: ayahsJson
          .whereType<Map<String, dynamic>>()
          .map(Ayah.fromJson)
          .toList(growable: false),
    );
  }
}

class SurahPageResponse {
  final SurahDetail arabic;
  final SurahDetail translation;
  final String edition;

  const SurahPageResponse({
    required this.arabic,
    required this.translation,
    required this.edition,
  });

  factory SurahPageResponse.fromJson(Map<String, dynamic> json) {
    final arabicData = (json['arabic'] as Map<String, dynamic>?) ?? const {};
    final translationData = (json['translation'] as Map<String, dynamic>?) ?? const {};

    return SurahPageResponse(
      arabic: SurahDetail.fromJson((arabicData['data'] as Map<String, dynamic>?) ?? const {}),
      translation: SurahDetail.fromJson((translationData['data'] as Map<String, dynamic>?) ?? const {}),
      edition: (json['edition'] as String?) ?? 'en.asad',
    );
  }
}
