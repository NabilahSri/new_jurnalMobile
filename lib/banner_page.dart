import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:jurnal_prakerin/bannerDetail.dart';
import 'package:jurnal_prakerin/component/textFormField_custom.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jurnal_prakerin/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BannerPage extends StatefulWidget {
  const BannerPage({super.key});

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> artikel = [];
  Future<void> showData() async {
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
    super.initState();
    showData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // backgroundColor: Colors.blue,
          // foregroundColor: Colors.white,
          // title: Text('Artikel'),
          // centerTitle: true,
          ),
      body: Padding(
        padding: const EdgeInsets.only(right: 24, left: 24, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Artikel',
              style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Cari artikel...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  setState(() {
                    searchResults = artikel
                        .where((item) => item['name']
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  final item = searchResults.isNotEmpty
                      ? searchResults[index]
                      : artikel[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Bannerdetail(
                                id: item['id'],
                              )));
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              imageUrl: item['gambar'],
                              width: 500,
                              height: 150,
                              placeholder: (context, url) => Container(
                                width: 500.0,
                                height: 150.0,
                                color: Colors.grey,
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 10,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 3, 66, 117),
                                borderRadius: BorderRadius.circular(4)),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                item['name'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(height: 16.0);
                },
                itemCount: searchResults.isNotEmpty
                    ? searchResults.length
                    : artikel.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}
