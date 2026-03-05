enum AppLanguage {
  english,
  indonesian;

  String get edition => this == AppLanguage.english ? 'en.asad' : 'id.indonesian';
  String get label   => this == AppLanguage.english ? 'EN' : 'ID';
  String get fullLabel => this == AppLanguage.english ? 'English' : 'Indonesia';
  AppStrings get strings => this == AppLanguage.english ? _en : _id;

  static const _en = AppStrings(
    bismillahTranslation: 'In the name of Allah, the Most Gracious, the Most Merciful',
    allSurahs: 'All Surahs',
    ayahLabel: 'Ayah',
    translationLabel: 'Translation',
    latinLabel: 'Latin',
    failedLoadList: 'Failed to load surah list',
    failedLoadDetail: 'Failed to load surah',
    retry: 'Retry',
    revelationMeccan: 'Meccan',
    revelationMedian: 'Medinan',
    ayahsCount: 'Ayahs',
  );

  static const _id = AppStrings(
    bismillahTranslation: 'Dengan nama Allah Yang Maha Pengasih lagi Maha Penyayang',
    allSurahs: 'Semua Surah',
    ayahLabel: 'Ayat',
    translationLabel: 'Terjemahan',
    latinLabel: 'Latin',
    failedLoadList: 'Gagal memuat daftar surah',
    failedLoadDetail: 'Gagal memuat surah',
    retry: 'Coba lagi',
    revelationMeccan: 'Makkiyah',
    revelationMedian: 'Madaniyah',
    ayahsCount: 'Ayat',
  );
}

class AppStrings {
  final String bismillahTranslation;
  final String allSurahs;
  final String ayahLabel;
  final String translationLabel;
  final String latinLabel;
  final String failedLoadList;
  final String failedLoadDetail;
  final String retry;
  final String revelationMeccan;
  final String revelationMedian;
  final String ayahsCount;

  const AppStrings({
    required this.bismillahTranslation,
    required this.allSurahs,
    required this.ayahLabel,
    required this.translationLabel,
    required this.latinLabel,
    required this.failedLoadList,
    required this.failedLoadDetail,
    required this.retry,
    required this.revelationMeccan,
    required this.revelationMedian,
    required this.ayahsCount,
  });
}

// Nama surah dalam bahasa Indonesia (index 0 = surah ke-1).
// Digunakan saat bahasa ID aktif menggantikan englishName dari API.
const List<String> surahNamesId = [
  'Al-Fatihah', 'Al-Baqarah', 'Ali Imran', 'An-Nisa', 'Al-Maidah',
  'Al-Anam', 'Al-Araf', 'Al-Anfal', 'At-Taubah', 'Yunus',
  'Hud', 'Yusuf', 'Ar-Rad', 'Ibrahim', 'Al-Hijr',
  'An-Nahl', 'Al-Isra', 'Al-Kahfi', 'Maryam', 'Ta Ha',
  'Al-Anbiya', 'Al-Hajj', 'Al-Muminun', 'An-Nur', 'Al-Furqan',
  'Asy-Syuara', 'An-Naml', 'Al-Qasas', 'Al-Ankabut', 'Ar-Rum',
  'Luqman', 'As-Sajdah', 'Al-Ahzab', 'Saba', 'Fatir',
  'Ya Sin', 'As-Saffat', 'Sad', 'Az-Zumar', 'Gafir',
  'Fussilat', 'Asy-Syura', 'Az-Zukhruf', 'Ad-Dukhan', 'Al-Jasiyah',
  'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujurat', 'Qaf',
  'Az-Zariyat', 'At-Tur', 'An-Najm', 'Al-Qamar', 'Ar-Rahman',
  'Al-Waqiah', 'Al-Hadid', 'Al-Mujadilah', 'Al-Hasyr', 'Al-Mumtahanah',
  'As-Saf', 'Al-Jumuah', 'Al-Munafiqun', 'At-Tagabun', 'At-Talaq',
  'At-Tahrim', 'Al-Mulk', 'Al-Qalam', 'Al-Haqqah', 'Al-Maarij',
  'Nuh', 'Al-Jin', 'Al-Muzzammil', 'Al-Muddassir', 'Al-Qiyamah',
  'Al-Insan', 'Al-Mursalat', 'An-Naba', 'An-Naziat', 'Abasa',
  'At-Takwir', 'Al-Infitar', 'Al-Mutaffifin', 'Al-Insyiqaq', 'Al-Buruj',
  'At-Tariq', 'Al-Ala', 'Al-Gasiyah', 'Al-Fajr', 'Al-Balad',
  'Asy-Syams', 'Al-Lail', 'Ad-Duha', 'Asy-Syarh', 'At-Tin',
  'Al-Alaq', 'Al-Qadr', 'Al-Bayyinah', 'Az-Zalzalah', 'Al-Adiyat',
  'Al-Qariah', 'At-Takasur', 'Al-Asr', 'Al-Humazah', 'Al-Fil',
  'Quraisy', 'Al-Maun', 'Al-Kausar', 'Al-Kafirun', 'An-Nasr',
  'Al-Masad', 'Al-Ikhlas', 'Al-Falaq', 'An-Nas',
];

