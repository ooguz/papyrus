import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_test/getx_test.dart';
import 'package:papyrus/app/modules/home/controllers/home_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  getTest("Route test", widgetTest: (tester) async {
    expect('/', Get.currentRoute);
  });
  testObx(
    'Stepper test',
    widget: (controller) => Obx(
      () => Text("Step:${controller.currentStep.value}"),
    ),
    controller: HomeController(),
    test: (e) {
      expect(find.text("Step:0"), findsOneWidget);
      expect(e.currentStep.value, 0);
      e.currentStep.value = 1;
      expect(e.currentStep.value, 1);
    },
  );
}
