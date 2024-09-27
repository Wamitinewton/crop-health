import 'dart:convert';

import 'package:farmshield/models/fertilizer.dart';
import 'package:http/http.dart' as http;

class FertilizerService {
  final String baseUrl;

  FertilizerService({required this.baseUrl});

  Future<String> getFertlizerRecommendations(FertilizerInput input) async {
    try {
      final response = await http.post(
          Uri.parse('$baseUrl/predict'),
          headers: {"Content-Type": "application/json"},
          body: json.encode(input.toJson()));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['prediction'];
      } else {
        throw HttpException(
            'Failed to get recommendation: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw HttpException('Network error: $e');
    } catch (e) {
      throw HttpException('Unexpected error: $e');
    }
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
