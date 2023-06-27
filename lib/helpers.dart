import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget getLogo(double size) => SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.description_outlined,
            size: 48,
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
                color: Get.isDarkMode
                    ? Get.theme.colorScheme.onBackground
                    : Get.theme.iconTheme.color,
              ),
            ),
          ),
        ],
      ),
    );
