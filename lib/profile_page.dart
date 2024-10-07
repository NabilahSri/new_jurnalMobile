import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jurnal_prakerin/component/bottomNavigationBar_custom.dart';
import 'package:jurnal_prakerin/component/button_custom.dart';
import 'package:jurnal_prakerin/component/snakcbar_custom.dart';
import 'package:jurnal_prakerin/component/textFormField_custom.dart';
import 'package:jurnal_prakerin/connection.dart';
import 'package:jurnal_prakerin/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nisnController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  File? _image;
  String foto = '';
  bool _isloading = false;
  bool _isloadingData = false;

  Future<void> showData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String? iduser = preferences.getString('id');
    log('keterangan id:$iduser');
    final response =
        await http.get(Uri.parse(connect().url + 'user/$iduser?token=$token'));
    if (response.statusCode == 200) {
      log('Data: ' + response.body);
      final responseData = jsonDecode(response.body)['user'];
      if (mounted) {
        setState(() {
          _nisnController.text = responseData['nisn'];
          _nameController.text = responseData['name'];
          _emailController.text = responseData['email'];
          _telpController.text = responseData['telp'];
          _alamatController.text = responseData['alamat'];
          foto = responseData['foto'] != null
              ? responseData['foto']
              : 'https://media.istockphoto.com/id/1337144146/vector/default-avatar-profile-icon-vector.jpg?s=612x612&w=0&k=20&c=BIbFwuv7FxTWvh5S3vB6bkT0Qv8Vn8N5Ffseq84ClGI=';
        });
      }
    } else {
      log('Data gagal diambil: ' + response.body);
    }
  }

  Future<void> editData() async {
    setState(() {
      _isloadingData = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String? idsiswa = preferences.getString('idsiswa');
    log('id siswa: ' + idsiswa.toString());
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(connect().url + 'user/editProfil/$idsiswa?token=$token'),
    );
    final fileValue = _image != null
        ? await http.MultipartFile.fromPath('foto', _image!.path)
        : null;
    request.fields['name'] = _nameController.text;
    request.fields['email'] = _emailController.text;
    request.fields['telp'] = _telpController.text;
    request.fields['alamat'] = _alamatController.text;
    if (fileValue != null) {
      request.files.add(fileValue);
    }

    try {
      var response = await request.send();
      if (response.statusCode == 201) {
        log('Data berhasil');
        if (mounted) {
          SnakcbarCustom.show(
              context,
              'Berhasil mengubah data',
              Colors.green[300]!,
              'Sukses',
              Icon(Icons.check, color: Colors.green));
        }
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => BottomnavigationbarCustom(id: 3)),
            (route) => false);
      } else {
        log('Data gagal');
        if (mounted) {
          SnakcbarCustom.show(context, 'Gagal mengubah data', Colors.red[300]!,
              'Gagal', Icon(Icons.check, color: Colors.red));
        }
      }
    } catch (e) {
      log('kesalahan server');
    }
    setState(() {
      _isloadingData = false;
    });
  }

  Future<void> logout() async {
    setState(() {
      _isloading = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String? iduser = preferences.getString('id');
    final response = await http
        .get(Uri.parse(connect().url + 'logout/$iduser?token=$token'));
    if (response.statusCode == 200) {
      log('Data: ' + response.body);
      SnakcbarCustom.show(
          context,
          "Masukan akun untuk kembali kedalam aplikasi",
          Colors.green,
          "Sukses",
          Icon(Icons.check, color: Colors.green));
      preferences.remove('token');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false);
    } else {
      log('Data gagal: ' + response.body);
      SnakcbarCustom.show(context, "Gagal melakukan logout", Colors.red[300]!,
          "Terjadi kesalahan", Icon(Icons.check, color: Colors.red));
    }
    setState(() {
      _isloading = false;
    });
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
                editData();
              },
              icon: _isloadingData
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
                'Profil',
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              profilContent(
                  Column(children: [
                    ClipOval(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: _image == null
                                ? NetworkImage(foto)
                                : FileImage(_image!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        bottomSheet(context);
                      },
                      child: Text('Upload foto'),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.lightBlueAccent),
                    )
                  ]),
                  'Foto'),
              profilContent(
                  TextformfieldCustom(
                    readOnly: true,
                    controller: _nisnController,
                  ),
                  'Nisn'),
              SizedBox(height: 12),
              profilContent(
                  TextformfieldCustom(
                    controller: _nameController,
                  ),
                  'Nama'),
              SizedBox(height: 12),
              profilContent(
                  TextformfieldCustom(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  'Email'),
              SizedBox(height: 12),
              profilContent(
                  TextformfieldCustom(
                    keyboardType: TextInputType.phone,
                    controller: _telpController,
                  ),
                  'No hp'),
              SizedBox(height: 12),
              profilContent(
                  TextformfieldCustom(
                    height: 150,
                    maxLines: 10,
                    controller: _alamatController,
                  ),
                  'Alamat'),
              SizedBox(height: 20),
              ButtonCustom(
                text: "Keluar",
                onPressedAction: () {
                  logout();
                },
                color: Colors.red,
                isLoading: _isloading,
              )
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
                'Foto Profil',
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
                          profileWithCamera();
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
                          profileWithGallery();
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

  void profileWithGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void profileWithCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Row profilContent(Widget content, String text) {
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
