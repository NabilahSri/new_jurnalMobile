import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:jurnal_prakerin/component/snakcbar_custom.dart';
import 'package:jurnal_prakerin/location_page.dart';
import 'package:jurnal_prakerin/profile_page.dart';
import 'package:jurnal_prakerin/connection.dart';
import 'package:jurnal_prakerin/laporan_page.dart';
import 'package:jurnal_prakerin/panduan_page.dart';
import 'package:jurnal_prakerin/password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String name = '';
  String nisn = '';
  String foto = '';
  bool isDataDiriVisible = false;
  bool isBantuanVisible = false;
  String? selectedMode;

  Future<void> showData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String? iduser = preferences.getString('id');
    log('keterangan id:' + iduser.toString());
    final response =
        await http.get(Uri.parse(connect().url + 'user/$iduser?token=$token'));
    if (response.statusCode == 200) {
      log('Data: ' + response.body);
      final responseData = jsonDecode(response.body)['user'];
      if (mounted) {
        setState(() {
          name = responseData['name'];
          nisn = responseData['nisn'];
          foto = responseData['foto'] != null
              ? responseData['foto']
              : 'https://media.istockphoto.com/id/1337144146/vector/default-avatar-profile-icon-vector.jpg?s=612x612&w=0&k=20&c=BIbFwuv7FxTWvh5S3vB6bkT0Qv8Vn8N5Ffseq84ClGI=';
        });
      }
      SharedPreferences shared = await SharedPreferences.getInstance();
      await shared.setString(
          'kunci_lokasi', responseData['kunci_lokasi'].toString());
    } else {
      log('Data gagal diambil: ' + response.body);
    }
  }

  Future<void> getMode() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? mode = shared.getString('mode');
    if (mode != null) {
      setState(() {
        selectedMode = mode;
      });
    } else {
      setState(() {
        selectedMode = 'Lokasi';
      });
    }
    log(selectedMode.toString());
  }

  @override
  void initState() {
    showData();
    getMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.blue,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengaturan',
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 40),
                Text(
                  'Profil',
                  style: TextStyle(fontSize: 28),
                ),
                SizedBox(height: 20),
                contentProfile(),
                SizedBox(height: 40),
                Text(
                  'Pengaturan',
                  style: TextStyle(fontSize: 28),
                ),
                SizedBox(height: 20),
                contentPengaturan(Colors.green[100]!, Icons.change_circle,
                    Colors.green, 'Ubah password', () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PasswordPage()));
                }),
                SizedBox(height: 12),
                contentPengaturan(
                    Colors.teal[100]!, Icons.map, Colors.teal, 'Atur Lokasi',
                    () async {
                  SharedPreferences shared =
                      await SharedPreferences.getInstance();
                  String? kunci_lokasi = shared.getString('kunci_lokasi');
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          LocationPage(kunci_lokasi: kunci_lokasi.toString())));
                }),
                SizedBox(height: 12),
                contentPengaturan(Colors.blueGrey[100]!, Icons.fingerprint,
                    Colors.blueGrey, 'Mode kehadiran', () {
                  setState(() {
                    isDataDiriVisible = !isDataDiriVisible;
                  });
                }),
                isDataDiriVisible ? modeAbsenContent() : Container(),
                SizedBox(height: 12),
                contentPengaturan(
                    Colors.red[100]!, Icons.help, Colors.red, 'Bantuan', () {
                  setState(() {
                    isBantuanVisible = !isBantuanVisible;
                  });
                }),
                isBantuanVisible ? bantuanContent() : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding bantuanContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => LaporanPage()));
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Laporkan masalah',
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => PanduanPage()));
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Panduan penggunaan aplikasi',
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container contentPengaturan(Color bgColor, IconData icon, Color iconColor,
      String title, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            child: Icon(
              icon,
              size: 24,
              color: iconColor,
            ),
          ),
          SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Spacer(),
          InkWell(
            onTap: onTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(Icons.chevron_right_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Container contentProfile() {
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(foto),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                nisn,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey),
              )
            ],
          ),
          Spacer(),
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => ProfilePage()));
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(Icons.chevron_right_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Container modeAbsenContent() {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Radio(
                value: "Lokasi",
                groupValue: selectedMode,
                onChanged: (value) async {
                  setState(() {
                    selectedMode = value;
                    log(selectedMode.toString());
                  });
                  SharedPreferences shared =
                      await SharedPreferences.getInstance();
                  shared.setString('mode', selectedMode!);
                  SnakcbarCustom.show(
                      context,
                      'Mode lokasi berhasil di set',
                      Colors.green[300]!,
                      'Sukses',
                      Icon(Icons.check, color: Colors.green));
                },
              ),
              Text("Lokasi"),
            ],
          ),
          Row(
            children: [
              Radio(
                value: "Token",
                groupValue: selectedMode,
                onChanged: (value) async {
                  setState(() {
                    selectedMode = value;
                    log(selectedMode.toString());
                  });
                  SharedPreferences shared =
                      await SharedPreferences.getInstance();
                  shared.setString('mode', selectedMode!);
                  SnakcbarCustom.show(
                      context,
                      'Mode token berhasil di set',
                      Colors.green[300]!,
                      'Sukses',
                      Icon(Icons.check, color: Colors.green));
                },
              ),
              Text("Token"),
            ],
          ),
        ],
      ),
    );
  }
}
