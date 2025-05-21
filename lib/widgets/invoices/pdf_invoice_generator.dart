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

    // Ensure invoice items is not null and calculate subtotal and VAT
    final items = invoice.items;
    final subtotal = items.isNotEmpty
        ? items.fold<double>(0.0, (sum, item) => sum + item.totalPrice)
        : 0.0;
    const vatRate = 0.0; // 0% VAT as requested
    final vatAmount = subtotal * vatRate; // Will be 0
    final totalWithVat = subtotal + vatAmount; // Same as subtotal since VAT is 0

    // Add a MultiPage to handle pagination automatically
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl, // Set RTL for Arabic text
        theme: theme, // Apply the theme with Arabic font
        // Set margin to ensure content doesn't get cut off
        margin: const pw.EdgeInsets.all(20),
        // Set maxPages to a high number to ensure all content is included
        maxPages: 100,
        // Header that appears on all pages
        header: (context) {
          // Get page number safely
          int pageNumber;
          try {
            pageNumber = context.pageNumber;
          } catch (e) {
            // Default to first page if we can't determine the page number
            pageNumber = 1;
          }

          return pw.Column(
            children: [
              components.buildHeader(ttf, logo, qrCode, localizations),
              // Show different title for continuation pages
              pageNumber == 1
                ? components.buildInvoiceTitle(ttf)
                : pw.Container(
                    width: double.infinity,
                    color: PdfColor.fromHex('#4C585B'), // Changed from brown/orange to dark gray
                    padding: const pw.EdgeInsets.symmetric(vertical: 5),
                    child: pw.Text(
                      'تابع فاتورة أولية', // "Continued Invoice"
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: PdfColors.white,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
              pw.SizedBox(height: 10),
            ],
          );
        },
        // Footer that appears on all pages with page number
        footer: (context) {
          // Create a safe wrapper for the page number component
          pw.Widget pageNumberWidget;
          try {
            pageNumberWidget = components2.buildPageNumber(context, ttf);
          } catch (e) {
            // If there's an error with the page number, show a simple text
            pageNumberWidget = pw.Text(
              'صفحة الفاتورة', // "Invoice page"
              style: pw.TextStyle(
                font: ttf,
                fontSize: 10,
                color: PdfColor.fromHex('#4C585B'), // Changed from brown/orange to dark gray
              ),
              textAlign: pw.TextAlign.center,
            );
          }

          return pw.Column(
            children: [
              components2.buildFooter(ttf),
              pw.SizedBox(height: 5),
              pageNumberWidget,
            ],
          );
        },
        build: (context) {
          // Create a list of widgets to display
          final widgets = <pw.Widget>[];

          // Get the current page number - default to 1 if not available
          int pageNumber;
          try {
            pageNumber = context.pageNumber;
          } catch (e) {
            // If there's an error accessing pageNumber, default to 1
            pageNumber = 1;
          }

          // Only show invoice details on the first page
          if (pageNumber == 1) {
            widgets.add(components.buildInvoiceDetails(invoice, ttf));
            widgets.add(pw.SizedBox(height: 15));
          }

          // For continuation pages, add a note
          if (pageNumber > 1) {
            widgets.add(
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 5),
                color: PdfColor.fromHex('#F5F5F5'), // Light gray background
                child: pw.Text(
                  'تابع المنتجات من الصفحة السابقة', // "Products continued from previous page"
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#4C585B'), // Dark gray
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 10));
          }

          // Add the items table with header on each page
          // The table will automatically flow to the next page when needed
          widgets.add(
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // #
                1: const pw.FlexColumnWidth(3), // Product
                2: const pw.FlexColumnWidth(1.5), // Quantity/Unit
                3: const pw.FlexColumnWidth(2), // Price
                4: const pw.FlexColumnWidth(2), // Total
              },
              border: pw.TableBorder.all(
                color: PdfColor.fromHex('#4C585B'), // Dark gray border
                width: 1,
              ),
              tableWidth: pw.TableWidth.max,
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                // Table header - always show on each page
                components2.buildItemsTableHeader(ttf),

                // Table rows - show all rows and let MultiPage handle pagination
                if (invoice.items.isNotEmpty)
                  ...invoice.items.asMap().entries.map(
                    (entry) => components2.buildItemsTableRow(entry.key, entry.value, ttf),
                  )
                else
                  // Show an empty row if there are no items
                  pw.TableRow(
                    children: List.generate(
                      5,
                      (index) => pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          index == 1 ? 'لا توجد منتجات' : '', // "No products" in the product column
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 9,
                            color: PdfColor.fromHex('#4C585B'),
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );

          // Always add the summary section at the end of the content
          // This ensures it's always visible, regardless of whether it fits on the first page
          // or flows to subsequent pages
          widgets.add(pw.SizedBox(height: 10));
          widgets.add(components2.buildSummarySection(subtotal, totalWithVat, invoice.paidAmount, ttf));

          return widgets;
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
