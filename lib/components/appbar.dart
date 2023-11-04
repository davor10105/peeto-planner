import 'package:flutter/material.dart';

PreferredSizeWidget getPeetoAppBar(BuildContext context) {
  return AppBar(
    foregroundColor: Theme.of(context).primaryColor,
    title: Text(
      'Miu',
      style: Theme.of(context).textTheme.displayLarge,
    ),
    backgroundColor: Colors.white,
  );
}
