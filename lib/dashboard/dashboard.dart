import 'package:Nutech/dashboard/service/balance_service.dart';
import 'package:Nutech/menu/menu.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<double> futureBalance;

  Future<Map<String, dynamic>> _fetchProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login.');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('https://take-home-test-api.nutech-integrasi.com/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']; // Mengambil data dari response
      } else {
        throw Exception('Gagal mendapatkan profil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    futureBalance = BalanceService.fetchBalance();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeader(),
              SizedBox(height: 20),
              _buildBalance(),
              SizedBox(height: 20),
              Menu(),
              SizedBox(height: 20),
              _buildSlider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchProfile(), // Panggil method untuk mendapatkan profil
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Tampilkan indikator saat menunggu
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Tampilkan pesan error
        } else if (snapshot.hasData) {
          final profile = snapshot.data;
          final firstName = profile['first_name'];
          final lastName = profile['last_name'];
          return Text(
            'Selamat Datang, $firstName $lastName',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          );
        } else {
          return Text('Data profil tidak ditemukan');
        }
      },
    );
  }


  Widget _buildBalance() {
    return FutureBuilder<double>(
      future: futureBalance,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final saldo = snapshot.data;
          return Container(
            height: 150.0,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Background Saldo.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Jumlah Saldo',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    'Rp ${saldo.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text('No data found'));
        }
      },
    );
  }

  //slider promo dari asset lokal
  Widget _buildSlider() {
    final List<String> bannerImages = [
      'assets/images/Banner 1.png',
      'assets/images/Banner 2.png',
      'assets/images/Banner 3.png',
      'assets/images/Banner 4.png',
      'assets/images/Banner 5.png',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Temukan Promo Menarik',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        CarouselSlider(
          height: 150.0,
          autoPlay: true,
          enlargeCenterPage: false,
          items: bannerImages.map((image) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.transparent,
                  ),
                  child: Image.asset(image, fit: BoxFit.cover),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
