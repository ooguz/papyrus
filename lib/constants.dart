import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class Constants {
  static const lightIcon = Icon(Icons.light_mode);
  static const darkIcon = Icon(Icons.dark_mode);
  static const themeSwitcherIcons = <Icon>[lightIcon, darkIcon];
}

class Fonts {
  late Courier courier;
  late Roboto roboto;

  static Future<Fonts> load() async {
    Fonts fonts = Fonts();
    fonts.roboto = await Roboto.load();
    fonts.courier = await Courier.load();
    return fonts;
  }
}

class Courier {
  late ByteData regular;
  late ByteData bold;

  static Future<Courier> load() async {
    Courier courier = Courier();
    courier.regular =
        await rootBundle.load("assets/courier/CourierPrime-Regular.ttf");
    courier.bold =
        await rootBundle.load("assets/courier/CourierPrime-Bold.ttf");
    return courier;
  }
}

class Roboto {
  late ByteData light;
  late ByteData regular;
  late ByteData medium;
  late ByteData bold;
  late ByteData italic;
  late ByteData bolditalic;

  static Future<Roboto> load() async {
    Roboto roboto = Roboto();
    roboto.light = await rootBundle.load("assets/roboto/Roboto-Light.ttf");
    roboto.regular = await rootBundle.load("assets/roboto/Roboto-Regular.ttf");
    roboto.medium = await rootBundle.load("assets/roboto/Roboto-Medium.ttf");
    roboto.bold = await rootBundle.load("assets/roboto/Roboto-Bold.ttf");
    roboto.italic = await rootBundle.load("assets/roboto/Roboto-Italic.ttf");
    roboto.bolditalic =
        await rootBundle.load("assets/roboto/Roboto-BoldItalic.ttf");

    return roboto;
  }
}

enum FileResult { success, permission, encoding, unknown }
