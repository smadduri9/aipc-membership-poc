import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/mock_data.dart';
import '../models/application.dart';
import '../widgets/flag_watermark.dart' show congressFlagAsset;
import 'format.dart';

/// PDF copies of the receipt and membership card. The standard PDF fonts have no rupee sign, so amounts use "Rs.".
String _rs(int amount) =>
    'Rs. ${NumberFormat.decimalPattern('en_IN').format(amount)}';

const _navy = PdfColor.fromInt(0xFF1F2A5A);
const _grey = PdfColor.fromInt(0xFF6B7280);

Future<pw.ImageProvider> _flag() async => pw.MemoryImage(
  (await rootBundle.load(congressFlagAsset)).buffer.asUint8List(),
);

pw.Widget _row(String k, String v) => pw.Padding(
  padding: const pw.EdgeInsets.symmetric(vertical: 6),
  child: pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(k, style: const pw.TextStyle(color: _grey)),
      pw.Text(v, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    ],
  ),
);

pw.Widget _header(pw.ImageProvider flag, String title) => pw.Row(
  children: [
    pw.Image(flag, width: 54),
    pw.SizedBox(width: 12),
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'AICP',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: _navy,
          ),
        ),
        pw.Text(
          'All India Congress Party',
          style: const pw.TextStyle(color: _grey),
        ),
      ],
    ),
    pw.Spacer(),
    pw.Text(
      title,
      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
    ),
  ],
);

String _planName(Application a) =>
    a.type == MembershipType.patron ? 'Patron' : 'AICP Member';

/// Payment receipt for an active member.
Future<Uint8List> buildReceiptPdf(Application a) async {
  final flag = await _flag();
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _header(flag, 'Payment receipt'),
          pw.SizedBox(height: 24),
          pw.Divider(color: PdfColors.grey300),
          _row('Received from', a.name),
          _row('Mobile', a.phone),
          _row('Membership', _planName(a)),
          _row('Amount paid', _rs(a.amount)),
          _row('Payment ID', a.paymentId ?? '-'),
          _row('Application reference', a.referenceNo),
          _row(
            'Date',
            formatDate(
              a.history
                  .lastWhere(
                    (e) => e.status == AppStatus.active,
                    orElse: () => StatusEvent(AppStatus.active, DateTime.now()),
                  )
                  .at,
            ),
          ),
          if (a.validUntil != null)
            _row('Valid until', formatDate(a.validUntil!)),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 16),
          pw.Text(
            'Demo document. Sample data, not a legal receipt.',
            style: const pw.TextStyle(color: _grey, fontSize: 10),
          ),
        ],
      ),
    ),
  );
  return doc.save();
}

/// Membership card, credit-card sized on an A4 page.
Future<Uint8List> buildCardPdf(Application a) async {
  final flag = await _flag();
  final doc = pw.Document();
  final validity = a.validUntil == null
      ? 'Lifetime'
      : 'Valid until ${formatDate(a.validUntil!)}';
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (_) => pw.Center(
        child: pw.Container(
          width: 340,
          height: 215,
          padding: const pw.EdgeInsets.all(18),
          decoration: pw.BoxDecoration(
            color: _navy,
            borderRadius: pw.BorderRadius.circular(14),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'AICP',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'All India Congress Party',
                        style: const pw.TextStyle(
                          color: PdfColors.grey300,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Image(flag, width: 50),
                ],
              ),
              pw.Spacer(),
              pw.Text(
                a.name,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Membership no. ${a.referenceNo}',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
              ),
              pw.Text(
                '${_planName(a)} · ${stateNames[a.state] ?? ''}',
                style: const pw.TextStyle(
                  color: PdfColors.grey300,
                  fontSize: 10,
                ),
              ),
              pw.Text(
                validity,
                style: const pw.TextStyle(
                  color: PdfColors.grey300,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return doc.save();
}

/// Opens the iOS share sheet so the member can save or send the file.
Future<void> shareReceipt(Application a) async => Printing.sharePdf(
  bytes: await buildReceiptPdf(a),
  filename: 'AICP-receipt-${a.referenceNo}.pdf',
);

Future<void> shareCard(Application a) async => Printing.sharePdf(
  bytes: await buildCardPdf(a),
  filename: 'AICP-membership-card-${a.referenceNo}.pdf',
);
