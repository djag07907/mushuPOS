import 'package:flutter/material.dart';

class BranchesBody extends StatefulWidget {
  const BranchesBody({super.key});

  @override
  State<BranchesBody> createState() => _BranchesBodyState();
}

class _BranchesBodyState extends State<BranchesBody> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('This is the branch screen'),
    );
  }
}
