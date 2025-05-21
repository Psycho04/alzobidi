import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/invoice.dart';
import '../../l10n/app_localizations.dart';
import 'pdf_invoice_components.dart' as components;
import 'pdf_invoice_components_2.dart' as components2;

class PdfInvoiceGenerator {
  static Future<void> generateAndShareInvoice(
    BuildContext context,
    Invoice invoice,
  ) async {
    final localizations = AppLocalizations.of(context);
    final pdf = pw.Document();

    // Load the Arabic font
    final arabicFont =
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final ttf = pw.Font.ttf(arabicFont);

    // Load the logo image
    final logoImage = await rootBundle.load('assets/logo.jpg');
    final logoImageData = logoImage.buffer.asUint8List();
    final logo = pw.MemoryImage(logoImageData);

    // Load the QR code image
    final qrImage = await rootBundle.load('assets/qr.jpg');
    final qrImageData = qrImage.buffer.asUint8List();
    final qrCode = pw.MemoryImage(qrImageData);

    // Create a theme with the Arabic font
    final theme = pw.ThemeData.withFont(
      base: ttf,
      bold: ttf,
      italic: ttf,
      boldItalic: ttf,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl, // Set RTL for Arabic text
        theme: theme, // Apply the theme with Arabic font
        build: (context) {
          // Calculate subtotal and VAT
          final subtotal = invoice.items.fold<double>(
            0.0,
            (sum, item) => sum + item.totalPrice,
          );
          const vatRate = 0.15; // 15% VAT as per image
          final vatAmount = subtotal * vatRate;
          final totalWithVat = subtotal + vatAmount;

          return pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.stretch, // Stretch to fill width
            children: [
              // Compact Header with logos and text in a more space-efficient layout
              components.buildHeader(ttf, logo, qrCode, localizations),

              // Invoice Title Section (more compact)
              components.buildInvoiceTitle(ttf),

              pw.SizedBox(height: 10),

              // Compact Invoice Details Table with 2x2 grid layout
              components.buildInvoiceDetails(invoice, ttf),

              pw.SizedBox(height: 15), // Reduced spacing

              // Items table with improved styling
              components2.buildItemsTable(invoice, ttf),

              pw.SizedBox(height: 10), // Reduced spacing

              // Summary Section
              components2.buildSummarySection(subtotal, totalWithVat, invoice.paidAmount, ttf),

              // Footer with contact information
              components2.buildFooter(ttf),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice_${invoice.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: '${localizations.invoices} #${invoice.id}',
    );
  }
}
