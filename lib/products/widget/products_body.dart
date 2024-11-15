import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;

class ProductsBody extends StatefulWidget {
  const ProductsBody({super.key});

  @override
  State<ProductsBody> createState() => _ProductsBodyState();
}

class _ProductsBodyState extends State<ProductsBody> {
  final List<Map<String, dynamic>> _products = List.generate(20, (index) {
    return {
      'number': index + 1,
      'product': 'Product name $index',
      'productCode': 'Code $index',
      'status': index % 2 == 0 ? 'Active' : 'Inactive',
      'category': 'Category $index',
      'brand': 'Brand $index',
      'sellPrice': 10.0 + index,
      'isvType': 'Type $index',
      'stock': 100,
      'productImage': null,
    };
  });

  String _filter = '';
  int _rowsPerPage = 5;
  int _currentPage = 0;
  TextEditingController _productCodeController = TextEditingController();

  List<Map<String, dynamic>> get _filteredProducts {
    return _products
        .where((product) => product['product']
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

    print("Filtered Products: $_filteredProducts");

    for (int i = 0; i < _filteredProducts.length; i += maxRowsPerPage) {
      final chunk = _filteredProducts.sublist(
          i,
          (i + maxRowsPerPage < _filteredProducts.length)
              ? i + maxRowsPerPage
              : _filteredProducts.length);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(pw.MemoryImage(logo), width: 100, height: 100),
                pw.SizedBox(height: 20),
                pw.Text('Products Report',
                    style: pw.TextStyle(fontSize: 24, font: boldFont)),
                pw.SizedBox(height: 20),
                pw.Text('Generated on: $formattedDate',
                    style: pw.TextStyle(fontSize: 12, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('User: Admin',
                    style: pw.TextStyle(fontSize: 18, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Text('Total Products: ${_filteredProducts.length}',
                    style: pw.TextStyle(fontSize: 18, font: regularFont)),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Product Name',
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
                          child: pw.Text('Status',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont)),
                        ),
                      ],
                    ),
                    ...chunk.map((product) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(product['product'],
                                style: pw.TextStyle(font: regularFont)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(product['ID'],
                                style: pw.TextStyle(font: regularFont)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(product['status'],
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
      ..setAttribute('download', 'products_report.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _showAddProductDialog() {
    String productName = '';
    String category = 'Category 1';
    String brand = 'Brand 1';
    String isvType = 'Type 1';
    double sellPrice = 0.0;
    int stock = 0;
    String? productImage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Register Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                onChanged: (value) {
                  productName = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _productCodeController,
                decoration: const InputDecoration(labelText: 'Product Code'),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _productCodeController,
                builder: (context, value, child) {
                  return Container(
                    height: 100,
                    child: BarcodeWidget(
                      data: value.text.isNotEmpty ? value.text : ' ',
                      width: 100,
                      height: 100,
                      barcode: Barcode.code128(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: category,
                items: const [
                  DropdownMenuItem(
                      value: 'Category 1', child: Text('Category 1')),
                  DropdownMenuItem(
                      value: 'Category 2', child: Text('Category 2')),
                ],
                onChanged: (value) {
                  category = value!;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Brand'),
                value: brand,
                items: const [
                  DropdownMenuItem(value: 'Brand 1', child: Text('Brand 1')),
                  DropdownMenuItem(value: 'Brand 2', child: Text('Brand 2')),
                ],
                onChanged: (value) {
                  brand = value!;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Sell Price'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  sellPrice = double.tryParse(value) ?? 0.0;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  stock = int.tryParse(value) ?? 0;
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  // TODO: Image upload logic here
                },
                child: const Text('Upload Image'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (productName.isNotEmpty &&
                    _productCodeController.text.isNotEmpty) {
                  setState(() {
                    _products.add({
                      'number': _products.length + 1,
                      'product': productName,
                      'productCode': _productCodeController.text,
                      'status': 'Active',
                      'category': category,
                      'brand': brand,
                      'sellPrice': sellPrice,
                      'isvType': isvType,
                      'stock': stock,
                      'productImage': productImage,
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

  void _showEditProductDialog(int index) {
    String productName = _products[index]['product'];
    String productCode = _products[index]['productCode'];
    String category = _products[index]['category'];
    String brand = _products[index]['brand'];
    double sellPrice = _products[index]['sellPrice'];
    int stock = _products[index]['stock'];
    String productStatus = _products[index]['status'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(index == null ? 'Register Product' : 'Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                controller: TextEditingController(text: productName),
                onChanged: (value) {
                  productName = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _productCodeController,
                decoration: const InputDecoration(labelText: 'Product Code'),
                onChanged: (value) {
                  productCode = value;
                },
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _productCodeController,
                builder: (context, value, child) {
                  return Container(
                    height: 100,
                    child: BarcodeWidget(
                      data: value.text.isNotEmpty ? value.text : ' ',
                      width: 100,
                      height: 100,
                      barcode: Barcode.code128(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: category,
                items: const [
                  DropdownMenuItem(
                      value: 'Category 1', child: Text('Category 1')),
                  DropdownMenuItem(
                      value: 'Category 2', child: Text('Category 2')),
                ],
                onChanged: (value) {
                  category = value!;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Brand'),
                value: brand,
                items: const [
                  DropdownMenuItem(value: 'Brand 1', child: Text('Brand 1')),
                  DropdownMenuItem(value: 'Brand 2', child: Text('Brand 2')),
                ],
                onChanged: (value) {
                  brand = value!;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Sell Price'),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: sellPrice.toString()),
                onChanged: (value) {
                  sellPrice = double.tryParse(value) ?? 0.0;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: stock.toString()),
                onChanged: (value) {
                  stock = int.tryParse(value) ?? 0;
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  //TODO: Image upload logic here
                },
                child: const Text('Upload Image'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (productName.isNotEmpty && productCode.isNotEmpty) {
                  setState(() {
                    if (index == null) {
                      _products.add({
                        'number': _products.length + 1,
                        'product': productName,
                        'productCode': productCode,
                        'status': productStatus,
                        'category': category,
                        'brand': brand,
                        'sellPrice': sellPrice,
                        'isvType': 'Type 1',
                        'stock': stock,
                        'productImage': null,
                      });
                    } else {
                      _products[index] = {
                        'number': index + 1,
                        'product': productName,
                        'productCode': productCode,
                        'status': productStatus,
                        'category': category,
                        'brand': brand,
                        'sellPrice': sellPrice,
                        'isvType': 'Type 1',
                        'stock': stock,
                        'productImage': null,
                      };
                    }
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
        title:
            const Text('Products List', style: TextStyle(color: Colors.black)),
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
                  onPressed: _showAddProductDialog,
                  child: const Text('Add Product'),
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
                labelText: 'Filter by product',
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
                  header: const Text('Products List'),
                  rowsPerPage: _rowsPerPage,
                  onPageChanged: (pageIndex) {
                    setState(() {
                      _currentPage = pageIndex;
                    });
                  },
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Product')),
                    DataColumn(label: Text('Product Code')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Brand')),
                    DataColumn(label: Text('Sell Price')),
                    DataColumn(label: Text('ISV Type')),
                    DataColumn(label: Text('Stock')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Edit')),
                    DataColumn(label: Text('Change Status')),
                  ],
                  source: _ProductsDataSource(
                    data: _filteredProducts,
                    onEdit: (index) => _showEditProductDialog(index),
                    onChangeStatus: (index) {
                      setState(() {
                        _filteredProducts[index]['status'] =
                            _filteredProducts[index]['status'] == 'Active'
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

class _ProductsDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final Function(int index) onEdit;
  final Function(int index) onChangeStatus;

  _ProductsDataSource({
    required this.data,
    required this.onEdit,
    required this.onChangeStatus,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final product = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(product['number'].toString())),
        DataCell(Text(product['product'])),
        DataCell(Text(product['productCode'])),
        DataCell(Text(product['category'])),
        DataCell(Text(product['brand'])),
        DataCell(Text(product['sellPrice'].toString())),
        DataCell(Text(product['isvType'])),
        DataCell(Text(product['stock'].toString())),
        DataCell(
          Text(
            product['status'],
            style: TextStyle(
              color: product['status'] == 'Active' ? Colors.green : Colors.red,
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
              product['status'] == 'Active'
                  ? Icons.toggle_on
                  : Icons.toggle_off,
              color: product['status'] == 'Active' ? Colors.green : Colors.red,
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
