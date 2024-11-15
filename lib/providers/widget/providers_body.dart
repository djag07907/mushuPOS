import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:html' as html;

class ProvidersBody extends StatefulWidget {
  const ProvidersBody({super.key});

  @override
  State<ProvidersBody> createState() => _ProvidersBodyState();
}

class _ProvidersBodyState extends State<ProvidersBody> {
  final List<Map<String, dynamic>> _providers = List.generate(20, (index) {
    return {
      'number': index + 1,
      'provider': 'Provider name $index',
      'documentType': index % 2 == 0 ? 'ID Card' : 'Passport',
      'documentNumber': 'Document Number $index',
      'phoneNumber': 'Phone Number $index',
      'email': 'Email $index',
      'address': 'Address $index',
      'status': index % 2 == 0 ? 'Active' : 'Inactive',
    };
  });

  String _filter = '';
  int _rowsPerPage = 5;
  int _currentPage = 0;

  List<Map<String, dynamic>> get _filteredProviders {
    return _providers
        .where((provider) => provider['provider']
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
    const int maxRowsPerPage = 5;
    String formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
    print("Filtered Providers: $_filteredProviders");

    for (int i = 0; i < _filteredProviders.length; i += maxRowsPerPage) {
      final chunk = _filteredProviders.sublist(
          i,
          (i + maxRowsPerPage < _filteredProviders.length)
              ? i + maxRowsPerPage
              : _filteredProviders.length);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(pw.MemoryImage(logo), width: 100, height: 100),
                pw.SizedBox(height: 20),
                pw.Text('Providers Report',
                    style: pw.TextStyle(fontSize: 24, font: boldFont)),
                pw.SizedBox(height: 20),
                pw.Text('Generated on: $formattedDate',
                    style: pw.TextStyle(fontSize: 12, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('User: Admin',
                    style: pw.TextStyle(fontSize: 18, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('Total Providers: ${_filteredProviders.length}',
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
                          child: pw.Text('Provider Name',
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
                          child: pw.Text('Document Number',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Phone Number',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Email',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Address',
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
                    ...chunk.map((provider) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(provider['provider'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(provider['documentType'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(provider['documentNumber'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(provider['phoneNumber'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(provider['email'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(provider['address'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(provider['status'] ?? 'N/A',
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
      ..setAttribute('download', 'providers_report.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _showAddProviderDialog() {
    String providerName = '';
    String documentType = 'ID Card';
    String documentNumber = '';
    String phoneNumber = '';
    String email = '';
    String address = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Register Provider'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Provider Name'),
                onChanged: (value) {
                  providerName = value;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Document Type'),
                value: documentType,
                items: const [
                  DropdownMenuItem(value: 'ID Card', child: Text('ID Card')),
                  DropdownMenuItem(value: 'Passport', child: Text('Passport')),
                  DropdownMenuItem(
                      value: 'Driver License', child: Text('Driver License')),
                ],
                onChanged: (value) {
                  documentType = value!;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Document Number'),
                onChanged: (value) {
                  documentNumber = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                onChanged: (value) {
                  phoneNumber = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  email = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Address'),
                onChanged: (value) {
                  address = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (providerName.isNotEmpty && documentNumber.isNotEmpty) {
                  setState(() {
                    _providers.add({
                      'number': _providers.length + 1,
                      'provider': providerName,
                      'documentType': documentType,
                      'documentNumber': documentNumber,
                      'phoneNumber': phoneNumber,
                      'email': email,
                      'address': address,
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

  void _showEditProviderDialog(int index) {
    String providerName = _providers[index]['provider'];
    String documentType = _providers[index]['documentType'];
    String documentNumber = _providers[index]['documentNumber'];
    String phoneNumber = _providers[index]['phoneNumber'];
    String email = _providers[index]['email'];
    String address = _providers[index]['address'];
    String providerStatus = _providers[index]['status'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Provider'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Provider Name'),
                controller: TextEditingController(text: providerName),
                onChanged: (value) {
                  providerName = value;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Document Type'),
                value: documentType,
                items: const [
                  DropdownMenuItem(value: 'ID Card', child: Text('ID Card')),
                  DropdownMenuItem(value: 'Passport', child: Text('Passport')),
                  DropdownMenuItem(
                      value: 'Driver License', child: Text('Driver License')),
                ],
                onChanged: (value) {
                  documentType = value!;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Document Number'),
                controller: TextEditingController(text: documentNumber),
                onChanged: (value) {
                  documentNumber = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                controller: TextEditingController(text: phoneNumber),
                onChanged: (value) {
                  phoneNumber = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                controller: TextEditingController(text: email),
                onChanged: (value) {
                  email = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Address'),
                controller: TextEditingController(text: address),
                onChanged: (value) {
                  address = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _providers[index]['provider'] = providerName;
                  _providers[index]['documentType'] = documentType;
                  _providers[index]['documentNumber'] = documentNumber;
                  _providers[index]['phoneNumber'] = phoneNumber;
                  _providers[index]['email'] = email;
                  _providers[index]['address'] = address;
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
        title:
            const Text('Providers List', style: TextStyle(color: Colors.black)),
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
                  onPressed: _showAddProviderDialog,
                  child: const Text('Add Provider'),
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
                labelText: 'Filter by provider',
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
                  header: const Text('Providers List'),
                  rowsPerPage: _rowsPerPage,
                  onPageChanged: (pageIndex) {
                    setState(() {
                      _currentPage = pageIndex;
                    });
                  },
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Provider')),
                    DataColumn(label: Text('Document Type')),
                    DataColumn(label: Text('Document Number')),
                    DataColumn(label: Text('Phone Number')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Address')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Edit')),
                    DataColumn(label: Text('Change Status')),
                  ],
                  source: _ProvidersDataSource(
                    data: _filteredProviders,
                    onEdit: (index) => _showEditProviderDialog(index),
                    onChangeStatus: (index) {
                      setState(() {
                        _filteredProviders[index]['status'] =
                            _filteredProviders[index]['status'] == 'Active'
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

class _ProvidersDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final Function(int index) onEdit;
  final Function(int index) onChangeStatus;

  _ProvidersDataSource({
    required this.data,
    required this.onEdit,
    required this.onChangeStatus,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final provider = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(provider['number'].toString())),
        DataCell(Text(provider['provider'] ?? 'N/A')),
        DataCell(Text(provider['documentType'] ?? 'N/A')),
        DataCell(Text(provider['documentNumber'] ?? 'N/A')),
        DataCell(Text(provider['phoneNumber'] ?? 'N/A')),
        DataCell(Text(provider['email'] ?? 'N/A')),
        DataCell(Text(provider['address'] ?? 'N/A')),
        DataCell(
          Text(
            provider['status'],
            style: TextStyle(
              color: provider['status'] == 'Active' ? Colors.green : Colors.red,
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
              provider['status'] == 'Active'
                  ? Icons.toggle_on
                  : Icons.toggle_off,
              color: provider['status'] == 'Active' ? Colors.green : Colors.red,
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
