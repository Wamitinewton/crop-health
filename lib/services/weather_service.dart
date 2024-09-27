import 'dart:convert';

import 'package:farmshield/models/weather_model.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  // ignore: constant_identifier_names
  static const BASE_URL = 'http://api.openweathermap.org/data/2.5/weather';
  static late SharedPreferences _prefs;
  final String apikey;
  WeatherService(this.apikey);

  static const String cacheKey = 'cachedWeatherData';
  Future<Weather> getWeather(String cityName) async {
    _prefs = await SharedPreferences.getInstance();

    // first chack whether there is cached data
    String? cachedData = _prefs.getString(cacheKey);
    if (cachedData != null) {
      final weatherData =
          Weather.fromJson(jsonDecode(cachedData) as Map<String, dynamic>);
      return weatherData;
    }
    final response = await http
        .get(Uri.parse('$BASE_URL?q=$cityName&appid=$apikey&units=metric'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      Weather weather = Weather.fromJson(jsonResponse);

      _prefs.setString(cacheKey, jsonEncode(jsonResponse));

      return weather;
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    String? city = placemarks[0].locality;
    return city ?? "";
  }
}
