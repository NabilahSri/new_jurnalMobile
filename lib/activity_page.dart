import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jurnal_prakerin/component/bottomNavigationBar_custom.dart';
import 'package:jurnal_prakerin/component/button_custom.dart';
import 'package:jurnal_prakerin/component/snakcbar_custom.dart';
import 'package:jurnal_prakerin/component/textFormField_custom.dart';
import 'package:jurnal_prakerin/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityPage extends StatefulWidget {
  final int id_kehadiran;
  const ActivityPage({super.key, required this.id_kehadiran});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _durasiController = TextEditingController();
  File? _image;
  bool _isloading = false;
  Future<void> addData() async {
    setState(() {
      _isloading = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String? idsiswa = preferences.getString('idsiswa');
    String? idkelas = preferences.getString('idkelas');
    var request = http.MultipartRequest(
        'POST', Uri.parse(connect().url + 'kegiatan/add?token=$token'));
    final fileValue = _image != null
        ? await http.MultipartFile.fromPath('foto', _image!.path)
        : null;
    request.fields['deskripsi'] = _namaController.text;
    request.fields['durasi'] = _durasiController.text;
    request.fields['id_kehadiran'] = widget.id_kehadiran.toString();
    request.fields['id_siswa'] = idsiswa.toString();
    request.fields['id_kelas'] = idkelas.toString();
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
              'Berhasil menambah kegiatan',
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
          SnakcbarCustom.show(context, 'Gagal menambah kegiatan',
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
                addData();
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Kegiatan',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              // Text('ID Kehadiran: ${widget.id_kehadiran}'),
              SizedBox(height: 40),
              kegiatanContent(
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
                      child: Text('Upload kegiatan'),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.lightBlueAccent),
                    )
                  ]),
                  'Foto'),
              SizedBox(height: 12),
              kegiatanContent(
                  TextformfieldCustom(
                    controller: _namaController,
                  ),
                  'Nama'),
              SizedBox(height: 12),
              kegiatanContent(
                  TextformfieldCustom(
                    controller: _durasiController,
                    labelText: 'dalam format menit',
                  ),
                  'Durasi'),
              SizedBox(height: 12),
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
                'Foto Kegiatan',
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

  Row kegiatanContent(Widget content, String text) {
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
