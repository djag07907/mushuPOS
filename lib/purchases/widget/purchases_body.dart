import 'package:flutter/material.dart';

class PurchasesBody extends StatefulWidget {
  const PurchasesBody({super.key});

  @override
  State<PurchasesBody> createState() => _PurchasesBodyState();
}

class _PurchasesBodyState extends State<PurchasesBody> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('This is the purchases screen'),
    );
  }
}
