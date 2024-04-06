import 'dart:async';

import 'package:background_location/background_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:vibration/vibration.dart';
import 'package:workmanager/workmanager.dart';

void onStart() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  service.onDataReceived.listen((event) async {
    if (event["action"] == "setAsForeground") {
      service.setForegroundMode(true);
      return;
    }

    if (event["action"] == "setAsBackground") {
      service.setForegroundMode(false);
    }

    if (event["action"] == "stopService") {
      service.stopBackgroundService();
    }
  });

  Location _location;

  await BackgroundLocation.setAndroidNotification(
    title: "Location tracking is running in the background!",
    message: "You can turn it off from settings menu inside the app",
    icon: '@mipmap/ic_logo',
  );

  BackgroundLocation.startLocationService(distanceFilter: 20);

  BackgroundLocation.getLocationUpdates((location) {
    _location = location;
    prefs.setStringList("location", [location.latitude.toString(), location.longitude.toString()]);
  });

  String screenShake = "Be strong, We are with you!";
  ShakeDetector.autoStart(
    shakeThresholdGravity: 7,
    onPhoneShake: () async {
      if (await Vibration.hasVibrator()) {
        if (await Vibration.hasCustomVibrationsSupport()) {
          Vibration.vibrate(duration: 1000);
        } else {
          Vibration.vibrate();
          await Future.delayed(Duration(milliseconds: 500));
          Vibration.vibrate();
        }
      }
      String link = '';
      try {
        double? lat = _location.latitude;
        double? long = _location.longitude;
        link = "http://maps.google.com/?q=$lat,$long";
        List<String> numbers = prefs.getStringList("numbers") ?? [];
        String error;
        if (numbers.isEmpty) {
          screenShake = "No contacts found, Please call 15 ASAP.";
          debugPrint('No Contacts Found!');
          return;
        } else {
          for (int i = 0; i < numbers.length; i++) {
            Telephony.backgroundInstance.sendSms(to: numbers[i], message: "Help Me! Track me here.\n$link");
          }
          prefs.setBool("alerted", true);
          screenShake = "SOS alert Sent! Help is on the way.";
        }
        print(link);
      } catch (e) {
        print(e);
      }
    },
  );

  service.setForegroundMode(true);

  Timer.periodic(Duration(seconds: 1), (timer) async {
    if (!(await service.isServiceRunning())) timer.cancel();

    service.setNotificationInfo(
      title: "Safe Shake activated!",
      content: screenShake,
    );

    service.sendData(
      {"current_date": DateTime.now().toIso8601String()},
    );
  });
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    String contact = inputData!['contact'];
    final prefs = await SharedPreferences.getInstance();
    List<String>? location = prefs.getStringList("location");
    String link = "http://maps.google.com/?q=${location![0]},${location[1]}";
    Telephony.backgroundInstance.sendSms(to: contact, message: "I am on my way! Track me here.\n$link");
    return true;
  });
}
