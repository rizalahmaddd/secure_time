# Secure Time Flutter Package

`secure_time` adalah package Flutter untuk mendapatkan waktu yang aman dan dapat diandalkan meskipun pengguna mengubah waktu di perangkat mereka. Package ini mengambil waktu dari server ketika aplikasi dijalankan, dan menyinkronkan waktu setiap kali ada koneksi internet. Dengan menggunakan informasi waktu dari server dan `boot time` perangkat, package ini memastikan waktu tetap akurat.

## Fitur

- Mengambil waktu dari server setiap kali aplikasi dijalankan.
- Menyimpan waktu yang diambil dan `boot time` perangkat di SharedPreferences.
- Menyediakan metode untuk mendapatkan waktu yang aman meskipun pengguna mengubah pengaturan waktu perangkat.

## Instalasi

Untuk menginstal package ini, tambahkan dependensi berikut pada file `pubspec.yaml` Anda:

```yaml
dependencies:
  secure_time:
    git:
      url: https://github.com/rizalahmaddd/secure_time.git
```