// Terjemahan nama surah dalam bahasa Indonesia
const List<String> surahTranslationsId = [
  'Pembukaan', 'Sapi Betina', 'Keluarga Imran', 'Wanita', 'Hidangan',
  'Binatang Ternak', 'Tempat Tertinggi', 'Rampasan Perang', 'Pengampunan', 'Yunus',
  'Hud', 'Yusuf', 'Guruh', 'Ibrahim', 'Bukit Hijr',
  'Lebah', 'Perjalanan Malam', 'Gua', 'Maryam', 'Ta Ha',
  'Nabi-Nabi', 'Haji', 'Orang-Orang Mukmin', 'Cahaya', 'Pembeda',
  'Para Penyair', 'Semut', 'Kisah-Kisah', 'Laba-Laba', 'Bangsa Romawi',
  'Luqman', 'Sujud', 'Golongan-Golongan', 'Saba', 'Pencipta',
  'Ya Sin', 'Barisan', 'Sad', 'Rombongan', 'Pengampun',
  'Dijelaskan', 'Musyawarah', 'Perhiasan Emas', 'Kabut', 'Berlutut',
  'Bukit Pasir', 'Muhammad', 'Kemenangan', 'Kamar-Kamar', 'Qaf',
  'Angin yang Menerbangkan', 'Bukit Tur', 'Bintang', 'Bulan', 'Yang Maha Pemurah',
  'Hari Kiamat', 'Besi', 'Gugatan', 'Pengusiran', 'Wanita yang Diuji',
  'Satu Barisan', 'Jumat', 'Orang-Orang Munafik', 'Hari Penampakan', 'Talak',
  'Pengharaman', 'Kerajaan', 'Qalam', 'Hari Kiamat', 'Tempat-Tempat Naik',
  'Nuh', 'Jin', 'Orang yang Berselimut', 'Orang yang Berkemul', 'Kiamat',
  'Manusia', 'Yang Diutus', 'Berita Besar', 'Yang Mencabut', 'Bermuka Masam',
  'Menggulung', 'Terbelah', 'Orang yang Curang', 'Terbelah', 'Gugusan Bintang',
  'Yang Datang di Malam Hari', 'Yang Paling Tinggi', 'Hari Pembalasan', 'Fajar', 'Negeri',
  'Matahari', 'Malam', 'Waktu Dhuha', 'Melapangkan', 'Buah Tin',
  'Segumpal Darah', 'Kemuliaan', 'Bukti Nyata', 'Kegoncangan', 'Berlari Kencang',
  'Hari Kiamat', 'Bermegah-Megahan', 'Masa', 'Pengumpat', 'Gajah',
  'Suku Quraisy', 'Barang yang Berguna', 'Nikmat yang Berlimpah', 'Orang Kafir', 'Pertolongan',
  'Gejolak Api', 'Ikhlas', 'Waktu Subuh', 'Manusia',
];