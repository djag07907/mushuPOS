import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:html' as html;

class PurchasesBody extends StatefulWidget {
  const PurchasesBody({super.key});

  @override
  State<PurchasesBody> createState() => _PurchasesBodyState();
}

class _PurchasesBodyState extends State<PurchasesBody> {
  final List<Map<String, dynamic>> _purchases = List.generate(20, (index) {
    return {
      'number': index + 1,
      'purchase': 'Purchase name $index',
      'purchaseDate': DateTime.now().subtract(Duration(days: index)).toString(),
      'purchaseNumber': 'Purchase Number $index',
      'provider': 'Provider ${index % 3 + 1}',
      'buyer': 'Daniel',
      'totalCost': 'Total Cost $index',
      'status': index % 2 == 0 ? 'Registered' : 'Nulled',
    };
  });

  String _filter = '';
  int _rowsPerPage = 5;
  int _currentPage = 0;

  List<Map<String, dynamic>> get _filteredPurchases {
    return _purchases
        .where((purchase) => purchase['purchase']
            .toString()
            .toLowerCase()
            .contains(_filter.toLowerCase()))
        .toList();
  }

  final List<String> _providers = ['Provider 1', 'Provider 2', 'Provider 3'];

  final Map<String, double> _products = {
    'Product A': 10.0,
    'Product B': 20.0,
    'Product C': 30.0,
    'Product D': 40.0,
    'Product E': 50.0,
  };

  List<String> _selectedProducts = [];

