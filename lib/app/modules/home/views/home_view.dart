import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Papyrus'),
          centerTitle: true,
          actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.info))],
        ),
        body: Obx(() => Stepper(
              currentStep: controller.currentStep.value,
              type: StepperType.horizontal,
              controlsBuilder: controller.controlsBuilder,
              steps: controller.steps,
              onStepContinue: () => controller.currentStep.value++,
              onStepCancel: () => controller.currentStep.value--,
            )));
  }
}
