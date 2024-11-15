import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;

class BrandsBody extends StatefulWidget {
  const BrandsBody({super.key});

  @override
  State<BrandsBody> createState() => _BrandsBodyState();
}

class _BrandsBodyState extends State<BrandsBody> {
  final List<Map<String, dynamic>> _brands = List.generate(20, (index) {
    return {
      'number': index + 1,
      'brand': 'Brand name $index',
      'description': 'Description $index',
      'Code': 'Code $index',
      'status': index % 2 == 0 ? 'Active' : 'Inactive',
    };
  });

  String _filter = '';
  int _rowsPerPage = 5;
  int _currentPage = 0;

  List<Map<String, dynamic>> get _filteredBrands {
    return _brands
        .where((brand) => brand['brand']
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

    print("Filtered Brands: $_filteredBrands");

    for (int i = 0; i < _filteredBrands.length; i += maxRowsPerPage) {
      final chunk = _filteredBrands.sublist(
          i,
          (i + maxRowsPerPage < _filteredBrands.length)
              ? i + maxRowsPerPage
              : _filteredBrands.length);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(pw.MemoryImage(logo), width: 100, height: 100),
                pw.SizedBox(height: 20),
                pw.Text('Brands Report',
                    style: pw.TextStyle(fontSize: 24, font: boldFont)),
                pw.SizedBox(height: 20),
                pw.Text('Generated on: $formattedDate',
                    style: pw.TextStyle(fontSize: 12, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('User: Admin',
                    style: pw.TextStyle(fontSize: 18, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('Total Brands: ${_filteredBrands.length}',
                    style: pw.TextStyle(fontSize: 18, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Brand Name',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Description',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Code',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Status',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont)),
                        ),
                      ],
                    ),
                    ...chunk.map((brand) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(brand['brand'],
                                style: pw.TextStyle(font: regularFont)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(brand['description'],
                                style: pw.TextStyle(font: regularFont)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(brand['Code'],
                                style: pw.TextStyle(font: regularFont)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(brand['status'],
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
      ..setAttribute('download', 'brands_report.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _showAddBrandDialog() {
    String brandName = '';
    String brandDescription = '';
    String brandCode = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Register Brand'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Brand Name'),
                onChanged: (value) {
                  brandName = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  brandDescription = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Code'),
                onChanged: (value) {
                  brandCode = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (brandName.isNotEmpty &&
                    brandDescription.isNotEmpty &&
                    brandCode.isNotEmpty) {
                  setState(() {
                    _brands.add({
                      'number': _brands.length + 1,
                      'brand': brandName,
                      'description': brandDescription,
                      'Code': brandCode,
                      'status': 'Active',
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

  void _showEditBrandDialog(int index) {
    String brandName = _brands[index]['brand'];
    String brandDescription = _brands[index]['description'];
    String brandCode = _brands[index]['Code'];
    String brandStatus = _brands[index]['status'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Brand'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Brand Name'),
                controller: TextEditingController(text: brandName),
                onChanged: (value) {
                  brandName = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                controller: TextEditingController(text: brandDescription),
                onChanged: (value) {
                  brandDescription = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Code'),
                controller: TextEditingController(text: brandCode),
                onChanged: (value) {
                  brandCode = value;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: brandStatus,
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  brandStatus = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _brands[index]['brand'] = brandName;
                  _brands[index]['description'] = brandDescription;
                  _brands[index]['Code'] = brandCode;
                  _brands[index]['status'] = brandStatus;
                });
                Navigator.of(context).pop();
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
        title: const Text('Brands List', style: TextStyle(color: Colors.black)),
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
                  onPressed: _showAddBrandDialog,
                  child: const Text('Add Brand'),
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
                labelText: 'Filter by brand',
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
                  header: const Text('Brands List'),
                  rowsPerPage: _rowsPerPage,
                  onPageChanged: (pageIndex) {
                    setState(() {
                      _currentPage = pageIndex;
                    });
                  },
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Brand')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Code')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Edit')),
                    DataColumn(label: Text('Change Status')),
                  ],
                  source: _BrandsDataSource(
                    data: _filteredBrands,
                    onEdit: (index) => _showEditBrandDialog(index),
                    onChangeStatus: (index) {
                      setState(() {
                        _filteredBrands[index]['status'] =
                            _filteredBrands[index]['status'] == 'Active'
                                ? 'Inactive'
                                : 'Active';
                      });
                    },
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

class _BrandsDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final Function(int index) onEdit;
  final Function(int index) onChangeStatus;

  _BrandsDataSource({
    required this.data,
    required this.onEdit,
    required this.onChangeStatus,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final brand = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(brand['number'].toString())),
        DataCell(Text(brand['brand'])),
        DataCell(Text(brand['description'])),
        DataCell(Text(brand['Code'])),
        DataCell(
          Text(
            brand['status'],
            style: TextStyle(
              color: brand['status'] == 'Active' ? Colors.green : Colors.red,
            ),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => onEdit(index),
          ),
        ),
        DataCell(
          IconButton(
            icon: Icon(
              brand['status'] == 'Active' ? Icons.toggle_on : Icons.toggle_off,
              color: brand['status'] == 'Active' ? Colors.green : Colors.red,
            ),
            onPressed: () => onChangeStatus(index),
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
