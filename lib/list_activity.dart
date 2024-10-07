import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jurnal_prakerin/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListActivityPage extends StatefulWidget {
  final String tanggal_awal;
  final String tanggal_akhir;
  const ListActivityPage(
      {super.key, required this.tanggal_awal, required this.tanggal_akhir});

  @override
  State<ListActivityPage> createState() => _ListActivityPageState();
}

class _ListActivityPageState extends State<ListActivityPage> {
  List<dynamic> listDataKegiatan = [];
  Future<void> listKegiatan() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String? idsiswa = preferences.getString('idsiswa');
    final response = await http.get(Uri.parse(connect().url +
        'kegiatan/show/$idsiswa/${widget.tanggal_awal}/${widget.tanggal_akhir}?token=$token'));
    if (response.statusCode == 200) {
      log('berhasil');
      setState(() {
        listDataKegiatan = jsonDecode(response.body)['kegiatan'];
      });
      log(listDataKegiatan.toString());
    } else {
      log('gagal');
    }
  }

  @override
  void initState() {
    initializeDateFormatting('id').then((_) {
      listKegiatan();
    });
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Kegiatan",
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      final dataKegiatan = listDataKegiatan[index];
                      String tanggalAsli = dataKegiatan['tanggal'];
                      DateTime parsedDate = DateTime.parse(tanggalAsli);
                      String formattedDate =
                          DateFormat('EEEE, dd MMMM yyyy', 'id')
                              .format(parsedDate);
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 200,
                                      width: 200,
                                      child: dataKegiatan['foto'] == null
                                          ? Text("Tidak ada foto kegiatan")
                                          : Image.network(
                                              dataKegiatan['foto'],
                                              fit: BoxFit.fill,
                                            ),
                                    )
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDate,
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "Nama Kegiatan : ",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Text(
                                    dataKegiatan['deskripsi'],
                                    style: TextStyle(color: Colors.grey),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  "Durasi Pengerjaan : ",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  dataKegiatan['durasi'],
                                  style: TextStyle(color: Colors.grey),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemCount: listDataKegiatan.length),
              )
            ],
          ),
        ),
      ),
    );
  }
}
