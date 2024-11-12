import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:jurnal_prakerin/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bannerdetail extends StatefulWidget {
  final int id;
  const Bannerdetail({super.key, required this.id});

  @override
  State<Bannerdetail> createState() => _BannerdetailState();
}

class _BannerdetailState extends State<Bannerdetail> {
  String name = '';
  String deskripsi = '';
  String gambar = '';
  String tanggal = '';
  Future<void> showBannerId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('token');
    final response = await http.get(
        Uri.parse(connect().url + 'banner/show/${widget.id}?token=$token'));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body)['banner'];
      log('Data: ' + response.body);
      if (mounted) {
        setState(() {
          name = responseData['name'];
          deskripsi = responseData['deskripsi'];
          gambar = responseData['gambar'];
          tanggal = responseData['tanggal'];
        });
      }
    } else {
      log('Data gagal: ' + response.body);
    }
  }

  @override
  void initState() {
    showBannerId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          title: Text('Artikel ${widget.id}'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: CachedNetworkImage(
                      imageUrl: gambar,
                      width: 500,
                      height: 150,
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
                SizedBox(height: 4),
                Text(
                  'dibuat pada: $tanggal',
                  style: TextStyle(
                      fontSize: 10,
                      color: const Color.fromARGB(190, 0, 0, 0),
                      fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 24),
                Html(
                  data: deskripsi,
                  style: {
                    "body": Style(
                      fontSize: FontSize(12),
                      color: Color.fromARGB(232, 0, 0, 0),
                    ),
                  },
                )
              ],
            ),
          ),
        ));
  }
}
