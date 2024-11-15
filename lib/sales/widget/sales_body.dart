import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:html' as html;

class SalesBody extends StatefulWidget {
  const SalesBody({super.key});

  @override
  State<SalesBody> createState() => _SalesBodyState();
}

class _SalesBodyState extends State<SalesBody> {
  final List<Map<String, dynamic>> _sales = List.generate(20, (index) {
    return {
      'number': index + 1,
      'saleDate': '2023-10-0${index % 10 + 1}',
      'saleNumber': 'Sale Number $index',
      'client': 'Client $index',
      'documentType': 'Document Type $index',
      'seller': 'Seller $index',
      'subTotal': (100 + index * 10).toString(),
      'isv15': '15%',
      'isv18': '18%',
      'totalSale': (100 + index * 10) * 1.15 + (100 + index * 10) * 0.18,
      'status': index % 2 == 0 ? 'Registered' : 'Nulled',
    };
  });

  String _filter = '';
  int _rowsPerPage = 5;
  int _currentPage = 0;

  List<Map<String, dynamic>> get _filteredSales {
    return _sales
        .where((sale) => sale['saleNumber']
            .toString()
            .toLowerCase()
            .contains(_filter.toLowerCase()))
        .toList();
  }

  void _generateIndividualPdfReport(Map<String, dynamic> sale) async {
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Image(pw.MemoryImage(logo), width: 100, height: 100),
              pw.SizedBox(height: 20),
              pw.Text('Sale Report for ${sale['saleNumber']}',
                  style: pw.TextStyle(fontSize: 24, font: boldFont)),
              pw.SizedBox(height: 20),
              pw.Text('Sale Date: ${sale['saleDate']}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont)),
              pw.Text('Sale Number: ${sale['saleNumber']}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont)),
              pw.Text('Client: ${sale['client']}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont)),
              pw.Text('Document Type: ${sale['documentType']}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont)),
              pw.Text('Seller: ${sale['seller']}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont)),
              pw.Text('Subtotal: ${sale['subTotal']}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont)),
              pw.Text('ISV 15%: ${sale['isv15']}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont)),
              pw.Text('ISV 18%: ${sale['isv18']}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont)),
              pw.Text('Total Sale: ${sale['totalSale']}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont)),
              pw.Text('Status: ${sale['status']}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont)),
            ],
          );
        },
      ),
    );

    final Uint8List pdfData = await pdf.save();
    final blob = html.Blob([pdfData], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'sale_report_${sale['number']}.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _showSaleDetails(Map<String, dynamic> sale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sale Details: ${sale['saleNumber']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sale Date: ${sale['saleDate']}'),
              Text('Sale Number: ${sale['saleNumber']}'),
              Text('Client: ${sale['client']}'),
              Text('Document Type: ${sale['documentType']}'),
              Text('Seller: ${sale['seller']}'),
              Text('Subtotal: ${sale['subTotal']}'),
              Text('ISV 15%: ${sale['isv15']}'),
              Text('ISV 18%: ${sale['isv18']}'),
              Text('Total Sale: ${sale['totalSale']}'),
              Text('Status: ${sale['status']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _generateIndividualPdfReport(sale);
                Navigator.of(context).pop();
              },
              child: const Text('Download PDF'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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
    const int maxRowsPerPage = 5;
    String formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());

    for (int i = 0; i < _filteredSales.length; i += maxRowsPerPage) {
      final chunk = _filteredSales.sublist(
          i,
          (i + maxRowsPerPage < _filteredSales.length)
              ? i + maxRowsPerPage
              : _filteredSales.length);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(pw.MemoryImage(logo), width: 100, height: 100),
                pw.SizedBox(height: 20),
                pw.Text('Sales Report',
                    style: pw.TextStyle(fontSize: 24, font: boldFont)),
                pw.SizedBox(height: 20),
                pw.Text('Generated on: $formattedDate',
                    style: pw.TextStyle(fontSize: 12, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('User: Admin',
                    style: pw.TextStyle(fontSize: 18, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('Total Sales: ${_filteredSales.length}',
                    style: pw.TextStyle(fontSize: 18, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: const {
                    0: pw.FixedColumnWidth(50.0),
                    1: pw.FixedColumnWidth(100.0),
                    2: pw.FixedColumnWidth(100.0),
                    3: pw.FixedColumnWidth(100.0),
                    4: pw.FixedColumnWidth(100.0),
                    5: pw.FixedColumnWidth(100.0),
                    6: pw.FixedColumnWidth(100.0),
                    7: pw.FixedColumnWidth(100.0),
                    8: pw.FixedColumnWidth(100.0),
                    9: pw.FixedColumnWidth(100.0),
                    10: pw.FixedColumnWidth(50.0),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Number',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Sale Date',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Sale Number',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Client',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Document Type',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Seller',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Subtotal',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('ISV 15%',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('ISV 18%',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Total Sale',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Status',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                      ],
                    ),
                    ...chunk.map((sale) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(sale['number'].toString(),
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(sale['saleDate'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(sale['saleNumber'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(sale['client'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(sale['documentType'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(sale['seller'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(sale['subTotal'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(sale['isv15'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(sale['isv18'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(
                                sale['totalSale'].toString() ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(sale['status'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
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
      ..setAttribute('download', 'sales_report.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _showAddSaleDialog() {
    String saleNumber = '';
    String client = '';
    String documentType = '';
    String seller = '';
    String subTotal = '';
    String isv15 = '15%';
    String isv18 = '18%';
    String totalSale = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Register Sale'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Sale Number'),
                onChanged: (value) {
                  saleNumber = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Client'),
                onChanged: (value) {
                  client = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Document Type'),
                onChanged: (value) {
                  documentType = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Seller'),
                onChanged: (value) {
                  seller = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Subtotal'),
                onChanged: (value) {
                  subTotal = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (saleNumber.isNotEmpty && client.isNotEmpty) {
                  setState(() {
                    _sales.add({
                      'number': _sales.length + 1,
                      'saleDate':
                          DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      'saleNumber': saleNumber,
                      'client': client,
                      'documentType': documentType,
                      'seller': seller,
                      'subTotal': subTotal,
                      'isv15': isv15,
                      'isv18': isv18,
                      'totalSale': double.parse(subTotal) * 1.15 +
                          double.parse(subTotal) * 0.18,
                      'status': 'Registered',
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales List', style: TextStyle(color: Colors.black)),
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
                  onPressed: _showAddSaleDialog,
                  child: const Text('Add Sale'),
                ),
                const SizedBox(width: 8),
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
                labelText: 'Filter by Sale Number',
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
                  header: const Text('Sales List'),
                  rowsPerPage: _rowsPerPage,
                  onPageChanged: (pageIndex) {
                    setState(() {
                      _currentPage = pageIndex;
                    });
                  },
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Sale Date')),
                    DataColumn(label: Text('Sale Number')),
                    DataColumn(label: Text('Client')),
                    DataColumn(label: Text('Document Type')),
                    DataColumn(label: Text('Seller')),
                    DataColumn(label: Text('Subtotal')),
                    DataColumn(label: Text('ISV 15%')),
                    DataColumn(label: Text('ISV 18%')),
                    DataColumn(label: Text('Total Sale')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Change Status')),
                    DataColumn(label: Text('View Details')),
                  ],
                  source: _SalesDataSource(
                    data: _filteredSales,
                    onChangeStatus: (index) {
                      setState(() {
                        _filteredSales[index]['status'] =
                            _filteredSales[index]['status'] == 'Registered'
                                ? 'Nulled'
                                : 'Registered';
                      });
                    },
                    onShowDetails: _showSaleDetails,
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

class _SalesDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final Function(int index) onChangeStatus;
  final Function(Map<String, dynamic>) onShowDetails;

  _SalesDataSource({
    required this.data,
    required this.onChangeStatus,
    required this.onShowDetails,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final sale = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(sale['number'].toString())),
        DataCell(Text(sale['saleDate'] ?? 'N/A')),
        DataCell(Text(sale['saleNumber'] ?? 'N/A')),
        DataCell(Text(sale['client'] ?? 'N/A')),
        DataCell(Text(sale['documentType'] ?? 'N/A')),
        DataCell(Text(sale['seller'] ?? 'N/A')),
        DataCell(Text(sale['subTotal'] ?? 'N/A')),
        DataCell(Text(sale['isv15'] ?? 'N/A')),
        DataCell(Text(sale['isv18'] ?? 'N/A')),
        DataCell(Text(sale['totalSale'].toString() ?? 'N/A')),
        DataCell(
          Text(
            sale['status'],
            style: TextStyle(
              color: sale['status'] == 'Registered' ? Colors.green : Colors.red,
            ),
          ),
        ),
        DataCell(
          IconButton(
            icon: Icon(
              sale['status'] == 'Registered'
                  ? Icons.toggle_on
                  : Icons.toggle_off,
              color: sale['status'] == 'Registered' ? Colors.green : Colors.red,
            ),
            onPressed: () => onChangeStatus(index),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () {
              onShowDetails(sale);
            },
          ),
        ),
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
