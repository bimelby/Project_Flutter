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
- 📱 Desain responsif untuk semua perangka
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
foshmed/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── user.dart
|   |   ├── reminder.dart
|   |   ├── templet.dart
│   │   └── entry.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── entry_provider.dart
│   │   └── theme_provider.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── entry/
│   │   │   ├── add_entry_screen.dart
│   │   │   └── entry_detail_screen.dart
│   │   ├── profile_screen.dart
│   │   └── search_screen.dart
│   ├── widgets/
│   │   ├── glass_container.dart
│   │   ├── custom_button.dart
│   │   ├── mood_selector.dart
│   │   └── entry_card.dart
│   └── utils/
│       └── constants.dart
├── assets/
│   └── images/


   api/
   ├── config/
   │   └── database.php
   ├── register.php
   ├── login.php
   ├── entries.php
   ├── add_entry.php
   ├── update_entry.php
   ├── delete_entry.php
   └── uploads/
   |  ├── entries
   |  └── profiles
   
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
**Tertanda Muhammad Haikal Bima** _01 juni 2025_  
