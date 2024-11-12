import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;

class CategoriesBody extends StatefulWidget {
  const CategoriesBody({super.key});

  @override
  State<CategoriesBody> createState() => _CategoriesBodyState();
}

class _CategoriesBodyState extends State<CategoriesBody> {
  final List<Map<String, dynamic>> _categories = List.generate(20, (index) {
    return {
      'number': index + 1,
      'category': 'Category $index',
      'description': 'Description for Category $index',
      'status': index % 2 == 0 ? 'Active' : 'Inactive',
    };
  });

  String _filter = '';
  int _rowsPerPage = 5;
  int _currentPage = 0;

  List<Map<String, dynamic>> get _filteredCategories {
    return _categories
        .where((category) => category['category']
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

    print("Filtered Categories: $_filteredCategories");

    for (int i = 0; i < _filteredCategories.length; i += maxRowsPerPage) {
      final chunk = _filteredCategories.sublist(
          i,
          (i + maxRowsPerPage < _filteredCategories.length)
              ? i + maxRowsPerPage
              : _filteredCategories.length);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(pw.MemoryImage(logo), width: 100, height: 100),
                pw.SizedBox(height: 20),
                pw.Text('Categories Report',
                    style: pw.TextStyle(fontSize: 24, font: boldFont)),
                pw.SizedBox(height: 20),
                pw.Text('Generated on: $formattedDate',
                    style: pw.TextStyle(fontSize: 12, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('User: Admin',
                    style: pw.TextStyle(fontSize: 18, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('Total Categories: ${_filteredCategories.length}',
                    style: pw.TextStyle(fontSize: 18, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Category Name',
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
                          child: pw.Text('Status',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont)),
                        ),
                      ],
                    ),
                    ...chunk.map((category) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(category['category'],
                                style: pw.TextStyle(font: regularFont)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(category['description'],
                                style: pw.TextStyle(font: regularFont)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(category['status'],
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
      ..setAttribute('download', 'categories_report.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _showAddCategoryDialog() {
    String categoryName = '';
    String categoryDescription = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Register Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Category Name'),
                onChanged: (value) {
                  categoryName = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  categoryDescription = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (categoryName.isNotEmpty && categoryDescription.isNotEmpty) {
                  setState(() {
                    _categories.add({
                      'number': _categories.length + 1,
                      'category': categoryName,
                      'description': categoryDescription,
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

  void _showEditCategoryDialog(int index) {
    String categoryName = _categories[index]['category'];
    String categoryDescription = _categories[index]['description'];
    String categoryStatus = _categories[index]['status'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Category Name'),
                controller: TextEditingController(text: categoryName),
                onChanged: (value) {
                  categoryName = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                controller: TextEditingController(text: categoryDescription),
                onChanged: (value) {
                  categoryDescription = value;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: categoryStatus,
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  categoryStatus = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _categories[index]['category'] = categoryName;
                  _categories[index]['description'] = categoryDescription;
                  _categories[index]['status'] = categoryStatus;
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
        title: const Text('Categories List',
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
                  onPressed: _showAddCategoryDialog,
                  child: const Text('Add Category'),
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
                labelText: 'Filter by category',
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
                  header: const Text('Categories List'),
                  rowsPerPage: _rowsPerPage,
                  onPageChanged: (pageIndex) {
                    setState(() {
                      _currentPage = pageIndex;
                    });
                  },
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Edit')),
                    DataColumn(label: Text('Change Status')),
                  ],
                  source: _CategoriesDataSource(
                    data: _filteredCategories,
                    onEdit: (index) => _showEditCategoryDialog(index),
                    onChangeStatus: (index) {
                      setState(() {
                        _filteredCategories[index]['status'] =
                            _filteredCategories[index]['status'] == 'Active'
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

class _CategoriesDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final Function(int index) onEdit;
  final Function(int index) onChangeStatus;

  _CategoriesDataSource({
    required this.data,
    required this.onEdit,
    required this.onChangeStatus,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final category = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(category['number'].toString())),
        DataCell(Text(category['category'])),
        DataCell(Text(category['description'])),
        DataCell(
          Text(
            category['status'],
            style: TextStyle(
              color: category['status'] == 'Active' ? Colors.green : Colors.red,
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
              category['status'] == 'Active'
                  ? Icons.toggle_on
                  : Icons.toggle_off,
              color: category['status'] == 'Active' ? Colors.green : Colors.red,
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
