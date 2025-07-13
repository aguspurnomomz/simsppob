import 'package:Nutech/profile/profile_service.dart';
import 'package:Nutech/register/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Profile> futureProfile;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _namadepanController = TextEditingController();
  final TextEditingController _namabelakangController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureProfile = ProfileService.fetchProfile();
  }


  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _editProfile() {
    setState(() {
      isEditing = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      isEditing = false;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState.validate()) {
      final Map<String, dynamic> updatedProfileData = {
        'email': _emailController.text,
        'first_name': _namadepanController.text,
        'last_name': _namabelakangController.text,
      };

      try {
        final response = await http.post(
          Uri.parse('https://take-home-test-api.nutech-integrasi.com/profile/update'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${await _getToken()}',
          },
          body: jsonEncode(updatedProfileData),
        );

        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 0) {
          // Successfully updated
          // Show a success message
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );

          // Exit edit mode and reset controllers with new data
          setState(() {
            isEditing = false; // Exit edit mode
            _emailController.text = responseData['data']['email'];
            _namadepanController.text = responseData['data']['first_name'];
            _namabelakangController.text = responseData['data']['last_name'];
          });
        } else {
          throw Exception('Update failed');
        }
      } catch (e) {
        print('Error updating profile: $e');
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile.')),
        );
      }
    }
  }

  Future<String> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<Profile>(
        future: futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final profile = snapshot.data;

            // Set initial values to the controllers
            if (!isEditing) {
              _emailController.text = profile.email;
              _namadepanController.text = profile.firstName;
              _namabelakangController.text = profile.lastName;
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profile.profileImage.isNotEmpty
                          ? NetworkImage(profile.profileImage)
                          : AssetImage('assets/images/Profile Photo-1.png'),
                    ),
                  ),
                  SizedBox(height: 5),
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Profil Pengguna",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),

                            // Email
                            _buildTextField("Email", _emailController, isEditing),
                            _buildDivider(),

                            // First Name
                            _buildTextField("First Name", _namadepanController, isEditing),
                            _buildDivider(),

                            // Last Name
                            _buildTextField("Last Name", _namabelakangController, isEditing),
                            _buildDivider(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),

                  // Button Edit Profile or Save / Cancel
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isEditing ? _saveProfile : _editProfile,
                          child: Text(isEditing ? 'Simpan' : 'Edit Profile'),
                        ),
                      ),
                      SizedBox(height: 10),
                      if (isEditing)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _cancelEdit,
                            style: ElevatedButton.styleFrom(primary: Colors.red),
                            child: Text('Batalkan'),
                          ),
                        ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          child: Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data found'));
          }
        },
      ),
    );
  }

  Widget _buildTextField(String title, TextEditingController controller, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextFormField(
            controller: controller,
            enabled: isEditable,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Masukkan $title',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Field ini tidak boleh kosong';
              }
              return null; // Valid input
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Column(
      children: [
        SizedBox(height: 5),
        Divider(height: 1, thickness: 3),
        SizedBox(height: 5),
      ],
    );
  }
}
