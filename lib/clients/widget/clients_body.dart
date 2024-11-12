import 'package:flutter/material.dart';

class ClientsBody extends StatefulWidget {
  const ClientsBody({super.key});

  @override
  State<ClientsBody> createState() => _ClientsBodyState();
}

class _ClientsBodyState extends State<ClientsBody> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('This is the clients screen'),
    );
  }
}
