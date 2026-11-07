# BookNest

Aplikasi mobile berbasis Flutter untuk membantu pengguna menemukan,
menyimpan, dan mengelola daftar buku pribadi. BookNest mengambil
informasi katalog buku dari Open Library, menyediakan fitur pencarian
interaktif, serta menyimpan data pengguna dan aktivitas pengguna
melalui Supabase.

## Identitas Pengembang

Nama I Komang Candra Aryadinata
NIM 2415051085
Kelas PTI 5A

## Fitur Aplikasi

Fitur utama BookNest meliputi:

1. Katalog Buku --- menampilkan daftar buku yang diperoleh dari
   Open Library.
2. Pencarian Buku --- mencari buku berdasarkan kata kunci dan
   menampilkan hasil pencarian.
3. Detail Buku --- menampilkan informasi buku, seperti judul,
   penulis, kategori, sampul, dan deskripsi jika tersedia.
4. My Library --- menambahkan dan menghapus buku dari daftar
   koleksi pribadi.
5. Target Membaca --- mengatur dan memantau target membaca.
6. User Profile --- menampilkan informasi profil pengguna.
7. Penyimpanan Data --- menyimpan data terkait pengguna dan koleksi
   buku pada backend Supabase.
8. Menandai Buku --- menandai buku yang ingin, sedang, dan sudah dibaca.

## Tech Stack

Teknologi Kegunaan
Flutter Framework pengembangan aplikasi mobile
Dart Bahasa pemrograman
Provider State management
HTTP Mengirim permintaan HTTP ke REST API
Supabase Flutter Integrasi aplikasi dengan layanan Supabase
Material Design Komponen dan sistem antarmuka aplikasi
Git & GitHub Version control dan penyimpanan repository

## REST API yang Digunakan

Open Library API
BookNest menggunakan Open Library API untuk memperoleh data katalog
buku.

- Dokumentasi API: https://openlibrary.org/developers/api
- Search API: https://openlibrary.org/search.json
- Works API: https://openlibrary.org/developers/api
- Cover API: https://covers.openlibrary.org/b/id/$rawCoverId-M.jpg
  API digunakan untuk: - Melakukan pencarian buku berdasarkan kata
  kunci. - Mengambil informasi judul dan penulis. - Mengambil kategori
  atau subjek buku jika tersedia. - Mengambil identitas buku dari Open
  Library. - Menampilkan gambar sampul buku jika tersedia. - Mengambil
  deskripsi karya berdasarkan Work ID jika tersedia.

## Backend dan Database

BookNest menggunakan Supabase sebagai backend dan database.

Layanan Supabase digunakan untuk: - Authentication: mengelola sesi
pengguna, termasuk autentikasi anonim. - PostgreSQL Database:
menyimpan data aplikasi yang berkaitan dengan pengguna, koleksi buku,
dan target membaca sesuai implementasi database. - Supabase Flutter
SDK: menghubungkan aplikasi Flutter dengan layanan Supabase.

Data katalog buku diperoleh dari Open Library API, sedangkan data
pengguna dan aktivitas yang disimpan aplikasi dikelola melalui Supabase.

## Struktur Arsitektur Aplikasi

BookNest menggunakan pemisahan tanggung jawab berdasarkan beberapa
lapisan, sehingga pengelolaan data, logika aplikasi, dan antarmuka
pengguna lebih terstruktur.

Alur umum pengambilan data:
Screen / Widget
|
v
Provider
|
v
Repository
|
v
Service
|
v
External API / Supabase

struktur direktori:
lib/
├── config/
├── models/
├── providers/
├── repositories/
├── screens/
├── services/
├── widgets/
└── main.dart

## Screenshoot Aplikasi

## Cara Menjalankan

1. Persyaratan
   Pastikan perangkat pengembangan telah memiliki: - Flutter SDK. - Dart
   SDK (termasuk dalam instalasi Flutter). - Android Studio atau Visual
   Studio Code. - Android SDK dan emulator, atau perangkat Android fisik. -
   Git.

Periksa instalasi Flutter:
flutter doctor

2. Clone Repository
   Clone repository BookNest dari GitHub:
   git clone [https://github.com/summerville-26/UTS_2415051085_I-Komang-Candra-Aryadinata]
   Masuk ke direktori project:
   cd [book_nest]

3. Install Dependencies
   Jalankan perintah:
   flutter pub get

4. Konfigurasi Supabase
   Pastikan konfigurasi Supabase yang diperlukan sudah tersedia pada
   project lokal. Jika aplikasi menggunakan file konfigurasi atau
   environment variable, siapkan file tersebut berdasarkan konfigurasi
   proyek masing-masing.

Jangan mengunggah kredensial rahasia ke repository publik.

5. Jalankan Aplikasi
   Hubungkan perangkat Android, jalankan emulator atau lewat browser, kemudian gunakan:
   flutter devices
   flutter run/flutter run -d chrome

6. Build APK
   Untuk membuat APK release:
   flutter build apk --release
   Hasil APK umumnya tersedia pada:
   build/app/outputs/flutter-apk/app-release.apk