  void _generateIndividualPdfReport(Map<String, dynamic> purchase) async {
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
              pw.Text('Purchase Report for ${purchase['purchase']}',
                  style: pw.TextStyle(fontSize: 24, font: boldFont)),
              pw.SizedBox(height: 20),
              pw.Text('Purchase Date: ${purchase['purchaseDate']}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont)),
              pw.Text('Purchase Number: ${purchase['purchaseNumber']}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont)),
              pw.Text('Provider: ${purchase['provider']}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont)),
              pw.Text('Buyer: ${purchase['buyer']}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont)),
              pw.Text('Total Cost: ${purchase['totalCost']}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont)),
              pw.Text('Status: ${purchase['status']}',
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
      ..setAttribute('download', 'purchase_report_${purchase['number']}.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _showPurchaseDetails(Map<String, dynamic> purchase) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Purchase Details: ${purchase['purchase']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Purchase Date: ${purchase['purchaseDate']}'),
              Text('Purchase Number: ${purchase['purchaseNumber']}'),
              Text('Provider: ${purchase['provider']}'),
              Text('Buyer: ${purchase['buyer']}'),
              Text('Total Cost: ${purchase['totalCost']}'),
              Text('Status: ${purchase['status']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _generateIndividualPdfReport(purchase);
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
    print("Filtered Purchases: $_filteredPurchases");

    for (int i = 0; i < _filteredPurchases.length; i += maxRowsPerPage) {
      final chunk = _filteredPurchases.sublist(
          i,
          (i + maxRowsPerPage < _filteredPurchases.length)
              ? i + maxRowsPerPage
              : _filteredPurchases.length);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(pw.MemoryImage(logo), width: 100, height: 100),
                pw.SizedBox(height: 20),
                pw.Text('Purchases Report',
                    style: pw.TextStyle(fontSize: 24, font: boldFont)),
                pw.SizedBox(height: 20),
                pw.Text('Generated on: $formattedDate',
                    style: pw.TextStyle(fontSize: 12, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('User: Admin',
                    style: pw.TextStyle(fontSize: 18, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('Total Purchases: ${_filteredPurchases.length}',
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
                    7: pw.FixedColumnWidth(50.0),
                    8: pw.FixedColumnWidth(50.0),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Purchase Name',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Purchase Date',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Purchase Number',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Provider',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Buyer',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Total Cost',
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
                    ...chunk.map((purchase) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(purchase['purchase'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(purchase['purchaseDate'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(purchase['purchaseNumber'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(purchase['provider'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(purchase['buyer'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(purchase['totalCost'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(purchase['status'] ?? 'N/A',
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
      ..setAttribute('download', 'purchases_report.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _showAddPurchaseDialog() {
    String purchaseName = '';
    String purchaseNumber = '';
    String selectedProvider = _providers[0];
    String identificationType = '';
    double totalCost = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Register Purchase'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Purchase Name'),
                onChanged: (value) {
                  purchaseName = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Purchase Number'),
                onChanged: (value) {
                  purchaseNumber = value;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Provider'),
                value: selectedProvider,
                items: _providers.map((provider) {
                  return DropdownMenuItem(
                      value: provider, child: Text(provider));
                }).toList(),
                onChanged: (value) {
                  selectedProvider = value!;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Identification Type'),
                onChanged: (value) {
                  identificationType = value;
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _showProductSelectionDialog((selectedTotalCost) {
                    setState(() {
                      totalCost = selectedTotalCost;
                    });
                  });
                },
                child: const Text('Add Products'),
              ),
              const SizedBox(height: 8),
              Wrap(
                children: _selectedProducts.map((product) {
                  return Chip(
                    label: Text(product),
                    onDeleted: () {
                      setState(() {
                        _selectedProducts.remove(product);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text('Total Cost: \$${totalCost.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (purchaseName.isNotEmpty && purchaseNumber.isNotEmpty) {
                  setState(() {
                    _purchases.add({
                      'number': _purchases.length + 1,
                      'purchase': purchaseName,
                      'purchaseDate': DateFormat('yyyy-MM-dd – kk:mm')
                          .format(DateTime.now()),
                      'purchaseNumber': purchaseNumber,
                      'provider': selectedProvider,
                      'buyer': 'Daniel',
                      'status': 'Registered',
                      'totalCost': totalCost.toStringAsFixed(2),
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Register Purchase'),
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

  void _showProductSelectionDialog(Function(double) onTotalCostChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Products'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _products.keys.map((product) {
                return CheckboxListTile(
                  title: Text(product),
                  value: _selectedProducts.contains(product),
                  onChanged: (isSelected) {
                    setState(() {
                      if (isSelected!) {
                        _selectedProducts.add(product);
                      } else {
                        _selectedProducts.remove(product);
                      }
                      double totalCost =
                          _selectedProducts.fold(0.0, (sum, item) {
                        return sum + _products[item]!;
                      });
                      onTotalCostChanged(totalCost);
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Done'),
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
        title:
            const Text('Purchases List', style: TextStyle(color: Colors.black)),
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
                  onPressed: _showAddPurchaseDialog,
                  child: const Text('Add Purchase'),
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
                labelText: 'Filter by purchase',
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
                  header: const Text('Purchases List'),
                  rowsPerPage: _rowsPerPage,
                  onPageChanged: (pageIndex) {
                    setState(() {
                      _currentPage = pageIndex;
                    });
                  },
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Purchase')),
                    DataColumn(label: Text('Purchase Date')),
                    DataColumn(label: Text('Purchase Number')),
                    DataColumn(label: Text('Provider')),
                    DataColumn(label: Text('Buyer')),
                    DataColumn(label: Text('Total Cost')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Change Status')),
                    DataColumn(label: Text('View Details')),
                  ],
                  source: _PurchasesDataSource(
                    data: _filteredPurchases,
                    onChangeStatus: (index) {
                      setState(() {
                        _filteredPurchases[index]['status'] =
                            _filteredPurchases[index]['status'] == 'Registered'
                                ? 'Nulled'
                                : 'Registered';
                      });
                    },
                    onShowDetails: _showPurchaseDetails,
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

class _PurchasesDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final Function(int index) onChangeStatus;
  final Function(Map<String, dynamic>) onShowDetails;

  _PurchasesDataSource({
    required this.data,
    required this.onChangeStatus,
    required this.onShowDetails,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final purchase = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(purchase['number'].toString())),
        DataCell(Text(purchase['purchase'] ?? 'N/A')),
        DataCell(Text(purchase['purchaseDate'] ?? 'N/A')),
        DataCell(Text(purchase['purchaseNumber'] ?? 'N/A')),
        DataCell(Text(purchase['provider'] ?? 'N/A')),
        DataCell(Text(purchase['buyer'] ?? 'N/A')),
        DataCell(Text('\$${purchase['totalCost'] ?? 'N/A'}')),
        DataCell(
          Text(
            purchase['status'],
            style: TextStyle(
              color: purchase['status'] == 'Registered'
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ),
        DataCell(
          IconButton(
            icon: Icon(
              purchase['status'] == 'Registered'
                  ? Icons.toggle_on
                  : Icons.toggle_off,
              color: purchase['status'] == 'Registered'
                  ? Colors.green
                  : Colors.red,
            ),
            onPressed: () => onChangeStatus(index),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () {
              onShowDetails(purchase);
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
