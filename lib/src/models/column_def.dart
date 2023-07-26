import 'package:flutter/material.dart';

class AsyncTableColumnDef<T> {
  final DataColumn column;
  final DataCell Function(BuildContext context, T item) cellBuilder;

  const AsyncTableColumnDef({
    required this.column,
    required this.cellBuilder,
  });
}

