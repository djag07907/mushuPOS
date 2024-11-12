import 'package:flutter/material.dart';

class CategoriesBody extends StatefulWidget {
  const CategoriesBody({super.key});

  @override
  State<CategoriesBody> createState() => _CategoriesBodyState();
}

class _CategoriesBodyState extends State<CategoriesBody> {
  final List<Map<String, dynamic>> _categories = List.generate(10, (index) {
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
                  onPressed: () {
                    // Export PDF functionality
                  },
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
