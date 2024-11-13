import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;

class UsersBody extends StatefulWidget {
  const UsersBody({super.key});
  @override
  State<UsersBody> createState() => _UsersBodyState();
}

class _UsersBodyState extends State<UsersBody> {
  final List<Map<String, dynamic>> _users = List.generate(20, (index) {
    return {
      'number': index + 1,
      'user': 'User name $index',
      'documentType': 'Document Type $index',
      'phoneNumber': '123-456-7890',
      'address': 'Address $index',
      'email': 'user$index@example.com',
      'username': 'username$index',
      'role': 'User',
      'status': index % 2 == 0 ? 'Active' : 'Inactive',
      'image': 'assets/images/point-of-sale.png'
    };
  });

  String _filter = '';
  int _rowsPerPage = 5;
  int _currentPage = 0;

  List<Map<String, dynamic>> get _filteredUsers {
    return _users
        .where((user) => user['user']
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

    for (int i = 0; i < _filteredUsers.length; i += maxRowsPerPage) {
      final chunk = _filteredUsers.sublist(
          i,
          (i + maxRowsPerPage < _filteredUsers.length)
              ? i + maxRowsPerPage
              : _filteredUsers.length);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(pw.MemoryImage(logo), width: 100, height: 100),
                pw.SizedBox(height: 20),
                pw.Text('Users Report',
                    style: pw.TextStyle(fontSize: 24, font: boldFont)),
                pw.SizedBox(height: 20),
                pw.Text('Generated on: $formattedDate',
                    style: pw.TextStyle(fontSize: 12, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('User: Admin',
                    style: pw.TextStyle(fontSize: 18, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('Total Users: ${_filteredUsers.length}',
                    style: pw.TextStyle(fontSize: 18, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text('User Name',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    font: boldFont))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text('Document Type',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    font: boldFont))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text('Phone Number',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    font: boldFont))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text('Address',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    font: boldFont))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text('Email',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    font: boldFont))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text('Username',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    font: boldFont))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text('Role',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    font: boldFont))),
                      ],
                    ),
                    ...chunk.map((user) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: pw.Text(user['user'],
                                  style: pw.TextStyle(font: regularFont))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: pw.Text(user['documentType'],
                                  style: pw.TextStyle(font: regularFont))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: pw.Text(user['phoneNumber'],
                                  style: pw.TextStyle(font: regularFont))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: pw.Text(user['address'],
                                  style: pw.TextStyle(font: regularFont))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: pw.Text(user['email'],
                                  style: pw.TextStyle(font: regularFont))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: pw.Text(user['username'],
                                  style: pw.TextStyle(font: regularFont))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: pw.Text(user['role'],
                                  style: pw.TextStyle(font: regularFont))),
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
      ..setAttribute('download', 'users_report.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _showAddUserDialog() {
    String userName = '';
    String userCode = '';
    String documentType = '';
    String phoneNumber = '';
    String address = '';
    String email = '';
    String username = '';
    String role = 'User';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Register User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'User Name'),
                onChanged: (value) {
                  userName = value;
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
                decoration: const InputDecoration(labelText: 'Phone Number'),
                onChanged: (value) {
                  phoneNumber = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Address'),
                onChanged: (value) {
                  address = value;
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
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (value) {
                  username = value;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                value: role,
                items: const [
                  DropdownMenuItem(value: 'User', child: Text('User')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                ],
                onChanged: (value) {
                  role = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (userName.isNotEmpty &&
                    documentType.isNotEmpty &&
                    phoneNumber.isNotEmpty &&
                    address.isNotEmpty &&
                    email.isNotEmpty &&
                    username.isNotEmpty) {
                  setState(() {
                    _users.add({
                      'number': _users.length + 1,
                      'user': userName,
                      'documentType': documentType,
                      'phoneNumber': phoneNumber,
                      'address': address,
                      'email': email,
                      'username': username,
                      'role': role,
                      'status': 'Active',
                      'image': 'assets/images/point-of-sale.png',
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

  void _showEditUserDialog(int index) {
    String userName = _users[index]['user'];
    String documentType = _users[index]['documentType'];
    String phoneNumber = _users[index]['phoneNumber'];
    String address = _users[index]['address'];
    String email = _users[index]['email'];
    String username = _users[index]['username'];
    String role = _users[index]['role'];
    String userstatus = _users[index]['status'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'User Name'),
                controller: TextEditingController(text: userName),
                onChanged: (value) {
                  userName = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Document Type'),
                controller: TextEditingController(text: documentType),
                onChanged: (value) {
                  documentType = value;
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
                decoration: const InputDecoration(labelText: 'Address'),
                controller: TextEditingController(text: address),
                onChanged: (value) {
                  address = value;
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
                decoration: const InputDecoration(labelText: 'Username'),
                controller: TextEditingController(text: username),
                onChanged: (value) {
                  username = value;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                value: role,
                items: const [
                  DropdownMenuItem(value: 'User', child: Text('User')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                ],
                onChanged: (value) {
                  role = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _users[index]['user'] = userName;
                  _users[index]['documentType'] = documentType;
                  _users[index]['phoneNumber'] = phoneNumber;
                  _users[index]['address'] = address;
                  _users[index]['email'] = email;
                  _users[index]['username'] = username;
                  _users[index]['role'] = role;
                  _users[index]['status'] = userstatus;
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
        title: const Text('Users List', style: TextStyle(color: Colors.black)),
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
                  onPressed: _showAddUserDialog,
                  child: const Text('Add User'),
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
                labelText: 'Filter by user',
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
                  header: const Text('Users List'),
                  rowsPerPage: _rowsPerPage,
                  onPageChanged: (pageIndex) {
                    setState(() {
                      _currentPage = pageIndex;
                    });
                  },
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Document Type')),
                    DataColumn(label: Text('Phone Number')),
                    DataColumn(label: Text('Address')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Username')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Edit')),
                    DataColumn(label: Text('Change Status')),
                  ],
                  source: _UsersDataSource(
                    data: _filteredUsers,
                    onEdit: (index) => _showEditUserDialog(index),
                    onChangeStatus: (index) {
                      setState(() {
                        _filteredUsers[index]['status'] =
                            _filteredUsers[index]['status'] == 'Active'
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

class _UsersDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final Function(int index) onEdit;
  final Function(int index) onChangeStatus;

  _UsersDataSource({
    required this.data,
    required this.onEdit,
    required this.onChangeStatus,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final user = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(user['number'].toString())),
        DataCell(Text(user['user'])),
        DataCell(Text(user['documentType'])),
        DataCell(Text(user['phoneNumber'])),
        DataCell(Text(user['address'])),
        DataCell(Text(user['email'])),
        DataCell(Text(user['username'])),
        DataCell(Text(user['role'])),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => onEdit(index),
          ),
        ),
        DataCell(
          IconButton(
            icon: Icon(
              user['status'] == 'Active' ? Icons.toggle_on : Icons.toggle_off,
              color: user['status'] == 'Active' ? Colors.green : Colors.red,
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
