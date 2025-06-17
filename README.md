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
- 🔐 Penyimpanan data aman dengan mysql
- 📱 Desain responsif untuk semua perangkat
- ⚡  Dan fitur lainny




## 🚀 Cara Memulai

### Prasyarat
- Flutter SDK (versi terbaru)
- Android Studio/VSCode dengan ekstensi Flutter
- Akun mysql dan api  untuk backend 

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

4. Jalankan aplikasi:
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
