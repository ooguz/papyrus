import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

final darkTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.purple,
    brightness: Brightness.dark);

void main() {
  runApp(
    GetMaterialApp(
      title: "Papyrus",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      themeMode: ThemeMode.dark,
    ),
  );
}
