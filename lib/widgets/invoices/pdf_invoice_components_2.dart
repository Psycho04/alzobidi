import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/invoice.dart';

// Items table header component
pw.TableRow buildItemsTableHeader(pw.Font ttf) {
  return pw.TableRow(
    decoration: pw.BoxDecoration(
      color: PdfColor.fromHex('#4C585B'), // Dark gray
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
  );
}

// Items table row component
pw.TableRow buildItemsTableRow(int index, InvoiceItem item, pw.Font ttf) {
  // Get product category and price
  final productCategory = item.product.category;
  final pricePerUnit = item.product.pricePerUnit;

  return pw.TableRow(
    decoration: pw.BoxDecoration(
      color: index % 2 == 0 ? PdfColors.white : PdfColor.fromHex('#F5F5F5'), // Light gray for alternating rows
    ),
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          (index + 1).toString(), // Item number
          style: pw.TextStyle(
            font: ttf,
            fontSize: 9,
            color: PdfColor.fromHex('#4C585B'), // Dark gray
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          productCategory, // Product name
          style: pw.TextStyle(
            font: ttf,
            fontSize: 9,
            color: PdfColor.fromHex('#4C585B'), // Dark gray
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
            color: PdfColor.fromHex('#4C585B'), // Dark gray
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          pricePerUnit.toStringAsFixed(2), // Price per unit
          style: pw.TextStyle(
            font: ttf,
            fontSize: 9,
            color: PdfColor.fromHex('#4C585B'), // Dark gray
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
            color: PdfColor.fromHex('#4C585B'), // Dark gray
          ),
          textAlign: pw.TextAlign.left,
        ),
      ),
    ],
  );
}

// Items table component
pw.Widget buildItemsTable(Invoice invoice, pw.Font ttf) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColor.fromHex('#4C585B')), // Dark gray border
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
        inside: pw.BorderSide(color: PdfColor.fromHex('#4C585B')), // Dark gray border
      ),
      tableWidth: pw.TableWidth.max,
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        // Table header
        buildItemsTableHeader(ttf),

        // Table rows - handle empty items list
        if (invoice.items.isNotEmpty)
          ...invoice.items.asMap().entries.map(
            (entry) => buildItemsTableRow(entry.key, entry.value, ttf),
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
}

// Summary section component
pw.Widget buildSummarySection(double subtotal, double totalWithVat, double? paidAmount, pw.Font ttf) {
  // Calculate remaining balance
  final paid = paidAmount ?? 0.0;
  final remainingBalance = totalWithVat - paid;

  return pw.Column(
    children: [
      // Add divider before summary section
      pw.Divider(
        color: PdfColor.fromHex('#4C585B'), // Dark gray
        thickness: 1,
        height: 20,
      ),

      // Title for the summary section - make it more prominent
      pw.Container(
        width: double.infinity,
        color: PdfColor.fromHex('#4C585B'), // Dark gray
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: pw.Text(
          'ملخص الفاتورة والدفع', // "Invoice and Payment Summary"
          style: pw.TextStyle(
            font: ttf,
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white, // White text on dark background
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.SizedBox(height: 10),

      // Summary content with exact formatting from the image - right-aligned
      pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColor.fromHex('#4C585B')), // Dark gray border
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
        ),
        padding: const pw.EdgeInsets.all(10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start, // Left-aligned in RTL (appears right-aligned)
          children: [
            // Subtotal
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  ':مجموع فرعي',
                  style: pw.TextStyle(
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: PdfColor.fromHex('#4C585B'), // Dark gray
                  ),
                ),
                pw.Text(
                  'SAR ${subtotal.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                    color: PdfColor.fromHex('#4C585B'), // Dark gray
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 5),

            // VAT amount (0%)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  ':ضريبة القيمة المضافة 0%',
                  style: pw.TextStyle(
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: PdfColor.fromHex('#4C585B'), // Dark gray
                  ),
                ),
                pw.Text(
                  'SAR 0.00',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                    color: PdfColor.fromHex('#4C585B'), // Dark gray
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 5),

            // Divider before total
            pw.Divider(
              color: PdfColor.fromHex('#4C585B'), // Dark gray
              thickness: 0.5,
            ),

            // Total with VAT - make it more prominent
            pw.Container(
              color: PdfColor.fromHex('#F5F5F5'), // Light gray background
              padding: const pw.EdgeInsets.all(5),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    ':إجمالي الفاتورة',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: PdfColor.fromHex('#4C585B'), // Dark gray
                    ),
                  ),
                  pw.Text(
                    'SAR ${totalWithVat.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: PdfColor.fromHex('#4C585B'), // Dark gray
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Payment information section
            pw.Container(
              width: double.infinity,
              color: PdfColor.fromHex('#F5F5F5'), // Light gray background
              padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              child: pw.Text(
                'معلومات الدفع', // "Payment Information"
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#4C585B'), // Dark gray
                ),
              ),
            ),
            pw.SizedBox(height: 5),

            // Paid amount
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  ':المبلغ المدفوع',
                  style: pw.TextStyle(
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: PdfColor.fromHex('#4C585B'), // Dark gray
                  ),
                ),
                pw.Text(
                  'SAR ${paid.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                    color: PdfColor.fromHex('#4C585B'), // Dark gray
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 5),

            // Remaining balance - make it more prominent
            pw.Container(
              decoration: pw.BoxDecoration(
                color: remainingBalance > 0 ? PdfColor.fromHex('#FFEBEE') : PdfColor.fromHex('#F5F5F5'), // Light red if balance due, light gray if paid
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                border: pw.Border.all(
                  color: remainingBalance > 0 ? PdfColors.red : PdfColor.fromHex('#4C585B'),
                  width: 0.5,
                ),
              ),
              padding: const pw.EdgeInsets.all(5),
              margin: const pw.EdgeInsets.only(top: 5),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    ':الرصيد المتبقي',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: remainingBalance > 0 ? PdfColors.red : PdfColor.fromHex('#4C585B'),
                    ),
                  ),
                  pw.Text(
                    'SAR ${remainingBalance.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: remainingBalance > 0 ? PdfColors.red : PdfColor.fromHex('#4C585B'),
                    ),
                  ),
                ],
              ),
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
        color: PdfColor.fromHex('#4C585B'), // Dark gray
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

// Page number indicator
pw.Widget buildPageNumber(pw.Context context, pw.Font ttf) {
  // Handle potential null context or missing page information
  int pageNumber;
  int pageCount;

  try {
    pageNumber = context.pageNumber;
    pageCount = context.pagesCount;

    // Simple page number indicator for all pages
    return pw.Text(
      'صفحة $pageNumber من $pageCount',
      style: pw.TextStyle(
        font: ttf,
        fontSize: 10,
        color: PdfColor.fromHex('#4C585B'), // Dark gray
      ),
      textAlign: pw.TextAlign.center,
    );
  } catch (e) {
    // Fallback if we can't get page information
    return pw.Text(
      'صفحة الفاتورة', // "Invoice page"
      style: pw.TextStyle(
        font: ttf,
        fontSize: 10,
        color: PdfColor.fromHex('#4C585B'), // Dark gray
      ),
      textAlign: pw.TextAlign.center,
    );
  }
}
