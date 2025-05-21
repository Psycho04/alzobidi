import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/invoice.dart';
import '../../l10n/app_localizations.dart';

// Header component
pw.Widget buildHeader(pw.Font ttf, pw.MemoryImage logo, 
    pw.MemoryImage qrCode, AppLocalizations localizations) {
  return pw.Container(
    width: double.infinity,
    color: PdfColor.fromHex('#00514C'), // Dark green
    padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Logo on the left (smaller)
        pw.SizedBox(
          height: 50,
          width: 50,
          child: pw.Image(logo, fit: pw.BoxFit.contain),
        ),
        // Institution details in the center
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                localizations.institutionName,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  font: ttf,
                  color: PdfColors.white,
                ),
                textAlign: pw.TextAlign.center,
              ),
              // Tax and registration info in a single row to save space
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    '${localizations.taxNumber}: ${Invoice.taxNumber}',
                    style: pw.TextStyle(
                      font: ttf,
                      color: PdfColor.fromHex('#E8F5E9'), // Light green
                      fontSize: 9,
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Text(
                    '${localizations.commercialRegistration}: ${Invoice.commercialRegistrationNumber}',
                    style: pw.TextStyle(
                      font: ttf,
                      color: PdfColor.fromHex('#E8F5E9'), // Light green
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // QR Code on the right (smaller)
        pw.SizedBox(
          height: 50,
          width: 50,
          child: pw.Image(qrCode, fit: pw.BoxFit.contain),
        ),
      ],
    ),
  );
}

// Invoice title component
pw.Widget buildInvoiceTitle(pw.Font ttf) {
  return pw.Container(
    width: double.infinity,
    color: PdfColor.fromHex('#00514C'), // Dark green
    padding: const pw.EdgeInsets.symmetric(vertical: 5),
    child: pw.Text(
      'فاتورة أولية',
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        font: ttf,
        color: PdfColors.white,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

// Invoice details component
pw.Widget buildInvoiceDetails(Invoice invoice, pw.Font ttf) {
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  return pw.Column(
    children: [
      // Invoice number and date
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Invoice number and date
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#2E7D32')), // Dark green border
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Invoice number row
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('رقم الفاتورة',
                        style: pw.TextStyle(
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                          color: PdfColor.fromHex('#2E7D32'), // Dark green
                        ),
                      ),
                      pw.Text(invoice.id.substring(0, 8),
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 9,
                          color: PdfColor.fromHex('#2E7D32'), // Dark green
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  // Date row
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('تاريخ الفاتورة',
                        style: pw.TextStyle(
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                          color: PdfColor.fromHex('#2E7D32'), // Dark green
                        ),
                      ),
                      pw.Text(formatDate(invoice.date),
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 9,
                          color: PdfColor.fromHex('#2E7D32'), // Dark green
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          pw.SizedBox(width: 10),

          // Right side - English labels
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#2E7D32')), // Dark green border
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Invoice number row (English)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Invoice Number',
                        style: pw.TextStyle(
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                          color: PdfColor.fromHex('#2E7D32'), // Dark green
                        ),
                      ),
                      pw.Text(invoice.id.substring(0, 8),
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 9,
                          color: PdfColor.fromHex('#2E7D32'), // Dark green
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  // Date row (English)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Invoice Date',
                        style: pw.TextStyle(
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                          color: PdfColor.fromHex('#2E7D32'), // Dark green
                        ),
                      ),
                      pw.Text('${formatDate(invoice.date)} ${invoice.date.hour}:${invoice.date.minute}',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 9,
                          color: PdfColor.fromHex('#2E7D32'), // Dark green
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      pw.SizedBox(height: 10),

      // Customer information in a compact row
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Arabic customer info
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#2E7D32')), // Dark green border
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('اسم العميل',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                      color: PdfColor.fromHex('#2E7D32'), // Dark green
                    ),
                  ),
                  pw.Text(invoice.customer.name,
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 9,
                      color: PdfColor.fromHex('#2E7D32'), // Dark green
                    ),
                  ),
                ],
              ),
            ),
          ),

          pw.SizedBox(width: 10),

          // English customer info
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#2E7D32')), // Dark green border
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Customer Name',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                      color: PdfColor.fromHex('#2E7D32'), // Dark green
                    ),
                  ),
                  pw.Text(invoice.customer.name,
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 9,
                      color: PdfColor.fromHex('#2E7D32'), // Dark green
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
