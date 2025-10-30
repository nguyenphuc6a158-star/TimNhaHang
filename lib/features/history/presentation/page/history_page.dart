import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final String uid;
  const HistoryPage({
    super.key,
    required this.uid,
  });
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}
class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(widget.uid),
    );
  }
}