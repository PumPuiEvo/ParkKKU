import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class LocateBtn extends StatefulWidget {
  const LocateBtn({super.key});

  @override
  State<LocateBtn> createState() => _LocateBtnState();
}

class _LocateBtnState extends State<LocateBtn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        children: [
          FloatingActionButton.small(
            child: const Icon(Icons.edit),
            onPressed: () {},
          ),
          FloatingActionButton.small(
            child: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
