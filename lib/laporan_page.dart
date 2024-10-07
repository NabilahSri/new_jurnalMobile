import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:jurnal_prakerin/component/bottomNavigationBar_custom.dart';
import 'package:jurnal_prakerin/component/snakcbar_custom.dart';
import 'package:jurnal_prakerin/component/textFormField_custom.dart';
import 'package:jurnal_prakerin/connection.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  Future<void> showData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String? iduser = preferences.getString('id');
    final response =
        await http.get(Uri.parse(connect().url + 'user/$iduser?token=$token'));
    if (response.statusCode == 200) {
      log('Data: ' + response.body);
      final responseData = jsonDecode(response.body)['user'];
      setState(() {
        _subjectController.text =
            responseData['name'] + ' - ' + responseData['telp'];
      });
    } else {
      log('Data gagal diambil: ' + response.body);
    }
  }

  sendEmail(String subject, String body) async {
    final Email email = Email(
      body: body,
      subject: subject,
      recipients: ['billb4721@gmail.com'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => BottomnavigationbarCustom(id: 3)),
        (route) => false);
    SnakcbarCustom.show(context, 'Masalah berhasil di laporkan',
        Colors.green[300]!, 'Sukses', Icon(Icons.check, color: Colors.green));
  }

  @override
  void initState() {
    showData();
    super.initState();
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
                sendEmail(_subjectController.text, _bodyController.text);
              },
              icon: Icon(
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
                'Laporkan masalah',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              laporanContetn(
                  TextformfieldCustom(
                    controller: _subjectController,
                    readOnly: true,
                  ),
                  'Subject'),
              SizedBox(height: 12),
              laporanContetn(
                  TextformfieldCustom(
                    controller: _bodyController,
                    height: 150,
                    maxLines: 10,
                  ),
                  'Masalah'),
            ],
          ),
        ),
      ),
    );
  }

  Row laporanContetn(Widget content, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Text(
          text,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        )),
        SizedBox(width: 19),
        Expanded(
          child: content,
          flex: 4,
        ),
      ],
    );
  }
}
