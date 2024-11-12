import 'package:flutter/material.dart';

class CategoriesBody extends StatefulWidget {
  const CategoriesBody({super.key});

  @override
  State<CategoriesBody> createState() => _CategoriesBodyState();
}

class _CategoriesBodyState extends State<CategoriesBody> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('This is the categories screen'),
    );
  }
}
