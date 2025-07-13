import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _namadepanController = TextEditingController();
  final TextEditingController _namabelakangController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordconfirmController = TextEditingController();

  bool _isObscure = true;
  bool _isObscureConfirm = true;

  void _register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final firstName = _namadepanController.text;
      final lastName = _namabelakangController.text;
      final password = _passwordController.text;

      final response = await http.post(
        Uri.parse('https://take-home-test-api.nutech-integrasi.com/registration'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'password': password,
        }),
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseBody['status'] == 0) {
          // Registrasi berhasil
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'])),
          );
        } else {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'])),
          );
        }
      } else {
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan pada server')),
        );
      }
    }
  }

  String _emailValidator(String value) {
    if (value == null || value.isEmpty) {
      return 'Masukan email anda';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Email tidak valid';
    }
    return null;
  }

  String _passwordValidator(String value) {
    if (value == null || value.isEmpty) {
      return 'Masukan passsword anda';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  String _confirmPasswordValidator(String value) {
    if (value == null || value.isEmpty) {
      return 'Mohon konfirmasi password anda';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Builder(
              builder: (BuildContext context) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    logo,
                    SizedBox(height: 30),
                    // email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          labelText: 'Email',
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
                      ),
                      validator: _emailValidator,
                    ),
                    SizedBox(height: 10),
                    // nama depan
                    TextFormField(
                      controller: _namadepanController,
                      decoration: InputDecoration(
                          labelText: 'Nama Depan',
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukan Nama Depan Anda';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    // nama belakang
                    TextFormField(
                      controller: _namabelakangController,
                      decoration: InputDecoration(
                          labelText: 'Nama Belakang',
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukan Nama Belakang Anda';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    // password
                    TextFormField(
                      obscureText: _isObscure,
                      controller: _passwordController,
                      decoration: InputDecoration(
                          labelText: 'Buat Password',
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
                      validator: _passwordValidator,
                    ),
                    SizedBox(height: 10),
                    // konfirmasi password
                    TextFormField(
                      obscureText: _isObscureConfirm,
                      controller: _passwordconfirmController,
                      decoration: InputDecoration(
                          labelText: 'Konfirmasi Password',
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          suffixIcon: IconButton(
                              icon: Icon(
                                  _isObscureConfirm ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isObscureConfirm = !_isObscureConfirm;
                                });
                              })
                      ),

                      validator: _confirmPasswordValidator,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _register(context),
                      child: Text('Registrasi'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Sudah punya akun? login disini'),
                    ),
                  ],
                );
              }
          ),
        ),
      ),
    );
  }
}
