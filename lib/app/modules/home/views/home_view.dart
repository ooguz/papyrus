import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:papyrus/helpers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/home_controller.dart';
import 'package:about/about.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Papyrus'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () => Get.to(aboutPage),
                icon: const Icon(Icons.info))
          ],
        ),
        body: Obx(() => Stepper(
              currentStep: controller.currentStep.value,
              type: StepperType.horizontal,
              controlsBuilder: controller.controlsBuilder,
              steps: <Step>[
                Step(
                  title: const Text("Welcome!"),
                  content: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(50),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              getLogo(48),
                              AutoSizeText(
                                "Welcome to Papyrus!",
                                maxLines: 1,
                                style: Get.theme.textTheme.titleLarge,
                              ),
                              AutoSizeText(
                                "Papyrus is a paper backup tool that you can turn your text files into machine readable PDF files.",
                                textAlign: TextAlign.center,
                                style: Get.theme.textTheme.bodyLarge,
                              ),
                              AutoSizeText(
                                "You can use it to make hard copy backups for your GnuPG or SSH keys, password manager or 2FA backups etc. Papyrus will split your file into QR codes (with error correction) and lines of your file with checksums for each line. Finally you get a PDF file that you can print and keep in a safe place.",
                                textAlign: TextAlign.center,
                                style: Get.theme.textTheme.bodyLarge,
                              ),
                            ])),
                  ),
                  isActive: true,
                ),
                Step(
                  title: const Text("Configure"),
                  content: Obx(() => Column(
                        children: controller.loading.value
                            ? [
                                const CircularProgressIndicator(),
                                const Text("Creating PDF...")
                              ]
                            : [
                                Column(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.file_open),
                                      title: Text(controller.filename.value),
                                      subtitle: const Text("Selected file"),
                                    ),
                                    ListTile(
                                      leading:
                                          const Icon(Icons.document_scanner),
                                      title: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: ToggleButtons(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                            constraints: const BoxConstraints(
                                                minHeight: 36.0),
                                            isSelected:
                                                controller.paperSizeSelection,
                                            onPressed: (index) {
                                              controller.paperSizeSelection
                                                      .value =
                                                  controller.paperSizeSelection
                                                      .reversed
                                                      .toList();
                                            },
                                            children: const [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.0),
                                                child: Text('A4'),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.0),
                                                child: Text('Letter'),
                                              ),
                                            ],
                                          )),
                                      subtitle: const Text("Paper size"),
                                    ),
                                    ListTile(
                                      leading: Checkbox(
                                        value: controller.qrChecked.value,
                                        onChanged: (bool? value) =>
                                            controller.qrChecked.value = value!,
                                      ),
                                      title: const Text('Generate QR Page'),
                                      subtitle: const Text(
                                          "Recommended, this option adds machine readable QR code pages"),
                                    ),
                                    ListTile(
                                      leading: Checkbox(
                                          value: controller.ocrChecked.value,
                                          onChanged: (bool? value) => controller
                                              .ocrChecked.value = value!),
                                      title: const Text('Generate OCR Page'),
                                      subtitle: const Text(
                                          "Recommended, this option adds OCR readable text with checksums for each line"),
                                    ),
                                    ListTile(
                                      leading: Checkbox(
                                          value: controller.zebraChecked.value,
                                          onChanged: controller.zebra),
                                      enabled: controller.ocrChecked.value,
                                      title: const Text('Zebra-stripped table'),
                                      subtitle: const Text(
                                          "Make OCR page lines zebra stripped. It makes lines easy to follow by eye but may cause OCR errors."),
                                    ),
                                  ],
                                ),
                              ],
                      )),
                  isActive: true,
                ),
                Step(
                    title: const Text("Final"),
                    content: Center(
                      child: Padding(
                          padding: const EdgeInsets.all(50),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                getLogo(48),
                                AutoSizeText(
                                  "Et voilà!",
                                  maxLines: 1,
                                  style: Get.theme.textTheme.titleLarge,
                                ),
                                Obx(() => AutoSizeText(
                                      "Your PDF file is ready at ${controller.directoryToWrite.value}.",
                                      textAlign: TextAlign.center,
                                      style: Get.theme.textTheme.bodyLarge,
                                    )),
                                AutoSizeText(
                                  "Now, you can print your file by clicking on 'Print'.",
                                  textAlign: TextAlign.center,
                                  style: Get.theme.textTheme.bodyLarge,
                                ),
                                TextButton(
                                  onPressed: () async => await launchUrl(
                                      Uri.parse(
                                          "https://github.com/ooguz/papyrus")),
                                  child: AutoSizeText.rich(
                                    TextSpan(
                                        text:
                                            "If you are satisfied using Papyrus, please give us a star on GitHub ",
                                        style: Get.theme.textTheme.bodyLarge!.copyWith(decoration: TextDecoration.underline),
                                        children: [
                                          TextSpan(
                                              text: "💕",
                                              style: Get
                                                  .theme.textTheme.bodyLarge!)
                                        ]),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ])),
                    ),
                    isActive: true,
                    state: StepState.complete),
              ],
              onStepContinue: () => controller.currentStep.value++,
              onStepCancel: () => controller.currentStep.value--,
            )));
  }
}
