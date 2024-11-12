import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jurnal_prakerin/component/button_custom.dart';
import 'package:jurnal_prakerin/component/snakcbar_custom.dart';
import 'package:jurnal_prakerin/list_activity.dart';

class FilterActivityPage extends StatefulWidget {
  const FilterActivityPage({super.key});

  @override
  State<FilterActivityPage> createState() => _FilterActivityPageState();
}

class _FilterActivityPageState extends State<FilterActivityPage> {
  DateTime? tanggalAwal;
  DateTime? tanggalAkhir;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Colors.blue),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                      tanggalAwal = picked;
                    });
                    log(tanggalAwal.toString());
                  }
                },
                child: Container(
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
                    child: Text(tanggalAwal == null
                        ? 'Tanggal Awal'
                        : DateFormat('yyyy-MM-dd').format(tanggalAwal!)),
                  ),
                ),
              ),
              SizedBox(height: 12),
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
                      tanggalAkhir = picked;
                    });
                    log(tanggalAkhir.toString());
                  }
                },
                child: Container(
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
                    child: Text(tanggalAkhir == null
                        ? 'Tanggal Akhir'
                        : DateFormat('yyyy-MM-dd').format(tanggalAkhir!)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ButtonCustom(
                  text: "Cari",
                  onPressedAction: () {
                    if (tanggalAwal == null) {
                      if (mounted) {
                        SnakcbarCustom.show(
                            context,
                            'Tanggal awal belum dipilih',
                            Colors.red[300]!,
                            'Gagal',
                            Icon(Icons.error, color: Colors.red));
                      }
                    } else if (tanggalAkhir == null) {
                      if (mounted) {
                        SnakcbarCustom.show(
                            context,
                            'Tanggal akhir belum dipilih',
                            Colors.red[300]!,
                            'Gagal',
                            Icon(Icons.error, color: Colors.red));
                      }
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListActivityPage(
                                  tanggal_awal: DateFormat('yyyy-MM-dd')
                                      .format(tanggalAwal!)
                                      .toString(),
                                  tanggal_akhir: DateFormat('yyyy-MM-dd')
                                      .format(tanggalAkhir!)
                                      .toString())));
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
