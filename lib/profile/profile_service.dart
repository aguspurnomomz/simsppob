import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Profile {
  final String email;
  final String firstName;
  final String lastName;
  final String profileImage;

  Profile({this.email, this.firstName, this.lastName, this.profileImage});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImage: json['profile_image'] ?? '',
    );
  }
}

class ProfileService {
  static Future<Profile> fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    //URL request
    final String apiUrl = 'https://take-home-test-api.nutech-integrasi.com/profile';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['status'] == 0) {
        return Profile.fromJson(responseData['data']);
      } else {
        throw Exception('Gagal memuat profil: ${responseData['message']}');
      }
    } else {
      throw Exception('Gagal memuat profil: ${response.statusCode}');
    }
  }
}
