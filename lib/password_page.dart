import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:jurnal_prakerin/component/snakcbar_custom.dart';
import 'package:jurnal_prakerin/component/textFormField_custom.dart';
import 'package:jurnal_prakerin/connection.dart';
import 'package:http/http.dart' as http;
import 'package:jurnal_prakerin/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  bool _obsecureText = true;
  bool _obsecureTextConfirm = true;
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  bool _isLoading = false;

  Future<void> editPassword() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String? iduser = preferences.getString('id');
    log('Id user: ' + iduser.toString());
    final response = await http.post(
      Uri.parse(connect().url + 'user/editAkun/$iduser?token=$token'),
      body: {
        'password': _passController.text,
      },
    );
    if (response.statusCode == 200) {
      log('Data: ' + response.body);
      if (mounted) {
        SnakcbarCustom.show(
            context,
            'Silahkan login menggunakan password baru anda',
            Colors.green[300]!,
            'Sukses',
            Icon(Icons.check, color: Colors.green));
      }
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false);
    } else {
      log('Data gagal: ' + response.body);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: () {
                if (_passController.text != _confirmPassController.text) {
                  if (mounted) {
                    SnakcbarCustom.show(
                        context,
                        'Password tidak sesuai',
                        Colors.red[300]!,
                        'Konfirmasi password',
                        Icon(Icons.error, color: Colors.red));
                  }
                } else {
                  editPassword();
                }
              },
              icon: _isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
              style: IconButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ubah Password',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              ubahPasswordContent(
                  TextformfieldCustom(
                    controller: _passController,
                    isObsecureText: _obsecureText,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obsecureText = !_obsecureText;
                        });
                      },
                      child: Icon(
                          _obsecureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey),
                    ),
                  ),
                  'Password \nbaru'),
              SizedBox(height: 12),
              ubahPasswordContent(
                  TextformfieldCustom(
                    controller: _confirmPassController,
                    isObsecureText: _obsecureTextConfirm,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obsecureTextConfirm = !_obsecureTextConfirm;
                        });
                      },
                      child: Icon(
                          _obsecureTextConfirm
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey),
                    ),
                  ),
                  'Konfirmasi Password'),
            ],
          ),
        ),
      ),
    );
  }

  Row ubahPasswordContent(Widget content, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Text(
          text,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        )),
        Expanded(
          child: content,
          flex: 2,
        ),
      ],
    );
  }
}
