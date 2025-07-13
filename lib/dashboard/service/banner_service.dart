
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BannerService {
  final String bannerName;
  final String bannerImage;
  final String description;

  BannerService({this.bannerName, this.bannerImage, this.description});

  factory BannerService.fromJson(Map<String, dynamic> json) {
    return BannerService(
      bannerName: json['banner_name'],
      bannerImage: json['banner_image'],
      description: json['description'],
    );
  }
}

Future<List<BannerService>> fetchBanners() async {
  try {
    print('Fetching banners...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String bearerToken = prefs.getString('bearer_token');

    final headers = {
      'Authorization': 'Bearer $bearerToken',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse('https://take-home-test-api.nutech-integrasi.com/banner'),
      headers: headers,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    //TODO selalu dapat response code 108, check
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> banners = data['data'];
      return banners.map((json) => BannerService.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat banner: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    throw Exception('Gagal memuat banner: $e');
  }
}
