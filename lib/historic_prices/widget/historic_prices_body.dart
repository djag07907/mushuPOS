import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;

class HistoricPricesBody extends StatefulWidget {
  const HistoricPricesBody({super.key});

  @override
  State<HistoricPricesBody> createState() => _HistoricPricesBodyState();
}

class _HistoricPricesBodyState extends State<HistoricPricesBody> {
  final List<Map<String, dynamic>> _historicPrices = List.generate(20, (index) {
    return {
      'number': index + 1,
      'historicPrice': 'HistoricPrice name $index',
      'ID': 'ID $index',
      'lastPrice': (index + 1) * 2.0, // Ensure this is a double
      'currentPrice': (index + 1) * 1.5, // Ensure this is a double
    };
  });

  String _filter = '';
  int _rowsPerPage = 5;
  int _currentPage = 0;

  List<Map<String, dynamic>> get _filteredHistoricPrices {
    return _historicPrices
        .where((historicPrice) => historicPrice['historicPrice']
            .toString()
            .toLowerCase()
            .contains(_filter.toLowerCase()))
        .toList();
  }

  void _generatePdfReport() async {
    final pdf = pw.Document();

    final ByteData bytes =
        await rootBundle.load('assets/images/point-of-sale.png');
    final Uint8List logo = bytes.buffer.asUint8List();

    final ByteData regularFontData =
        await rootBundle.load("assets/fonts/Roboto/Roboto-Regular.ttf");
    final ByteData boldFontData =
        await rootBundle.load("assets/fonts/Roboto/Roboto-Bold.ttf");

    final pw.Font regularFont = pw.Font.ttf(regularFontData);
    final pw.Font boldFont = pw.Font.ttf(boldFontData);

    const int maxRowsPerPage = 10;

    String formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());

    print("Filtered HistoricPrices: $_filteredHistoricPrices");

    for (int i = 0; i < _filteredHistoricPrices.length; i += maxRowsPerPage) {
      final chunk = _filteredHistoricPrices.sublist(
          i,
          (i + maxRowsPerPage < _filteredHistoricPrices.length)
              ? i + maxRowsPerPage
              : _filteredHistoricPrices.length);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(pw.MemoryImage(logo), width: 100, height: 100),
                pw.SizedBox(height: 20),
                pw.Text('HistoricPrices Report',
                    style: pw.TextStyle(fontSize: 24, font: boldFont)),
                pw.SizedBox(height: 20),
                pw.Text('Generated on: $formattedDate',
                    style: pw.TextStyle(fontSize: 12, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('User: Admin',
                    style: pw.TextStyle(fontSize: 18, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text(
                    'Total HistoricPrices: ${_filteredHistoricPrices.length}',
                    style: pw.TextStyle(fontSize: 18, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('HistoricPrice Name',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('ID',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Last Price',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Current Price',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont)),
                        ),
                      ],
                    ),
                    ...chunk.map((historicPrice) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(historicPrice['historicPrice'],
                                style: pw.TextStyle(font: regularFont)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(historicPrice['ID'],
                                style: pw.TextStyle(font: regularFont)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(
                                historicPrice['lastPrice'].toStringAsFixed(
                                    2), // Format to 2 decimal places
                                style: pw.TextStyle(font: regularFont)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(
                                historicPrice['currentPrice'].toStringAsFixed(
                                    2), // Format to 2 decimal places
                                style: pw.TextStyle(font: regularFont)),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    final Uint8List pdfData = await pdf.save();

    final blob = html.Blob([pdfData], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'historicPrices_report.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HistoricPrices List',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _generatePdfReport,
                  child: const Text('PDF Report'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Export Excel functionality
                  },
                  child: const Text('Excel Report'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Filter by historicPrice',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _filter = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: PaginatedDataTable(
                  header: const Text('HistoricPrices List'),
                  rowsPerPage: _rowsPerPage,
                  onPageChanged: (pageIndex) {
                    setState(() {
                      _currentPage = pageIndex;
                    });
                  },
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('HistoricPrice')),
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('LastPrice')),
                    DataColumn(label: Text('CurrentPrice')),
                  ],
                  source: _HistoricPricesDataSource(
                    data: _filteredHistoricPrices,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoricPricesDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;

  _HistoricPricesDataSource({
    required this.data,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final historicPrice = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(historicPrice['number'].toString())),
        DataCell(Text(historicPrice['historicPrice'])),
        DataCell(Text(historicPrice['ID'])),
        DataCell(Text(historicPrice['lastPrice']
            .toStringAsFixed(2))), // Format to 2 decimal places
        DataCell(Text(historicPrice['currentPrice']
            .toStringAsFixed(2))), // Format to 2 decimal places
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}
