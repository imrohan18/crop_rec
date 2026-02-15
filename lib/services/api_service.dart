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
      crop: json["crop"],
      deficiency: Map<String, dynamic>.from(json["deficiency"]),
      fertilizers: List<String>.from(json["fertilizer_recommendation"]),
    );
  }
}

/// ================= API SERVICE =================
class ApiService {

  /// ✔ Chrome/Web → keep 127.0.0.1
  /// ✔ Android Emulator → use 10.0.2.2
  final String baseUrl = "http://127.0.0.1:8000";

  /// ---------- SAVE LOGIN ----------
  Future<void> _saveLogin(String token, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setInt("userId", userId);
  }

  /// ---------- GET TOKEN ----------
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /// ---------- GET USER ID ----------
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId");
  }

  /// ---------- CHECK LOGIN ----------
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// ---------- LOGOUT ----------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// ================= REGISTER =================
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

  /// ================= LOGIN =================
  /// RETURNS userId for navigation
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

      /// SAVE locally
      await _saveLogin(token, userId);

      return userId;

    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  /// ================= PREDICT =================
  Future<List<CropRecommendation>> predictCrop({
    required double n,
    required double p,
    required double k,
    required double temperature,
    required double humidity,
    required double ph,
  }) async {

    final token = await getToken();

    if (token == null) {
      throw Exception("User not logged in");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/predict"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
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

  /// ================= HISTORY =================
  Future<List<dynamic>> getHistory() async {

    final token = await getToken();

    if (token == null) {
      throw Exception("User not logged in");
    }

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
