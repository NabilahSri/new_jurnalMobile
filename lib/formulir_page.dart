import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jurnal_prakerin/component/bottomNavigationBar_custom.dart';
import 'package:jurnal_prakerin/component/snakcbar_custom.dart';
import 'package:jurnal_prakerin/component/textFormField_custom.dart';
import 'package:jurnal_prakerin/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormulirPage extends StatefulWidget {
  const FormulirPage({super.key});

  @override
  State<FormulirPage> createState() => _FormulirPageState();
}

class _FormulirPageState extends State<FormulirPage> {
  final TextEditingController _catatancontroller = TextEditingController();
  File? _image;
  bool _isloading = false;
  DateTime? pickedDate;
  String? selectedStatus;
  Future<void> addFormulir() async {
    setState(() {
      _isloading = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String? idsiswa = preferences.getString('idsiswa');
    String? iduser = preferences.getString('id');
    var request = http.MultipartRequest(
        'POST', Uri.parse(connect().url + 'formulir/add?token=$token'));
    final fileValue = _image != null
        ? await http.MultipartFile.fromPath('bukti', _image!.path)
        : null;
    final tanggalAsli = pickedDate!;
    request.fields['tanggal'] = DateFormat('yyyy-MM-dd').format(tanggalAsli);
    request.fields['status'] = selectedStatus.toString();
    request.fields['catatan'] = _catatancontroller.text;
    request.fields['id_siswa'] = idsiswa.toString();
    request.fields['id_user'] = iduser.toString();
    log(request.fields.toString());
    if (fileValue != null) {
      request.files.add(fileValue);
    }
    try {
      var response = await request.send();
      if (response.statusCode == 201) {
        log('berhasil');
        if (mounted) {
          SnakcbarCustom.show(
              context,
              'Berhasil menambah formulir',
              Colors.green[300]!,
              'Sukses',
              Icon(Icons.check, color: Colors.green));
        }
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => BottomnavigationbarCustom(id: 1)),
            (route) => false);
      } else {
        log('Gagal');
        if (mounted) {
          SnakcbarCustom.show(context, 'Gagal menambah formulir',
              Colors.red[300]!, 'Gagal', Icon(Icons.check, color: Colors.red));
        }
      }
    } catch (e) {
      log('kesalahan server');
    }
    setState(() {
      _isloading = false;
    });
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
                addFormulir();
              },
              icon: _isloading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Icon(
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
          padding: const EdgeInsets.only(right: 24, left: 24, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Formulir',
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              formulirContent(
                  Column(children: [
                    Container(
                      width: 100,
                      height: 80,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: _image == null
                              ? AssetImage('assets/images/profile.png')
                              : FileImage(_image!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        bottomSheet(context);
                      },
                      child: Text('Upload bukti'),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.lightBlueAccent),
                    )
                  ]),
                  'Bukti'),
              InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      print(picked);
                      setState(() {
                        pickedDate = picked;
                        log(pickedDate.toString());
                      });
                    }
                  },
                  child: formulirContent(
                      Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 7,
                            ),
                          ],
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(pickedDate == null
                              ? 'Pilih tanggal'
                              : DateFormat('yyyy-MM-dd').format(pickedDate!)),
                        ),
                      ),
                      'Tanggal')),
              SizedBox(height: 12),
              formulirContent(
                  Column(
                    children: [
                      Row(
                        children: [
                          Radio(
                              value: "sakit",
                              groupValue: selectedStatus,
                              onChanged: (value) async {
                                setState(() {
                                  selectedStatus = value;
                                  log(selectedStatus.toString());
                                });
                              }),
                          Text('Sakit')
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                              value: "izin",
                              groupValue: selectedStatus,
                              onChanged: (value) async {
                                setState(() {
                                  selectedStatus = value;
                                  log(selectedStatus.toString());
                                });
                              }),
                          Text('Izin')
                        ],
                      ),
                    ],
                  ),
                  'Status'),
              SizedBox(height: 12),
              formulirContent(
                  TextformfieldCustom(
                    height: 150,
                    maxLines: 10,
                    controller: _catatancontroller,
                  ),
                  'Catatan'),
            ],
          ),
        ),
      ),
    );
  }

  Future bottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 160,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 24.0, right: 24.0, top: 32.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Foto Bukti',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(167, 0, 0, 0),
                    fontSize: 20),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          formulirWithCamera();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.blue[100]),
                          child: Icon(
                            Icons.camera_alt,
                            size: 28,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Kamera'),
                    ],
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          formulirWithGallery();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.blue[100]),
                          child: Icon(
                            Icons.photo,
                            size: 28,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Galeri'),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void formulirWithGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void formulirWithCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Row formulirContent(Widget content, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Text(
          text,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        )),
        SizedBox(width: 20),
        Expanded(
          child: content,
          flex: 4,
        ),
      ],
    );
  }
}
