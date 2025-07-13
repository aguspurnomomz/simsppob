import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TopUpBalancePage extends StatefulWidget {
  @override
  _TopUpBalancePageState createState() => _TopUpBalancePageState();
}

class _TopUpBalancePageState extends State<TopUpBalancePage> {
  final TextEditingController _amountController = TextEditingController();
  final List<int> nominalTopUp = [10000, 20000, 50000, 100000, 250000, 500000];
  bool _isButtonDisabled = true;
  Future<double> futureBalance;

  @override
  void initState() {
    super.initState();
    futureBalance = _fetchBalance();
  }

  Future<double> _fetchBalance() async {
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
        Uri.parse('https://take-home-test-api.nutech-integrasi.com/balance'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data']['balance'] != null) {
          return data['data']['balance'].toDouble();
        } else {
          throw Exception('Saldo tidak ditemukan.');
        }
      } else {
        throw Exception('Gagal mendapatkan saldo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan: $e');
    }
  }

  void _validateInput() {
    final amount = int.tryParse(_amountController.text);
    setState(() {
      _isButtonDisabled = amount == null || amount < 10000 || amount > 1000000;
    });
  }

  void _setAmount(int amount) {
    _amountController.text = amount.toString();
    _validateInput();
  }

  Future<void> _topUp() async {
    final amount = int.parse(_amountController.text);
    if (amount < 10000 || amount > 1000000) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token');

      if (token == null) {
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Silakan login kembali.')),
        );
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('https://take-home-test-api.nutech-integrasi.com/topup'),
        headers: headers,
        body: json.encode({'top_up_amount': amount}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 0) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        } else {
          throw Exception('Top Up gagal: ${data['message']}');
        }

        setState(() {
          futureBalance = _fetchBalance();
        });
      } else {
        throw Exception('Failed to top up: ${response.statusCode}');
      }
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan: $e')),
      );
    }
  }


  Widget _buildBalance() {
    return FutureBuilder<double>(
      future: futureBalance,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data != null) {
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
          return Center(child: Text('Saldo tidak tersedia'));
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Top Up Balance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildBalance(),
            SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Nominal Top Up',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _validateInput(),
            ),
            SizedBox(height: 20),
            Text(
              'Pilih Nominal Top Up',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2,
                ),
                itemCount: nominalTopUp.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _setAmount(nominalTopUp[index]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'Rp.'+'${nominalTopUp[index]}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : _topUp,
              child: Text('Top Up'),
            ),
          ],
        ),
      ),
    );
  }
}
