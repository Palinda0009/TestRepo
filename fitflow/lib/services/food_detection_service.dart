import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FoodDetectionService {
  static const String apiUrl = "http://192.168.1.176:8000/predict/";

  static Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    try {
      print("📤 Sending Image to API: ${imageFile.path}");

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("📩 Response Code: ${response.statusCode}");
      print("📩 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        print("❌ API Error: ${response.body}");
        return {};
      }
    } catch (e) {
      print("⚠️ Exception: $e");
      return {};
    }
  }
}
