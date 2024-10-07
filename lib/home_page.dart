import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart' as slider_controller;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jurnal_prakerin/banner_page.dart';
import 'package:jurnal_prakerin/component/snakcbar_custom.dart';
import 'package:jurnal_prakerin/connection.dart';
import 'package:http/http.dart' as http;
import 'package:jurnal_prakerin/pilih_pesan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _fcmToken;
  String name = '';
  String kelas = '';
  String foto = '';
  int? hadir;
  int? izin;
  int? sakit;
  int? jam;
  int? menit;
  List<Map<String, dynamic>> artikel = [];

  void getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Mendapatkan FCM token
    String? token = await messaging.getToken();
    setState(() {
      _fcmToken = token;
    });

    if (token != null) {
      // Kirim token ke backend
      sendTokenToServer(token);
    }
  }

  void sendTokenToServer(String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? tokenLogin = preferences.getString('token');
    String? iduser = preferences.getString('id');
    final response = await http.post(
      Uri.parse(connect().url + 'user/fcmToken/$iduser?token=$tokenLogin'),
      body: {
        'fcm_token': token,
      },
    );

    if (response.statusCode == 200) {
      log('Token berhasil disimpan ke database');
    } else {
      log(response.body);
      log('Gagal menyimpan token');
    }
  }

  Future<void> showData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String? iduser = preferences.getString('id');
    final response = await http
        .get(Uri.parse(connect().url + 'dashboard/$iduser?token=$token'));
    if (response.statusCode == 200) {
      log('Data: ' + response.body);
      final responseData = jsonDecode(response.body);
      final data = responseData['siswa'];
      final waktu = responseData['total_jam_kerja'];
      if (mounted) {
        setState(() {
          name = data['name'];
          kelas = data['kelas'];
          foto = data['foto'] != null
              ? data['foto']
              : 'https://media.istockphoto.com/id/1337144146/vector/default-avatar-profile-icon-vector.jpg?s=612x612&w=0&k=20&c=BIbFwuv7FxTWvh5S3vB6bkT0Qv8Vn8N5Ffseq84ClGI=';
          hadir = responseData['hadir'];
          izin = responseData['izin'];
          sakit = responseData['sakit'];
          jam = waktu['jam'];
          menit = waktu['menit'];
        });
      }
    } else {
      log('Data gagal: ' + response.body);
      if (mounted) {
        SnakcbarCustom.show(context, 'Gagal mengambil data', Colors.red[300]!,
            'Terjadi Kesalahan', Icon(Icons.error, color: Colors.red));
      }
    }
  }

  Future<void> showDataBanner() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    final response =
        await http.get(Uri.parse(connect().url + 'banner/show?token=$token'));
    if (response.statusCode == 200) {
      log('Data:' + response.body);
      final List<dynamic> data = jsonDecode(response.body)['banner'];
      if (mounted) {
        setState(() {
          artikel = data.cast<Map<String, dynamic>>();
        });
      }
    } else {
      log('Gagal mengambil data');
    }
  }

  @override
  void initState() {
    getToken();
    showData();
    showDataBanner();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              name: name,
              kelas: kelas,
              foto: foto,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 16),
                caraouseSlider(),
                SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => BannerPage()));
                  },
                  child: Text(
                    'Lihat selengkapnya...',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
                gridView()
              ],
            )
          ],
        ),
      ),
    );
  }

  slider_controller.CarouselSlider caraouseSlider() {
    return slider_controller.CarouselSlider(
      items: artikel.map((item) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              child: Container(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                    imageUrl: item['gambar'],
                    placeholder: (context, url) => Container(
                      width: 500.0,
                      height: 150.0,
                      color: Colors.grey,
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
      options: slider_controller.CarouselOptions(
        height: 120,
        // aspectRatio: 16 / 9,
        // viewportFraction: 0.8,
        // initialPage: 0,
        // enableInfiniteScroll: true,
        // reverse: false,
        autoPlay: true,
        // autoPlayInterval: Duration(seconds: 3),
        // autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        // onPageChanged: (index, reason) {
        //   setState(() {
        //     // _currentPage = index;
        //   });
        // },
      ),
    );
  }

  GridView gridView() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1.80,
      children: [
        Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.green.withAlpha(90), width: 2),
              color: Colors.green.withAlpha(20),
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$hadir',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              Text(
                'Total Hadir',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.orangeAccent.withAlpha(90), width: 2),
              color: Colors.orangeAccent.withAlpha(20),
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$sakit',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              Text(
                'Total Sakit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.red.withAlpha(90), width: 2),
              color: Colors.red.withAlpha(20),
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$izin',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              Text(
                'Total Izin',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withAlpha(90), width: 2),
              color: Colors.grey.withAlpha(20),
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$jam jam $menit menit',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              Text(
                'Total Jam Kerja',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class AppBar extends StatelessWidget {
  final String name;
  final String kelas;
  final String foto;
  const AppBar(
      {super.key, required this.name, required this.kelas, required this.foto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
      height: 300,
      width: double.infinity,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30)),
          gradient: LinearGradient(
              colors: [Colors.blue, Color.fromARGB(255, 220, 237, 252)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PilihPesan()));
                },
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 141, 199, 247)),
                  child: Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
          ClipOval(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(foto),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            kelas,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
