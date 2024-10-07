import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jurnal_prakerin/component/bottomNavigationBar_custom.dart';
import 'package:jurnal_prakerin/component/button_custom.dart';
import 'package:jurnal_prakerin/component/snakcbar_custom.dart';
import 'package:jurnal_prakerin/connection.dart';
import 'package:jurnal_prakerin/setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationPage extends StatefulWidget {
  final String kunci_lokasi;
  const LocationPage({super.key, required this.kunci_lokasi});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  late GoogleMapController mapController;
  LatLng? _initialPosition;
  bool _isLoading = true;
  bool _isLoadingSetLocation = false;
  Marker? _marker;
  LatLng? _markerPosition;
  Future<void> _getUserLocation() async {
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

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );
    Position posisi =
        await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    double lat = posisi.latitude;
    double long = posisi.longitude;

    // Update the map position
    if (mounted) {
      setState(() {
        _initialPosition = LatLng(lat, long);
        _markerPosition = _initialPosition;
        _isLoading = false;
        _marker = Marker(
          markerId: MarkerId("currentLocation"),
          position: _initialPosition!,
          infoWindow: InfoWindow(title: "Lokasi Saat Ini"),
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _markerPosition = newPosition;
            });
          },
        );
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_initialPosition != null) {
      mapController.animateCamera(CameraUpdate.newLatLng(_initialPosition!));
    }
  }

  Future<void> setLocation(double latitude, double longitude) async {
    setState(() {
      _isLoadingSetLocation = true;
    });
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? token = shared.getString('token');
    String? iduser = shared.getString('id');
    final response = await http.post(
        Uri.parse(connect().url + 'user/aturLokasi/$iduser?token=$token'),
        body: {
          'lat': latitude.toString(),
          'long': longitude.toString(),
        });
    if (response.statusCode == 200) {
      if (widget.kunci_lokasi == "0") {
        log('berhasil');
        if (mounted) {
          SnakcbarCustom.show(
              context,
              'Lokasi berhaasil di set',
              Colors.green[300]!,
              'Berhasil',
              Icon(Icons.check, color: Colors.green));
        }
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => BottomnavigationbarCustom(id: 3)),
            (context) => false);
      } else {
        log('gagal');
        if (mounted) {
          SnakcbarCustom.show(
              context,
              "Lokasi terkunci, silahkan hubungi pemonitor",
              Colors.red[300]!,
              'Error',
              Icon(Icons.error, color: Colors.red));
        }
      }
    }
    setState(() {
      _isLoadingSetLocation = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Atur Lokasi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition!,
                    zoom: 15.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _marker != null ? {_marker!} : {},
                ),
                setlokasiContent()
              ],
            ),
    );
  }

  Positioned setlokasiContent() {
    return Positioned(
      bottom: 20,
      right: 20,
      left: 20,
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        "Latitude",
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text(
                        _markerPosition != null
                            ? _markerPosition!.latitude.toStringAsFixed(10)
                            : "Loading...",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Longitude",
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text(
                        _markerPosition != null
                            ? _markerPosition!.longitude.toStringAsFixed(10)
                            : "Loading...",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      )
                    ],
                  )
                ],
              ),
              Divider(),
              ButtonCustom(
                color: Colors.lightBlueAccent,
                text: "Set Lokasi",
                onPressedAction: () async {
                  await setLocation(
                      _markerPosition!.latitude, _markerPosition!.longitude);
                },
                isLoading: _isLoadingSetLocation,
              )
            ],
          ),
        ),
      ),
    );
  }
}
