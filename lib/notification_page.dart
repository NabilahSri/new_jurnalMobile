import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:jurnal_prakerin/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  final int pengirim_pesan;
  const NotificationPage({super.key, required this.pengirim_pesan});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> data = [];
  String? iduser;

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  Future<void> showPesan() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? token = shared.getString('token');
    String? idsiswa = shared.getString('idsiswa');
    iduser = shared.getString('id');
    final request = await http.get(Uri.parse(connect().url +
        'pesan/show/$idsiswa/${widget.pengirim_pesan}?token=$token'));
    if (request.statusCode == 200) {
      log(request.body);
      setState(() {
        data = jsonDecode(request.body)['pesan'];
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else {
      log('gagal');
      log(request.body);
    }
  }

  Future<void> createPesan() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String? iduser = preferences.getString('id');
    final request = await http
        .post(Uri.parse(connect().url + 'pesan/add?token=$token'), body: {
      'id_pengirim': iduser,
      'id_penerima': widget.pengirim_pesan.toString(),
      'kirim_pesan': _messageController.text
    });
    if (request.statusCode == 201) {
      log('berasil');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
      _messageController.clear();
    } else {
      log('gagal');
      log(request.body);
    }
  }

  @override
  void initState() {
    initializeDateFormatting('id').then((_) {});
    showPesan();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Pesan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Colors.blue),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: contentPesan(),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: kirimPesan(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row kirimPesan() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: "Ketik pesan...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            createPesan();
            _scrollToBottom();
            showPesan();
            // Logika untuk mengirim pesan atau memproses input
            // print('Pesan dikirim: ${_messageController.text}');
            // _messageController.clear(); // Mengosongkan input setelah mengirim pesan
          },
          child: Icon(Icons.send),
          style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(14),
              backgroundColor: Colors.blueAccent[100]),
        ),
      ],
    );
  }

  ListView contentPesan() {
    return ListView.separated(
      controller: _scrollController,
      itemBuilder: (context, index) {
        final dataPesan = data[index];
        String tanggalAsli = dataPesan['tanggal_kirim'];
        DateTime parsedDate = DateTime.parse(tanggalAsli);
        String formattedDate =
            DateFormat('EEEE, dd MMMM yyyy', 'id').format(parsedDate);
        return Wrap(
          children: [
            ClipOval(
              child: Container(
                height: 30,
                width: 30,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dataPesan['user_pengirim']['level'] == 'siswa'
                      ? 'Anda'
                      : dataPesan['user_pengirim']['level'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Card(
                color: Colors.blueAccent[100],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dataPesan['pesan'],
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      itemCount: data.length,
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 12);
      },
    );
  }
}
