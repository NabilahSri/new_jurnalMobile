import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as badges;
import 'package:jurnal_prakerin/activity_page.dart';
import 'package:jurnal_prakerin/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ListHistoryPresensi extends StatefulWidget {
  final String tanggal_awal;
  final String tanggal_akhir;
  const ListHistoryPresensi(
      {super.key, required this.tanggal_awal, required this.tanggal_akhir});

  @override
  State<ListHistoryPresensi> createState() => _ListHistoryPresensiState();
}

class _ListHistoryPresensiState extends State<ListHistoryPresensi> {
  List<dynamic> data = [];
  Future<void> showKehadiran() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String? idsiswa = preferences.getString('idsiswa');
    final response = await http.get(Uri.parse(connect().url +
        'kehadiran/show/$idsiswa/${widget.tanggal_awal}/${widget.tanggal_akhir}?token=$token'));
    setState(() {
      data = jsonDecode(response.body)['kehadiran'];
    });
    if (response.statusCode == 200) {
      log(data.toString());
    } else {
      log("gagal mengambil data");
    }
  }

  @override
  void initState() {
    showKehadiran();
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
                "Kehadiran",
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    final datakehadiran = data[index];
                    String tanggalAsli = datakehadiran['tanggal'];
                    DateTime parsedDate = DateTime.parse(tanggalAsli);
                    String formattedDate =
                        DateFormat('EEEE, dd MMMM yyyy', 'id')
                            .format(parsedDate);
                    return InkWell(
                      onTap: () {
                        if (datakehadiran['status'] == 'izin' ||
                            datakehadiran['status'] == 'sakit') {
                          dialogShow(context, datakehadiran);
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ActivityPage(
                                      id_kehadiran: datakehadiran['id'])));
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formattedDate,
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                              badges.Badge(
                                badgeContent: Text(
                                  datakehadiran['jumlah_kegiatan'].toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Masuk",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                datakehadiran['jam_masuk'] != null
                                    ? datakehadiran['jam_masuk']
                                    : "-",
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Pulang",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                datakehadiran['jam_pulang'] != null
                                    ? datakehadiran['jam_pulang']
                                    : "-",
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                          SizedBox(height: 4),
                          Status(datakehadiran),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                  itemCount: data.length,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Row Status(datakehadiran) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Status",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        if (datakehadiran['status'] == 'hadir')
          Text(
            'Hadir',
            style: TextStyle(color: Colors.green),
          )
        else if (datakehadiran['status'] == 'izin')
          Text(
            'Izin',
            style: TextStyle(color: Colors.red),
          )
        else
          Text(
            'Sakit',
            style: TextStyle(color: Colors.yellow[700]),
          )
      ],
    );
  }

  Future<dynamic> dialogShow(BuildContext context, datakehadiran) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Kehadiran dengan status ${datakehadiran['status']}. Anda tidak dapat menambah kegiatan.'),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 200,
                width: 200,
                child: Image.network(
                  datakehadiran['bukti'],
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
  }
}
