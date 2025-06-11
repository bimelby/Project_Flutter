# 📱 Foshmed - Aplikasi Catatan Sederhana

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)

**Foshmed** adalah aplikasi catatan sederhana yang dibangun dengan Flutter, dirancang untuk membantu Anda mengelola catatan harian dengan antarmuka yang intuitif dan fitur-fitur esensial.

## ✨ Fitur Utama

- 🗒️ Buat, edit, dan hapus catatan dengan mudah
- 🔍 Pencarian cepat untuk menemukan catatan spesifik
- 🗂️ Kategorikan catatan dengan sistem label
- 🌙 Mode gelap untuk kenyamanan mata
- 🔐 Penyimpanan data aman dengan Firebase
- 📱 Desain responsif untuk semua perangkat
- ⚡ Sinkronisasi cloud antar perangkat
-  / Dan fitur lainnya

## 🖼️ Tampilan Aplikasi

| Tampilan Daftar Catatan | Tambah Catatan Baru | Mode Gelap |
|-------------------------|---------------------|------------|
| ![List View](https://via.placeholder.com/300x600/4f46e5/ffffff?text=Daftar+Catatan) | ![Add Note](https://via.placeholder.com/300x600/10b981/ffffff?text=Tambah+Catatan) | ![Dark Mode](https://via.placeholder.com/300x600/1e293b/ffffff?text=Mode+Gelap) |

## 🚀 Cara Memulai

### Prasyarat
- Flutter SDK (versi terbaru)
- Android Studio/VSCode dengan ekstensi Flutter
- Akun Firebase untuk backend

### Instalasi
1. Clone repositori ini:
```bash
git clone https://github.com/username/Project_Flutter.git
```

2. Masuk ke direktori proyek:
```bash
cd Project_Flutter
```

3. Install dependencies:
```bash
flutter pub get
```

4. Hubungkan dengan Firebase:
- Buat proyek Firebase baru
- Download file `google-services.json` untuk Android
- Letakkan di `android/app/google-services.json`

5. Jalankan aplikasi:
```bash
flutter run
```

## 🛠️ Struktur Proyek

```
lib/
├── main.dart          # Entry point aplikasi
├── models/            # Model data
│   └── note.dart
├── services/          # Layanan backend
│   └── firestore_service.dart
├── screens/           # Halaman aplikasi
│   ├── home_screen.dart
│   ├── note_editor.dart
│   └── settings_screen.dart
├── widgets/           # Komponen UI
│   ├── note_card.dart
│   └── search_bar.dart
└── utils/             # Utilities
    └── colors.dart
```

## 🤝 Berkontribusi

Kontribusi selalu diterima! Ikuti langkah berikut:
1. Fork proyek ini
2. Buat branch fitur baru (`git checkout -b fitur/namafitur`)
3. Commit perubahan Anda (`git commit -m 'Tambahkan fitur baru'`)
4. Push ke branch (`git push origin fitur/namafitur`)
5. Buat Pull Request

## 📜 Lisensi

Proyek ini dilisensikan di bawah [Lisensi MIT](LICENSE).

---

**Foshmed** © 2023 - Dibangun dengan ❤️ menggunakan Flutter
