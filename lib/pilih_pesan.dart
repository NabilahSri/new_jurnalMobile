import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:jurnal_prakerin/connection.dart';
import 'package:jurnal_prakerin/notification_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PilihPesan extends StatefulWidget {
  const PilihPesan({super.key});

  @override
  State<PilihPesan> createState() => _PilihPesanState();
}

class _PilihPesanState extends State<PilihPesan> {
  List<dynamic> pesan = [];
  Future<void> show() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String? idsiswa = preferences.getString('idsiswa');
    final request = await http
        .get(Uri.parse(connect().url + 'pesan/showAwal/$idsiswa?token=$token'));
    if (request.statusCode == 200) {
      log('berhasil');
      setState(() {
        pesan = jsonDecode(request.body)['pesan'];
      });
    } else {
      log('gagal');
      log(request.body);
    }
  }

  @override
  void initState() {
    initializeDateFormatting('id').then((_) {});
    show();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Colors.blue),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pesan',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Expanded(
                  child: ListView.separated(
                itemBuilder: (context, index) {
                  final dataPesan = pesan[index];
                  String tanggalAsli = dataPesan['tanggal_kirim'];
                  DateTime parsedDate = DateTime.parse(tanggalAsli);
                  String formattedDate =
                      DateFormat('dd-MM-yyyy HH:mm', 'id').format(parsedDate);
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationPage(
                                  pengirim_pesan: dataPesan['id_pengirim'])));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dataPesan['user_pengirim']['level'],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  dataPesan['pesan'],
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                Icon(
                                  Icons.arrow_circle_right,
                                  color: Colors.white,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: pesan.length,
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(height: 8);
                },
              ))
            ],
          ),
        ),
      ),
    );
  }
}
