import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfMaker {
  static double pad1 = 3;
  static Future<File> generatePdf(
      String report, String doctorName, String patientName) async {
    print(patientName);
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.portrait,
        build: (pw.Context context) {
          return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 30),
                pw.Text("Report",
                    style: const pw.TextStyle(
                      fontSize: 30,
                      color: PdfColors.black,
                    )),
                pw.SizedBox(height: 20),
                pw.Text(report),
                pw.SizedBox(height: 20),
                pw.Row(children: [
                  pw.Text("Doctor Name: ",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 10),
                  pw.Text(doctorName)
                ]),
                pw.SizedBox(height: 5),
                pw.Row(children: [
                  pw.Text("Patient Name: ",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 10),
                  pw.Text(patientName)
                ])
              ]);
        },
      ),
    );
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/sample.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
