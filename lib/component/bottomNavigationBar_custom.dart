import 'package:flutter/material.dart';
import 'package:jurnal_prakerin/filter_activity.dart';
import 'package:jurnal_prakerin/home_page.dart';
import 'package:jurnal_prakerin/presensi_page.dart';
import 'package:jurnal_prakerin/setting_page.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class BottomnavigationbarCustom extends StatefulWidget {
  final int id;
  const BottomnavigationbarCustom({super.key, required this.id});

  @override
  State<BottomnavigationbarCustom> createState() =>
      _BottomnavigationbarCustomState();
}

class _BottomnavigationbarCustomState extends State<BottomnavigationbarCustom> {
  var index = 0;
  @override
  void initState() {
    super.initState();
    setState(() {
      index = widget.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black38)],
            color: Colors.blue,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: ClipRRect(
          child: SalomonBottomBar(
            selectedItemColor: Colors.white,
            unselectedItemColor: Color.fromARGB(255, 0, 1, 102),
            items: [
              SalomonBottomBarItem(
                icon: Icon(
                  Icons.home,
                  size: 18,
                ),
                title: Text("Utama"),
              ),
              SalomonBottomBarItem(
                icon: Icon(
                  Icons.fingerprint,
                  size: 18,
                ),
                title: Text("Kehadiran"),
              ),
              SalomonBottomBarItem(
                icon: Icon(
                  Icons.list,
                  size: 18,
                ),
                title: Text("Kegiatan"),
              ),
              SalomonBottomBarItem(
                icon: Icon(
                  Icons.settings,
                  size: 18,
                ),
                title: Text("Pengaturan"),
              )
            ],
            currentIndex: index,
            onTap: (selectedIndex) {
              setState(() {
                index = selectedIndex;
              });
            },
          ),
        ),
      ),
      body: Container(
          color: Colors.white, child: getSelectedWidget(index: index)),
    );
  }

  Widget getSelectedWidget({required int index}) {
    Widget widget;
    switch (index) {
      case 0:
        widget = const HomePage();
        break;
      case 1:
        widget = const PresensiPage();
        break;
      case 2:
        widget = const FilterActivityPage();
        break;
      case 3:
        widget = SettingPage();
        break;
      default:
        widget = const HomePage();
    }
    return widget;
  }
}
