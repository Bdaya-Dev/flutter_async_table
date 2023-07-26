import 'package:flutter/material.dart';

class RowsPerPageWrapper extends StatefulWidget {
  static const defaultRowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  const RowsPerPageWrapper({
    super.key,
    required this.initialRowsPerPage,
    required this.builder,
  });

  final int initialRowsPerPage;

  final Widget Function(
    BuildContext context,
    int rowsPerPage,
    ValueChanged<int?> setRowsPerPage,
  ) builder;

  @override
  State<RowsPerPageWrapper> createState() => _RowsPerPageWrapperState();
}

class _RowsPerPageWrapperState extends State<RowsPerPageWrapper> {
  late int rowsPerPage;
  @override
  void initState() {
    super.initState();
    rowsPerPage = widget.initialRowsPerPage;
  }

  @override
  void didUpdateWidget(covariant RowsPerPageWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRowsPerPage != widget.initialRowsPerPage) {
      rowsPerPage = widget.initialRowsPerPage;
    }
  }

  void setRowsPerPage(int? rowsPerPage) {
    if (rowsPerPage == null) {
      return;
    }
    setState(() {
      this.rowsPerPage = rowsPerPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, rowsPerPage, setRowsPerPage);
  }
}
