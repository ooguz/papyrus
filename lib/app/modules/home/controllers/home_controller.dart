import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:papyrus_neo/constants.dart';
import 'package:papyrus_neo/helpers.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:crypto/crypto.dart';
import 'package:printing/printing.dart';

import 'package:file_picker/file_picker.dart';

class HomeController extends GetxController {
  List<String> qrStrings = [];
  List<pw.Column> qrColumns = [];
  List<String> fileLines = [];
  final filename = "".obs;
  late Fonts fonts;
  List<List<String>> hashes = [
    ['Line', 'SHA256']
  ];
  late pw.ThemeData pdfTheme;
  var paperSizeSelection = <bool>[true, false].obs;
  final qrChecked = true.obs;
  final ocrChecked = true.obs;
  final currentStep = 0.obs;
  String? directoryToWrite;
  late pw.Document pdf;

  @override
  void onInit() async {
    fonts = await Fonts.load();
    pdfTheme = pw.ThemeData.withFont(
      base: pw.Font.ttf(fonts.roboto.regular),
      bold: pw.Font.ttf(fonts.roboto.bold),
      italic: pw.Font.ttf(fonts.roboto.italic),
      boldItalic: pw.Font.ttf(fonts.roboto.bolditalic),
    );

    pdf = pw.Document(
        creator: 'Papyrus',
        subject: 'Paper Backup',
        producer: 'Papyrus - https://github.com/ooguz/papyrus',
        theme: pdfTheme);
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  late final steps = <Step>[
    Step(
      title: Text("Welcome!"),
      content: Center(
        child: Padding(
            padding: EdgeInsets.all(50),
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
      title: Text("Configure"),
      content: Column(
        children: [
          Container(
            child: Column(
              children: [
                Obx(() => Text('Seçilen dosya: ${filename.value}')),
                ElevatedButton(
                    onPressed: () async {
                      String? selectedDirectory =
                          await FilePicker.platform.saveFile(
                        dialogTitle: 'Please select an output file:',
                        fileName: 'paper-backup.pdf',
                      );
                      directoryToWrite = selectedDirectory;
                    },
                    child: Text('Dosyanın kaydedileceği yeri seçin')),
                Obx(() => ToggleButtons(
                      borderRadius: BorderRadius.circular(4.0),
                      constraints: BoxConstraints(minHeight: 36.0),
                      isSelected: paperSizeSelection,
                      onPressed: (index) {
                        paperSizeSelection.value =
                            paperSizeSelection.reversed.toList();
                      },
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('A4'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Letter'),
                        ),
                      ],
                    )),
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: qrChecked.value,
                          onChanged: (bool? value) => qrChecked.value = value!,
                        ),
                        const Text('Generate QR Page'),
                      ],
                    )),
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                            value: ocrChecked.value,
                            onChanged: (bool? value) =>
                                ocrChecked.value = value!),
                        const Text('Generate OCR Page'),
                      ],
                    ))
              ],
            ),
          ),
        ],
      ),
      isActive: true,
    ),
    Step(
        title: Text("Final"),
        content: Text("content3"),
        isActive: true,
        state: StepState.complete),
  ];

  Future<bool> filePicker() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles();
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
    if (result != null) {
      PlatformFile file = result.files.first;
      try {
        await readFile(file.path!);
      } catch (e) {
        debugPrint(e.toString());
        return false;
      }
      filename.value = file.path!;
      return true;
    } else {
      return false;
    }
  }

  Future<void> readFile(String path) async {
    int qr_size = 1024;
    File file = File(path);
    String contents;
    List<String> lines;
    try {
      contents = await file.readAsString();
      lines = await file.readAsLines();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
    int modulo = contents.length % qr_size;
    int total_codes = (contents.length / qr_size).round();
    int position = 0;
    for (int i = 1; i <= total_codes; i++) {
      String identifier = '${i - 1}' '~';
      if (i != total_codes) {
        String qrString = contents.substring(position, i * qr_size);
        qrStrings.add('$identifier$qrString');
        position = i * qr_size + 1;
      } else {
        String qrString = contents.substring(position, position + modulo - 1);
        qrStrings.add('$identifier$qrString');
      }
    }
    for (var element in lines) {
      fileLines.add(element);
    }
    /* for (var element in qrStrings) {
      print(element);
      print('------------------');
    } */
  }

  void _genHashes() {
    for (var element in fileLines) {
      List<int> bytes = utf8.encode(element);
      Digest hash = sha256.convert(bytes);
      String hashToDisplay = hash.toString().substring(0, 8);
      List<String> elementToAdd = [element, hashToDisplay];
      hashes.add(elementToAdd);
    }
  }

  void generatePdf(
      {required String path,
      bool qrCodes = true,
      bool ocrText = true,
      bool letterPaper = false}) async {
    final pageFormat =
        letterPaper == false ? PdfPageFormat.a4 : PdfPageFormat.letter;
    if (qrCodes = true) {
      _genHashes();
      for (var element in qrStrings) {
        final qrColumn = pw.Column(
          children: [
            pw.BarcodeWidget(
                width: 220,
                height: 220,
                barcode: pw.Barcode.qrCode(
                    errorCorrectLevel: pw.BarcodeQRCorrectionLevel.high),
                data: element),
            pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                    '${qrStrings.indexOf(element) + 1}/${qrStrings.length}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))
          ],
        );
        qrColumns.add(qrColumn);
      }

      pdf.addPage(pw.MultiPage(
          pageFormat: pageFormat,
          header: (pw.Context context) {
            return pw.Container(
                alignment: pw.Alignment.centerRight,
                margin:
                    const pw.EdgeInsets.only(bottom: 6.0 * PdfPageFormat.mm),
                padding:
                    const pw.EdgeInsets.only(bottom: 6.0 * PdfPageFormat.mm),
                decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        bottom:
                            pw.BorderSide(width: 0.5, color: PdfColors.grey))),
                child: pw.Text('QR codes',
                    style: pw.Theme.of(context).defaultTextStyle.copyWith(
                        color: PdfColors.black,
                        font: pw.Font.ttf(fonts.roboto.regular))));
          },
          footer: (pw.Context context) {
            return pw.Container(
                alignment: pw.Alignment.center,
                margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
                child: pw.Text('${context.pageNumber} / ${context.pagesCount}',
                    style: pw.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(color: PdfColors.black)));
          },
          build: (pw.Context context) => [
                pw.Wrap(
                    children: qrColumns,
                    spacing: 30,
                    runSpacing: 30,
                    alignment: pw.WrapAlignment.center),
              ]));
    }
    if (ocrText == true) {
      pdf.addPage(pw.MultiPage(
          header: (pw.Context context) {
            return pw.Container(
                alignment: pw.Alignment.centerRight,
                margin:
                    const pw.EdgeInsets.only(bottom: 6.0 * PdfPageFormat.mm),
                padding:
                    const pw.EdgeInsets.only(bottom: 6.0 * PdfPageFormat.mm),
                decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        bottom:
                            pw.BorderSide(width: 0.5, color: PdfColors.grey))),
                child: pw.Text('Lines',
                    style: pw.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(color: PdfColors.black)));
          },
          footer: (pw.Context context) {
            return pw.Container(
                alignment: pw.Alignment.center,
                margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
                child: pw.Text('${context.pageNumber} / ${context.pagesCount}',
                    style: pw.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(color: PdfColors.black)));
          },
          build: (pw.Context context) => [
                pw.TableHelper.fromTextArray(
                  data: hashes,
                  border: pw.TableBorder.all(style: pw.BorderStyle.none),
                  cellStyle: pw.TextStyle(
                      font: pw.Font.ttf(fonts.courier.regular),
                      fontSize: 10,
                      lineSpacing: 0),
                  cellPadding: const pw.EdgeInsets.all(0),
                  headerStyle:
                      pw.TextStyle(font: pw.Font.ttf(fonts.courier.bold)),
                )
              ]));
    }
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
  }

  Widget controlsBuilder(BuildContext context, ControlsDetails details) {
    String nextLabel;
    IconData nextIcon;
    void Function()? nextAction;
    switch (details.currentStep) {
      case 0:
        nextLabel = "Choose file";
        nextIcon = Icons.file_open;
        nextAction = () async {
          final result = await filePicker();
          if (!result) {
            Get.snackbar("Error", "File could not be opened",
                margin: EdgeInsets.all(15),
                snackPosition: SnackPosition.BOTTOM);
            return;
          }
          details.onStepContinue!();
        };
      case 1:
        nextLabel = "Build PDF";
        nextIcon = Icons.picture_as_pdf;
        nextAction = () async {
          generatePdf(
              path: directoryToWrite!,
              qrCodes: qrChecked.value,
              ocrText: ocrChecked.value,
              letterPaper: paperSizeSelection[0]);
          details.onStepContinue!();
        };
      case 2:
        nextLabel = "Print";
        nextIcon = Icons.print;
        nextAction = () async {
          await Printing.layoutPdf(
              onLayout: (PdfPageFormat format) async => pdf.save());
        };
      default:
        nextLabel = "Next";
        nextIcon = Icons.arrow_forward;
        nextAction = () {
          details.onStepContinue!();
        };
    }

    return Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            details.currentStep != 0
                ? ElevatedButton.icon(
                    onPressed: details.onStepCancel,
                    icon: Icon(Icons.arrow_back),
                    label: Text("Back"),
                  )
                : Center(),
            ElevatedButton.icon(
              onPressed: nextAction,
              icon: Icon(nextIcon),
              label: Text(nextLabel),
            ),
          ],
        ));
  }
}
