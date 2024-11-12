import 'package:flutter/material.dart';

class SalesBody extends StatefulWidget {
  const SalesBody({super.key});

  @override
  State<SalesBody> createState() => _SalesBodyState();
}

class _SalesBodyState extends State<SalesBody> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('This is the sales screen'),
    );
  }
}
