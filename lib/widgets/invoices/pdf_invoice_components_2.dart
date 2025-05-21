import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/invoice.dart';

// Items table component
pw.Widget buildItemsTable(Invoice invoice, pw.Font ttf) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColor.fromHex('#2E7D32')), // Dark green border
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
    ),
    child: pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5), // #
        1: const pw.FlexColumnWidth(3), // Product
        2: const pw.FlexColumnWidth(1.5), // Quantity/Unit
        3: const pw.FlexColumnWidth(2), // Price
        4: const pw.FlexColumnWidth(2), // Total
      },
      border: pw.TableBorder.symmetric(
        inside: pw.BorderSide(color: PdfColor.fromHex('#2E7D32')), // Dark green border
      ),
      tableWidth: pw.TableWidth.max,
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        // Table header with background color
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#00514C'), // Dark blue
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text(
                '#',
                style: pw.TextStyle(
                  font: ttf,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 10,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text(
                'المنتج', // Product
                style: pw.TextStyle(
                  font: ttf,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 10,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text(
                'الكمية للوحدة', // Quantity per Unit
                style: pw.TextStyle(
                  font: ttf,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 10,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text(
                'السعر', // Price (Arabic)
                style: pw.TextStyle(
                  font: ttf,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 10,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text(
                'إجمالي', // Total (Arabic)
                style: pw.TextStyle(
                  font: ttf,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 10,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),
        // Table rows with alternating background colors
        ...invoice.items.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final item = entry.value;
            return pw.TableRow(
              decoration: pw.BoxDecoration(
                color: index % 2 == 0 ? PdfColors.white : PdfColor.fromHex('#E8F5E9'), // Light green for alternating rows
              ),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    (index + 1).toString(), // Item number
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 9,
                      color: PdfColor.fromHex('#2E7D32'), // Dark green
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    item.product.category, // Product name
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 9,
                      color: PdfColor.fromHex('#2E7D32'), // Dark green
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '${item.quantity} حبّة', // Quantity and unit
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 9,
                      color: PdfColor.fromHex('#2E7D32'), // Dark green
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    item.product.pricePerUnit.toStringAsFixed(2), // Price per unit
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 9,
                      color: PdfColor.fromHex('#2E7D32'), // Dark green
                    ),
                    textAlign: pw.TextAlign.left,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    item.totalPrice.toStringAsFixed(2), // Total price for item
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 9,
                      color: PdfColor.fromHex('#2E7D32'), // Dark green
                    ),
                    textAlign: pw.TextAlign.left,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

// Summary section component
pw.Widget buildSummarySection(double subtotal, double totalWithVat, double? paidAmount, pw.Font ttf) {
  return pw.Column(
    children: [
      // Add divider before summary section
      pw.Divider(
        color: PdfColor.fromHex('#2E7D32'), // Dark green
        thickness: 1,
        height: 20,
      ),

      // Summary content with exact formatting from the image - right-aligned
      pw.Container(
        alignment: pw.Alignment.centerRight,
        padding: const pw.EdgeInsets.only(right: 20), // Add right padding
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start, // Left-aligned in RTL (appears right-aligned)
          children: [
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  ':مجموع فرعي',
                  style: pw.TextStyle(
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: PdfColor.fromHex('#2E7D32'), // Dark green
                  ),
                ),
                pw.SizedBox(width: 5),
                pw.Text(
                  'SAR ${subtotal.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                    color: PdfColor.fromHex('#2E7D32'), // Dark green
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2),
            // Display paid amount instead of 'معفاة'
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                 pw.Text(
                  ':المعفاة',
                  style: pw.TextStyle(
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: PdfColor.fromHex('#2E7D32'), // Dark green
                  ),
                ),
                pw.SizedBox(width: 5),
                pw.Text(
                  'SAR ${(paidAmount ?? 0.0).toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                    color: PdfColor.fromHex('#2E7D32'), // Dark green
                  ),
                ),
              ]
            ),
          ],
        ),
      ),
    ],
  );
}

// Footer component
pw.Widget buildFooter(pw.Font ttf) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    child: pw.Text(
      'المملكة العربية السعودية - خميس مشيط - رقم جوال 0537217522 البريد الإلكتروني: info@hayatalbadya.com',
      style: pw.TextStyle(
        font: ttf,
        fontSize: 10,
        color: PdfColor.fromHex('#2E7D32'), // Dark green
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}
