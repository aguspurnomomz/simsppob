import 'package:Nutech/dashboard/navigasibottom.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text;
      final String password = _passwordController.text;

      //URL Request
      final String apiUrl = 'https://take-home-test-api.nutech-integrasi.com/login';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'email': email, 'password': password}),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData['status'] == 0) {
            final String token = responseData['data']['token'];

            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', token);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NavigasiBottom()),
            );
          } else {
            _showErrorDialog(responseData['message']);
          }
        } else {
          _showErrorDialog('Periksa kembali Email dan Password Anda.');
        }
      } catch (e) {
        _showErrorDialog('Kesalahan pada jaringan. Periksa koneksi Anda.');
      }
    }
  }

  final logo = Hero(
    tag: 'hero',
    child: CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 35.0,
      child: Image.asset(
        "assets/icon/Logo.png",
      ),
    ),
  );

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              logo,
              SizedBox(height: 30),
              Text("Masuk atau Buat Akun Untuk Memulai"),
              SizedBox(height: 100),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    labelText: 'Email',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
                ),
                validator: (value) {
                  if (value == null || value!.isEmpty) {
                    return 'Masukan email anda';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                obscureText: _isObscure,
                controller: _passwordController,
                decoration: InputDecoration(
                    labelText: 'Password',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _isObscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        })
                ),


                validator: (value) {
                  if (value == null || value!.isEmpty) {
                    return 'Masukan password anda';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                style: Text('Belum punya akun? Registrasi di sini'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
