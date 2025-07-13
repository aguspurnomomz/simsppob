import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BalanceService {
  static Future<double> fetchBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('https://take-home-test-api.nutech-integrasi.com/balance'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['data'] != null && responseBody['data']['balance'] != null) {
        return responseBody['data']['balance'].toDouble();
      } else {
        throw Exception('Gagal Mengambil Data');
      }
    } else {
      throw Exception('Gagal Mengambil Data');
    }
  }
}
