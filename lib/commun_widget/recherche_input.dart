import 'package:flutter/material.dart';

class RechercheInput extends StatelessWidget {
  const RechercheInput({super.key});

  @override
  Widget build(BuildContext context) {
    return const  Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter a search term',
        ),
      ),
    );
  }
}
