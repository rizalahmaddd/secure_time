library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_clock/system_clock.dart';

class SecureTime {
  static const String _timeKey = 'secure_time';
  static const String _bootTimeKey = 'secure_boot_time';

  /// Callback untuk sinkronisasi waktu dari server.
  /// Pengguna dapat mengoverride ini dengan server mereka sendiri.
  static Future<DateTime> Function()? syncTimeCallback;

  /// Sinkronkan waktu dari server.
  static Future<void> syncTime() async {
    if (syncTimeCallback != null) {
      // Gunakan callback sinkronisasi yang diatur oleh pengguna
      final serverTime = await syncTimeCallback!();
      final elapsedRealtime = SystemClock.elapsedRealtime();

      // Simpan waktu server dan boot time ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt(_timeKey, serverTime.millisecondsSinceEpoch);
      prefs.setInt(_bootTimeKey, elapsedRealtime.inMilliseconds);
    } else {
      // Gunakan sinkronisasi bawaan jika callback tidak diatur
      final serverTime = await _fetchTimeFromServer();
      final elapsedRealtime = SystemClock.elapsedRealtime();

      final prefs = await SharedPreferences.getInstance();
      prefs.setInt(_timeKey, serverTime.millisecondsSinceEpoch);
      prefs.setInt(_bootTimeKey, elapsedRealtime.inMilliseconds);
    }
  }

  /// Ambil waktu aman (secure time) saat ini.
  static Future<DateTime> getSecureTime() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt(_timeKey);
    final bootTime = prefs.getInt(_bootTimeKey);

    // Jika waktu belum diatur, coba sinkronisasi terlebih dahulu
    if (savedTime == null || bootTime == null) {
      try {
        await syncTime(); // Sinkronisasi waktu dari server
        // Setelah sinkronisasi, ulangi pengambilan waktu
        final updatedSavedTime = prefs.getInt(_timeKey);
        final updatedBootTime = prefs.getInt(_bootTimeKey);

        if (updatedSavedTime != null && updatedBootTime != null) {
          final currentBootTime = SystemClock.elapsedRealtime();
          final elapsedTime = currentBootTime.inMilliseconds - updatedBootTime;
          return DateTime.fromMillisecondsSinceEpoch(updatedSavedTime + elapsedTime);
        } else {
          throw Exception('Waktu aman tidak tersedia setelah sinkronisasi.');
        }
      } catch (e) {
        throw Exception('Gagal sinkronisasi waktu: $e');
      }
    }

    // Jika data tersedia, hitung secure time
    final currentBootTime = SystemClock.elapsedRealtime();
    final elapsedTime = currentBootTime.inMilliseconds - bootTime;

    return DateTime.fromMillisecondsSinceEpoch(savedTime + elapsedTime);
  }

  /// Sinkronisasi default: ambil waktu dari server melalui HTTP
  static Future<DateTime> _fetchTimeFromServer() async {
    try {
      final response = await http.get(Uri.parse('https://worldtimeapi.org/api/timezone/Etc/UTC'));

      if (response.statusCode == 200) {
        // Parsing waktu dari JSON
        final data = json.decode(response.body);
        final datetimeString = data['utc_datetime']; // Ambil waktu UTC dari respons
        return DateTime.parse(datetimeString);
      } else {
        throw Exception('Gagal mengambil waktu dari server.');
      }
    } catch (e) {
      throw Exception('Gagal mengambil waktu dari server: $e');
    }
  }
}
