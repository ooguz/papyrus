import 'package:about/about.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:papyrus/pubspec.dart';
import 'package:url_launcher/url_launcher.dart';

Widget getLogo(double size) => SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: size,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings_backup_restore,
                size: size / 2,
                color: Get.isDarkMode
                    ? Get.theme.colorScheme.onBackground
                    : Get.theme.iconTheme.color,
              ),
            ),
          ),
        ],
      ),
    );

AboutPage aboutPage = AboutPage(
  values: {
    'version': Pubspec.version,
    'buildNumber': Pubspec.versionBuild.toString(),
    'year': DateTime.now().year.toString(),
    'author': "Özcan Oğuz",
  },
  title: const Text('About Papyrus'),
  applicationVersion: 'Version {{ version }}, build #{{ buildNumber }}',
  applicationDescription: const Text(
    Pubspec.description,
    textAlign: TextAlign.justify,
  ),
  applicationIcon: Image.asset(
    "assets/logo.png",
    width: 64,
    height: 64,
  ),
  applicationLegalese: 'Copyright © {{ year }} {{ author }}',
  children: <Widget>[
    ListTile(
      title: const Text("Source code (on GitHub)"),
      leading: const Icon(Icons.code),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => launchUrl(Uri.parse("https://github.com/ooguz/papyrus")),
    ),
    const MarkdownPageListTile(
      filename: 'README.md',
      title: Text('View README'),
      icon: Icon(Icons.all_inclusive),
    ),
    const MarkdownPageListTile(
      filename: 'CHANGELOG.md',
      title: Text('View changelog'),
      icon: Icon(Icons.view_list),
    ),
    const MarkdownPageListTile(
      filename: 'LICENSE',
      title: Text('View license (GNU GPL v3+)'),
      icon: Icon(Icons.description),
    ),
    const LicensesPageListTile(
      title: Text('Free software licenses'),
      icon: Icon(Icons.favorite),
    ),
  ],
);
