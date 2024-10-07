import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jurnal_prakerin/activity_page.dart';
import 'package:jurnal_prakerin/component/button_custom.dart';
import 'package:jurnal_prakerin/connection.dart';
import 'package:jurnal_prakerin/filter_history_presensi.dart';
import 'package:jurnal_prakerin/formulir_page.dart';
import 'package:badges/badges.dart' as badges;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class PresensiPage extends StatefulWidget {
  const PresensiPage({super.key});

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(),
              SizedBox(height: 75),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Kehadiran terbaru",
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              listView(),
            ],
          ),
          container(),
        ],
      ),
    );
  }
}

class container extends StatefulWidget {
  const container({
    super.key,
  });

  @override
  State<container> createState() => _containerState();
}

class _containerState extends State<container> {
  String jam_masuk = '-';
  String jam_pulang = '-';
  String token_masuk = '';
  String token_keluar = '';
  bool masuk = false;
  bool pulang = false;

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log('Layanan lokasi tidak diaktifkan.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      log('Izin lokasi ditolak secara permanen!');
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        log('Izin lokasi ditolak!');
      }
    }
  }

  Future<Object?> _inisialisasiMode() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('mode') != null) {
      return sharedPreferences.getString('mode');
    } else {
      return sharedPreferences.setString('mode', 'Lokasi');
    }
  }

  Future<void> kirimMasuk() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? token = shared.getString('token');
    String? idsiswa = shared.getString('idsiswa');
    String? iduser = shared.getString('id');
    String? modeKehadiran = shared.getString('mode');
    if (modeKehadiran == "Token" && token_masuk.isEmpty) {
      showTokenDialog(true);
      return;
    }
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );
    Position posisi =
        await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    String lat = posisi.latitude.toString();
    String long = posisi.longitude.toString();

    jam_masuk = DateFormat('HH:mm:ss').format(DateTime.now());
    String tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
    log(modeKehadiran.toString());
    final response = await http
        .post(Uri.parse(connect().url + 'kehadiran/masuk?token=$token'), body: {
      'lat': lat,
      'long': long,
      'tanggal': tanggal,
      'jam_masuk': jam_masuk,
      'status': 'hadir',
      'id_siswa': idsiswa.toString(),
      'id_user': iduser.toString(),
      'mode': modeKehadiran,
      'token_masuk': token_masuk
    });
    log(token_masuk);
    if (response.statusCode == 201) {
      log('berhasil');
      log(response.body);
      setState(() {
        masuk = true;
        jam_masuk;
      });
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString('jam_masuk', jam_masuk);
      await sharedPreferences.setBool('masuk', masuk);
      await sharedPreferences.setString('tanggal', tanggal);
    } else {
      log('gagal');
      log(response.statusCode.toString());
      log(response.body);
    }
  }

  Future<void> kirimPulang() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? token = shared.getString('token');
    String? modeKehadiran = shared.getString('mode');
    if (modeKehadiran == "Token" && token_keluar.isEmpty) {
      showTokenDialog(false);
      return;
    }
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );
    Position posisi =
        await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    String lat = posisi.latitude.toString();
    String long = posisi.longitude.toString();

    jam_pulang = DateFormat('HH:mm:ss').format(DateTime.now());
    String tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await http.post(
        Uri.parse(connect().url + 'kehadiran/pulang?token=$token'),
        body: {
          'lat': lat,
          'long': long,
          'tanggal': tanggal,
          'jam_pulang': jam_pulang,
          'status': 'hadir',
          'mode': modeKehadiran,
          'token_keluar': token_keluar
        });
    if (response.statusCode == 201) {
      log('berhasil');
      log(response.body);
      setState(() {
        pulang = true;
        jam_pulang;
      });
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString('jam_pulang', jam_pulang);
      await sharedPreferences.setBool('pulang', pulang);
    } else {
      log('gagal');
      log(response.statusCode.toString());
      log(response.body);
    }
  }

  Future<void> _cekTanggalDanResetJamMasuk() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? tanggal = sharedPreferences.getString('tanggal');
    String? idsiswa = sharedPreferences.getString('idsiswa');
    String tanggal_hari_ini = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Jika tanggal berbeda dengan tanggal hari ini, reset jam_masuk
    if (tanggal != tanggal_hari_ini) {
      setState(() {
        jam_masuk = '-';
        jam_pulang = '-';
        masuk = false;
        pulang = false;
      });
      await sharedPreferences.setString('jam_masuk', '-');
      await sharedPreferences.setBool('masuk', false);
      await sharedPreferences.setString('jam_pulang', '-');
      await sharedPreferences.setBool('pulang', false);
    }
  }

  Future<void> _ambilJamMasuk() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      jam_masuk = sharedPreferences.getString('jam_masuk') ?? '-';
      masuk = sharedPreferences.getBool('masuk') ?? false;
      jam_pulang = sharedPreferences.getString('jam_pulang') ?? '-';
      pulang = sharedPreferences.getBool('pulang') ?? false;
    });
  }

  Future<void> showTokenDialog(bool masuk) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          title: Text(
            masuk ? 'Masukkan Token Masuk' : 'Masukkan Token Pulang',
            style: TextStyle(fontSize: 16),
          ),
          content: OtpTextField(
            focusedBorderColor: Colors.blue,
            numberOfFields: 5,
            borderColor: Colors.blue,
            showFieldAsBox: true,
            onSubmit: (String verificationCode) {
              if (masuk) {
                setState(() {
                  token_masuk = verificationCode;
                });
                log(token_masuk);
                kirimMasuk();
                Navigator.pop(context);
              } else {
                setState(() {
                  token_keluar = verificationCode;
                });
                log(token_keluar);
                kirimPulang();
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _inisialisasiMode();
    _determinePosition();
    _cekTanggalDanResetJamMasuk();
    _ambilJamMasuk();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 170, // Sesuaikan posisi kotak mengambang
      left: 20,
      right: 20,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        "Jam Masuk",
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text(
                        jam_masuk,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Jam Pulang",
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text(jam_pulang,
                          style: TextStyle(color: Colors.grey, fontSize: 16))
                    ],
                  )
                ],
              ),
              Divider(),
              ButtonCustom(
                text: masuk ? (pulang ? "Selesai" : "Pulang") : "Masuk",
                onPressedAction: pulang
                    ? () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Kehadiran Selesai"),
                              content: Text(
                                  "Silahkan registrasi kembali kehadiran esok hari."),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    : () {
                        if (!masuk) {
                          kirimMasuk();
                        } else {
                          kirimPulang();
                        }
                      },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class listView extends StatefulWidget {
  const listView({
    super.key,
  });

  @override
  State<listView> createState() => _listViewState();
}

class _listViewState extends State<listView> {
  Future<void> _refreshPage() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      showKehadiran();
    });
  }

  List<dynamic> data = [];
  Future<void> showKehadiran() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String? idsiswa = preferences.getString('idsiswa');
    final response = await http
        .get(Uri.parse(connect().url + 'kehadiran/show/$idsiswa?token=$token'));

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body)['kehadiran'];
      });
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
    return Expanded(
      child: RefreshIndicator(
        onRefresh: _refreshPage,
        child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            final datakehadiran = data[index];
            String tanggalAsli = datakehadiran['tanggal'];
            DateTime parsedDate = DateTime.parse(tanggalAsli);
            String formattedDate =
                DateFormat('EEEE, dd MMMM yyyy', 'id').format(parsedDate);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: InkWell(
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
                              color: Colors.blue, fontWeight: FontWeight.bold),
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
                              color: Colors.grey, fontWeight: FontWeight.bold),
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
                              color: Colors.grey, fontWeight: FontWeight.bold),
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
                    status(datakehadiran),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
          itemCount: data.length,
        ),
      ),
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

  Row status(datakehadiran) {
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
}

class AppBar extends StatefulWidget {
  const AppBar({
    super.key,
  });

  @override
  State<AppBar> createState() => _AppBarState();
}

class _AppBarState extends State<AppBar> {
  String _timeString = '';
  String _dateString = '';
  Timer? _timer;
  void _getCurrentTime() {
    if (mounted) {
      final DateTime now = DateTime.now();
      final String formattedTime = DateFormat('HH:mm:ss').format(now);
      final String formattedDate =
          DateFormat('EEEE, dd MMMM yyyy', 'id').format(now);

      setState(() {
        _timeString = formattedTime;
        _dateString = formattedDate;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id', null).then((_) {
      _getCurrentTime();
      _timer =
          Timer.periodic(Duration(seconds: 1), (Timer t) => _getCurrentTime());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
      height: 250,
      width: double.infinity,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30)),
          gradient: LinearGradient(
              colors: [Colors.blue, Color.fromARGB(255, 220, 237, 252)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => FormulirPage()));
                },
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 141, 199, 247)),
                  child: Icon(
                    Icons.note_add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FilterHistoryPresensi()));
                },
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 141, 199, 247)),
                  child: Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Kehadiran langsung',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          Text(
            _timeString,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            _dateString,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
