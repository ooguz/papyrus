import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
