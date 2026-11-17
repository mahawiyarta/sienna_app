import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeoNamesConfig {
  static const String username = 'mahawiyarta';
}
class CityLocation {
  final int geoNameId;
  final String name;
  final String countryName;
  final String countryCode;
  const CityLocation({
    required this.geoNameId,
    required this.name,
    required this.countryName,
    required this.countryCode,
  });
  String get label => '$name, $countryName';
  factory CityLocation.fromJson(Map<String, dynamic> json) {
    return CityLocation(
      geoNameId: (json['geonameId'] as num).toInt(),
      name: (json['name'] as String).trim(),
      countryName: (json['countryName'] as String).trim(),
      countryCode: (json['countryCode'] as String).trim(),
    );
  }
}
class GeoNamesException implements Exception {
  final String message;
  const GeoNamesException(this.message);

  @override
  String toString() => message;
}
class GeoNamesService {
  static const int maxResults = 12;
  final Map<String, List<CityLocation>> _cache = {};

  Future<List<CityLocation>> searchCities(String text) async {
    final query = text.trim();
    if (query.length < 2) return const [];
    final cacheKey = query.toLowerCase();
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;
    if (GeoNamesConfig.username == 'ISI_USERNAME_GEONAMES' ||
        GeoNamesConfig.username.trim().isEmpty) {
      throw const GeoNamesException(
        'Username GeoNames belum diatur.',
      );
    }
    final uri = Uri.https('secure.geonames.org', '/searchJSON', {
      'name_startsWith': query,
      'featureClass': 'P',
      'maxRows': '$maxResults',
      'orderby': 'population',
      'lang': 'en',
      'username': GeoNamesConfig.username,
    });
    late final http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw const GeoNamesException(
        'Pencarian kota timeout. Coba kembali.',
      );
    } catch (error) {
      debugPrint(
        'GeoNames network error: $error',
      );
      throw const GeoNamesException(
        'Gagal terhubung ke GeoNames.',
      );
    }
    if (response.statusCode != 200) {
      throw GeoNamesException(
        'GeoNames HTTP ${response.statusCode}.',
      );
    }
    try {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const GeoNamesException(
          'Respons GeoNames tidak valid.',
        );
      }
      if (data['status'] is Map) {
        final status = data['status'] as Map;
        throw GeoNamesException(
          'GeoNames: ${status['message'] ?? 'Periksa username/kuota API.'}',
        );
      }
      final raw = data['geonames'];
      if (raw is! List) {
        throw const GeoNamesException(
          'Daftar kota tidak tersedia.',
        );
      }
      final result = <CityLocation>[];
      final seen = <int>{};
      for (final item in raw) {
        if (item is! Map<String, dynamic> ||
            item['geonameId'] is! num ||
            item['name'] is! String ||
            item['countryName'] is! String ||
            item['countryCode'] is! String) {
          continue;
        }
        final city = CityLocation.fromJson(item);
        if (city.name.toLowerCase().startsWith(cacheKey) &&
            city.name.isNotEmpty &&
            city.countryName.isNotEmpty &&
            seen.add(city.geoNameId)) {
          result.add(city);
        }
      }
      _cache[cacheKey] = result;
      return result;
    } on GeoNamesException {
      rethrow;
    } catch (error) {
      debugPrint(
        'GeoNames response parse error: $error',
      );
      throw const GeoNamesException(
        'Gagal membaca hasil pencarian kota.',
      );
    }
  }
}