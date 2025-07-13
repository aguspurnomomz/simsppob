import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MenuService {
  final String serviceCode;
  final String serviceName;
  final String serviceIcon;
  final int serviceTariff;

  MenuService({this.serviceCode, this.serviceName, this.serviceIcon, this.serviceTariff});

  factory MenuService.fromJson(Map<String, dynamic> json) {
    return MenuService(
      serviceCode: json['service_code'],
      serviceName: json['service_name'],
      serviceIcon: json['service_icon'],
      serviceTariff: json['service_tariff'],
    );
  }
}

class ServiceService {
  static Future<List<MenuService>> fetchServices(String token) async {
    final response = await http.get(
      Uri.parse('https://take-home-test-api.nutech-integrasi.com/services'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['status'] == 0) {
        List<dynamic> data = responseBody['data'];
        return data.map((service) => MenuService.fromJson(service)).toList();
      } else {
        throw Exception('Gagal Mengambil Data: ${responseBody['message']}');
      }
    } else {
      throw Exception('Gagal Mengambil Data');
    }
  }

  static Future<Map<String, dynamic>> makeTransaction(String token, String serviceCode) async {
    final response = await http.post(
      Uri.parse('https://take-home-test-api.nutech-integrasi.com/transaction'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_code': serviceCode,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['status'] == 0) {
        return responseBody['data'];
      } else {
        throw Exception('Transaksi Gagal: ${responseBody['message']}');
      }
    } else {
      throw Exception('Transaksi Gagal');
    }
  }
}

// Widget Menu
class Menu extends StatefulWidget {
  const Menu({Key key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Future<List<MenuService>> futureServices;
  String token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchServices();
  }

  Future<void> _loadTokenAndFetchServices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    futureServices = ServiceService.fetchServices(token);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FutureBuilder<List<MenuService>>(
          future: futureServices,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final services = snapshot.data;
              final firstRowServices = services.sublist(0, services.length ~/ 2);
              final secondRowServices = services.sublist(services.length ~/ 2);

              return Column(
                children: [
                  _buildServiceRow(firstRowServices),
                  SizedBox(height: 10.0),
                  _buildServiceRow(secondRowServices),
                ],
              );
            } else {
              return Text('No data found');
            }
          },
        ),
      ],
    );
  }

  Widget _buildServiceRow(List<MenuService> services) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: services.map((service) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceDetailPage(service: service, token: token),
                        ),
                      );
                    },
                    child: Image.network(
                      service.serviceIcon,
                      width: 40.0,
                      height: 40.0,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/icon/default.png',
                          width: 40.0,
                          height: 40.0,
                        );
                      },
                    ),
                  ),
                  TextButton(
                    child: Text(service.serviceName,
                        style: TextStyle(color: Colors.black87, fontSize: 12.0)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceDetailPage(service: service, token: token),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ServiceDetailPage extends StatelessWidget {
  final MenuService service;
  final String token;

  ServiceDetailPage({@required this.service, @required this.token});

  Future<void> _handleTransaction(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      final transactionData = await ServiceService.makeTransaction(token, service.serviceCode);

      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Transaksi Berhasil'),
            content: Text('Nomor Invoice: ${transactionData['invoice_number']}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.of(context).pop();

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Kesalahan'),
            content: Text('Kesalahan: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service.serviceName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                service.serviceIcon,
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/icon/default.png',
                    width: 80,
                    height: 80,
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text('Kode Layanan: ${service.serviceCode}'),
            SizedBox(height: 10),
            Text('Nama Layanan: ${service.serviceName}'),
            SizedBox(height: 10),
            Text('Tarif: Rp ${service.serviceTariff}'),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () => _handleTransaction(context),
                child: Text('Bayar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
