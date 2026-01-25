import 'dart:convert';
import 'package:http/http.dart' as http;

// ---------------- MODEL ----------------
class CropRecommendation {
  final String crop;
  final Map<String, dynamic> deficiency;
  final List<String> fertilizers;

  CropRecommendation({
    required this.crop,
    required this.deficiency,
    required this.fertilizers,
  });

  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    return CropRecommendation(
      crop: json["crop"],
      deficiency: Map<String, dynamic>.from(json["deficiency"]),
      fertilizers:
          List<String>.from(json["fertilizer_recommendation"]),
    );
  }
}

// ---------------- API SERVICE ----------------
class ApiService {
  // Chrome / Flutter Web → OK
  // Android Emulator → use http://10.0.2.2:8000
  final String baseUrl = "http://127.0.0.1:8000";

  Future<List<CropRecommendation>> predictCrop({
    required double n,
    required double p,
    required double k,
    required double temperature,
    required double humidity,
    required double ph,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/predict"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "N": n,
        "P": p,
        "K": k,
        "Temperature": temperature,
        "Humidity": humidity,
        "pH": ph,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data["recommendations"];

      return list
          .map((e) => CropRecommendation.fromJson(e))
          .toList();
    } else {
      throw Exception("Prediction failed: ${response.body}");
    }
  }
}
