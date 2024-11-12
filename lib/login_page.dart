import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jurnal_prakerin/component/bottomNavigationBar_custom.dart';
import 'package:jurnal_prakerin/component/button_custom.dart';
import 'package:jurnal_prakerin/component/snakcbar_custom.dart';
import 'package:jurnal_prakerin/component/textFormField_custom.dart';
import 'package:jurnal_prakerin/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obsecureText = true;
  bool _isLoading = false;
  Future<void> login(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final response = await http.post(Uri.parse(connect().url + 'login'), body: {
      'username': _usernameController.text,
      'password': _passController.text
    });
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['token'];
      final user = responseData['user'];
      final siswa = responseData['siswa'];
      final kelas = siswa['kelas'];
      final iduser = user['id'].toString();
      final level = user['level'].toString();
      final idsiswa = siswa['id'].toString();
      final idkelas = kelas['id'].toString();
      if (level == 'siswa') {
        // SharedPreferences.setMockInitialValues({});
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('id', iduser);
        await prefs.setString('idsiswa', idsiswa);
        await prefs.setString('idkelas', idkelas);
        if (mounted) {
          SnakcbarCustom.show(context, 'Login berhasil', Colors.green[300]!,
              'Sukses', Icon(Icons.check, color: Colors.green));
        }
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => BottomnavigationbarCustom(id: 0)),
            (route) => false);
      } else {
        log('TIDAK ADA HAK AKSES: ' + level);
      }
    } else {
      log('GAGAL LOGIN: ' + response.statusCode.toString());
      log('GAGAL LOGIN: ' + response.body);
      if (mounted) {
        SnakcbarCustom.show(
            context,
            'Username atau password tidak sesuai!',
            Colors.red[300]!,
            'Terjadi Kesalahan',
            Icon(Icons.error, color: Colors.red));
      }
    } 
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assets/images/logo.png'),
              height: 120,
              width: 120,
            ),
            const Text(
              'Jurnal Prakerin',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 1, 102),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            TextformfieldCustom(
              controller: _usernameController,
              labelText: 'Nisn',
            ),
            const SizedBox(height: 15),
            TextformfieldCustom(
              controller: _passController,
              labelText: 'Password',
              isObsecureText: _obsecureText,
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obsecureText = !_obsecureText;
                  });
                },
                child: Icon(
                  _obsecureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 15),
            ButtonCustom(
              width: double.infinity,
              text: 'Masuk',
              onPressedAction: () {
                login(context);
              },
              isLoading: _isLoading,
            )
          ],
        ),
      ),
    );
  }
}
