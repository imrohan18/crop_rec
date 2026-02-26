import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ================= MODEL =================
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
      crop: json["crop"] ?? "",
      deficiency: Map<String, dynamic>.from(json["deficiency"] ?? {}),
      fertilizers:
          List<String>.from(json["fertilizer_recommendation"] ?? []),
    );
  }
}

/// ================= API SERVICE =================
class ApiService {

  final String baseUrl = "http://127.0.0.1:8000";

  Future<void> _saveLogin(String token, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setInt("userId", userId);
  }

  Future<void> setGuest(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("guest", value);
  }

  Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("guest") ?? false;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId");
  }

  Future<bool> isLoggedIn() async {
    final guest = await isGuest();
    if (guest) return true;
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("userId");
    await prefs.remove("guest");
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Register failed: ${response.body}");
    }
  }

  Future<int> login({
    required String email,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      final String token = data["token"];
      final int userId = data["user"]["id"];

      await _saveLogin(token, userId);

      return userId;

    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  Future<List<CropRecommendation>> predictCrop({
    required double n,
    required double p,
    required double k,
    required double temperature,
    required double humidity,
    required double ph,
    required String season,
  }) async {

    final guest = await isGuest();
    final token = await getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/predict"),
      headers: () {
        final h = {"Content-Type": "application/json"};
        if (!guest && token != null && token.isNotEmpty) {
          h["Authorization"] = "Bearer $token";
        }
        return h;
      }(),
      body: jsonEncode({
        "N": n,
        "P": p,
        "K": k,
        "Temperature": temperature,
        "Humidity": humidity,
        "pH": ph,
        "Season": season,
      }),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      final List list = data["recommendations"] ?? [];

      return list
          .map((e) => CropRecommendation.fromJson(e))
          .toList();

    } else {

      // helpful backend error message
      final msg = jsonDecode(response.body);
      throw Exception("Prediction failed: ${msg["detail"] ?? response.body}");
    }
  }

  Future<List<dynamic>> getHistory() async {

    final guest = await isGuest();
    if (guest) return [];
    final token = await getToken();
    if (token == null || token.isEmpty) return [];

    final response = await http.get(
      Uri.parse("$baseUrl/history"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("History load failed: ${response.body}");
    }
  }
}
