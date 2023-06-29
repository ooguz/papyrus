import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:papyrus/constants.dart';
import 'package:papyrus/helpers.dart';
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
  final directoryToWrite = ".".obs;
  late pw.Document pdf;

  final loading = false.obs;

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

  Future<FileResult> filePicker() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles();
    } catch (e) {
      debugPrint(e.toString());
      return FileResult.unknown;
    }
    if (result != null) {
      PlatformFile file = result.files.first;
      try {
        await readFile(file.path!);
      } on PathAccessException catch (e) {
        debugPrint(e.toString());
        return FileResult.permission;
      } on FileSystemException catch (e) {
        debugPrint(e.message.toString());
        if (e.message.contains("encoding")) {
          return FileResult.encoding;
        }
        return FileResult.unknown;
      } catch (e) {
        debugPrint(e.toString());
        return FileResult.unknown;
      }
      filename.value = file.path!;
      return FileResult.success;
    } else {
      return FileResult.unknown;
    }
  }

  Future<void> readFile(String path) async {
    int qrSize = 1024;
    File file = File(path);
    String contents;
    List<String> lines;
    try {
      contents = await file.readAsString();
      lines = await file.readAsLines();
    } catch (e) {
      rethrow;
    }
    int modulo = contents.length % qrSize;
    int totalCodes = (contents.length / qrSize).round();
    int position = 0;
    for (int i = 1; i <= totalCodes; i++) {
      String identifier = '${i - 1}' '~';
      if (i != totalCodes) {
        String qrString = contents.substring(position, i * qrSize);
        qrStrings.add('$identifier$qrString');
        position = i * qrSize + 1;
      } else {
        String qrString = contents.substring(position, position + modulo - 1);
        qrStrings.add('$identifier$qrString');
      }
    }
    for (var element in lines) {
      fileLines.add(element);
    }
  }

  void _genHashes() {
    for (var element in fileLines) {
      Digest hash = sha256.convert(utf8.encode(element));
      hashes.add([element, hash.toString().substring(0, 8)]);
    }
  }

  void generatePdf(
      {required String path,
      bool qrCodes = true,
      bool ocrText = true,
      bool letterPaper = false}) async {
    final pageFormat =
        letterPaper == false ? PdfPageFormat.a4 : PdfPageFormat.letter;
    if (qrCodes) {
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
      _genHashes();

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
    Widget backButton = ElevatedButton.icon(
      onPressed: details.onStepCancel,
      icon: const Icon(Icons.arrow_back),
      label: const Text("Back"),
    );
    switch (details.currentStep) {
      case 0:
        nextLabel = "Choose file";
        nextIcon = Icons.file_open;
        nextAction = () async {
          final result = await filePicker();
          if (result != FileResult.success) {
            String message;
            switch (result) {
              case FileResult.encoding:
                message = "Only text files are supported";
                break;
              case FileResult.permission:
                message = "File could not be opened, permission denied";
                break;
              default:
                message = "File could not be opened, unknown error has occured";
            }
            Get.snackbar("Error", message,
                margin: const EdgeInsets.all(15),
                snackPosition: SnackPosition.BOTTOM);
            return;
          }
          details.onStepContinue!();
        };
        backButton = const Center();
      case 1:
        nextLabel = "Build PDF";
        nextIcon = Icons.picture_as_pdf;
        nextAction = () async {
          loading.value = true;

          String? selectedDirectory = await FilePicker.platform.saveFile(
            dialogTitle: 'Please select an output file:',
            fileName: 'paper-backup.pdf',
          );
          if (selectedDirectory == null) {
            loading.value = false;
            Get.snackbar("Error", "Please select a save directory",
                snackPosition: SnackPosition.BOTTOM);
            return;
          }
          directoryToWrite.value = selectedDirectory;
          generatePdf(
              path: directoryToWrite.value,
              qrCodes: qrChecked.value,
              ocrText: ocrChecked.value,
              letterPaper: paperSizeSelection[1]);
          details.onStepContinue!();
          loading.value = false;
        };
        backButton = ElevatedButton.icon(
          onPressed: details.onStepCancel,
          icon: const Icon(Icons.arrow_back),
          label: const Text("Back"),
        );
      case 2:
        nextLabel = "Print";
        nextIcon = Icons.print;
        nextAction = () async {
          await Printing.layoutPdf(
              onLayout: (PdfPageFormat format) async => pdf.save());
        };
        backButton = ElevatedButton.icon(
          onPressed: () => currentStep.value = 0,
          icon: const Icon(Icons.refresh),
          label: const Text("Restart"),
        );
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
            backButton,
            currentStep.value == 2
                ? ElevatedButton.icon(
                    onPressed: () => exit(0),
                    icon: const Icon(Icons.close),
                    label: const Text("Close app"),
                  )
                : const Center(),
            ElevatedButton.icon(
              onPressed: nextAction,
              icon: Icon(nextIcon),
              label: Text(nextLabel),
            ),
          ],
        ));
  }
}
