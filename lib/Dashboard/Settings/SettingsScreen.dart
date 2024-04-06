import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:vibration/vibration.dart';
import 'package:workmanager/workmanager.dart';

import '../../background_services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool switchValue = false;

  @override
  void initState() {
    super.initState();
    checkService();
  }

  @override
  Widget build(BuildContext context) {
    // Your existing build method code
  }

  Future<void> checkService() async {
    bool running = await FlutterBackgroundService().isServiceRunning();
    setState(() {
      switchValue = running;
    });
  }

  void controlSafeShake(bool val) async {
    if (val) {
      FlutterBackgroundService.initialize(onStart);
    } else {
      FlutterBackgroundService().sendData({
        "action": "stopService",
      });
    }
  }

  void getHomeSafe(String contact) {
    Workmanager().registerOneOffTask(
      "getHomeSafeTask",
      "getHomeSafe",
      inputData: {"contact": contact},
      initialDelay: Duration(minutes: 15),
    );
  }
}
