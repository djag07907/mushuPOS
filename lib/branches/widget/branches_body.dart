import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:html' as html;

class BranchesBody extends StatefulWidget {
  const BranchesBody({super.key});

  @override
  State<BranchesBody> createState() => _BranchesBodyState();
}

class _BranchesBodyState extends State<BranchesBody> {
  final List<Map<String, dynamic>> _branches = List.generate(20, (index) {
    return {
      'number': index + 1,
      'branchName': 'Branch $index',
      'location': 'Location $index',
      'contactNumber': 'Contact Number $index',
      'email': 'Email $index',
      'status': index % 2 == 0 ? 'Active' : 'Inactive',
    };
  });

  String _filter = '';
  int _rowsPerPage = 5;
  int _currentPage = 0;

  List<Map<String, dynamic>> get _filteredBranches {
    return _branches
        .where((branch) => branch['branchName']
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
    print("Filtered Branches: $_filteredBranches");

    for (int i = 0; i < _filteredBranches.length; i += maxRowsPerPage) {
      final chunk = _filteredBranches.sublist(
          i,
          (i + maxRowsPerPage < _filteredBranches.length)
              ? i + maxRowsPerPage
              : _filteredBranches.length);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(pw.MemoryImage(logo), width: 100, height: 100),
                pw.SizedBox(height: 20),
                pw.Text('Branches Report',
                    style: pw.TextStyle(fontSize: 24, font: boldFont)),
                pw.SizedBox(height: 20),
                pw.Text('Generated on: $formattedDate',
                    style: pw.TextStyle(fontSize: 12, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('User: Admin',
                    style: pw.TextStyle(fontSize: 18, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('Total Branches: ${_filteredBranches.length}',
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
                    5: pw.FixedColumnWidth(50.0),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Branch Name',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Location',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('Contact Number',
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
                          child: pw.Text('Status',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                  fontSize: 10)),
                        ),
                      ],
                    ),
                    ...chunk.map((branch) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(branch['branchName'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(branch['location'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(branch['contactNumber'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(branch['email'] ?? 'N/A',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 9)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4.0),
                            child: pw.Text(branch['status'] ?? 'N/A',
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
      ..setAttribute('download', 'branches_report.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _showAddBranchDialog() {
    String branchName = '';
    String location = '';
    String contactNumber = '';
    String email = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Register Branch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Branch Name'),
                onChanged: (value) {
                  branchName = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Location'),
                onChanged: (value) {
                  location = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Contact Number'),
                onChanged: (value) {
                  contactNumber = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  email = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (branchName.isNotEmpty && location.isNotEmpty) {
                  setState(() {
                    _branches.add({
                      'number': _branches.length + 1,
                      'branchName': branchName,
                      'location': location,
                      'contactNumber': contactNumber,
                      'email': email,
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

  void _showEditBranchDialog(int index) {
    String branchName = _branches[index]['branchName'];
    String location = _branches[index]['location'];
    String contactNumber = _branches[index]['contactNumber'];
    String email = _branches[index]['email'];
    String branchStatus = _branches[index]['status'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Branch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Branch Name'),
                controller: TextEditingController(text: branchName),
                onChanged: (value) {
                  branchName = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Location'),
                controller: TextEditingController(text: location),
                onChanged: (value) {
                  location = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Contact Number'),
                controller: TextEditingController(text: contactNumber),
                onChanged: (value) {
                  contactNumber = value;
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
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: branchStatus,
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  branchStatus = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _branches[index]['branchName'] = branchName;
                  _branches[index]['location'] = location;
                  _branches[index]['contactNumber'] = contactNumber;
                  _branches[index]['email'] = email;
                  _branches[index]['status'] = branchStatus;
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
            const Text('Branches List', style: TextStyle(color: Colors.black)),
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
                  onPressed: _showAddBranchDialog,
                  child: const Text('Add Branch'),
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
                labelText: 'Filter by branch',
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
                  header: const Text('Branches List'),
                  rowsPerPage: _rowsPerPage,
                  onPageChanged: (pageIndex) {
                    setState(() {
                      _currentPage = pageIndex;
                    });
                  },
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Branch Name')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Contact Number')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Edit')),
                    DataColumn(label: Text('Change Status')),
                  ],
                  source: _BranchesDataSource(
                    data: _filteredBranches,
                    onEdit: (index) => _showEditBranchDialog(index),
                    onChangeStatus: (index) {
                      setState(() {
                        _filteredBranches[index]['status'] =
                            _filteredBranches[index]['status'] == 'Active'
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

class _BranchesDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final Function(int index) onEdit;
  final Function(int index) onChangeStatus;

  _BranchesDataSource({
    required this.data,
    required this.onEdit,
    required this.onChangeStatus,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final branch = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(branch['number'].toString())),
        DataCell(Text(branch['branchName'] ?? 'N/A')),
        DataCell(Text(branch['location'] ?? 'N/A')),
        DataCell(Text(branch['contactNumber'] ?? 'N/A')),
        DataCell(Text(branch['email'] ?? 'N/A')),
        DataCell(
          Text(
            branch['status'],
            style: TextStyle(
              color: branch['status'] == 'Active' ? Colors.green : Colors.red,
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
              branch['status'] == 'Active' ? Icons.toggle_on : Icons.toggle_off,
              color: branch['status'] == 'Active' ? Colors.green : Colors.red,
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
