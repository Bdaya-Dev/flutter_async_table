import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../models/actions_builder_params.dart';
import '../models/column_def.dart';
import '../models/response.dart';
import '../models/table_source.dart';

class AsyncTableWidget<T> extends StatefulWidget {
  const AsyncTableWidget({
    super.key,
    required this.columns,
    required this.requestItems,
    this.initState,
    this.rowBuilder,
    this.rowsPerPage = PaginatedDataTable.defaultRowsPerPage,
    this.availableRowsPerPage = const <int>[
      PaginatedDataTable.defaultRowsPerPage,
      PaginatedDataTable.defaultRowsPerPage * 2,
      PaginatedDataTable.defaultRowsPerPage * 5,
      PaginatedDataTable.defaultRowsPerPage * 10
    ],
    this.sortColumnIndex,
    this.sortAscending = true,
    this.dataRowMinHeight,
    this.dataRowMaxHeight,
    this.headingRowHeight = 56.0,
    this.horizontalMargin = 24.0,
    this.columnSpacing = 56.0,
    this.showCheckboxColumn = true,
    this.showFirstLastButtons = false,
    this.initialFirstRowIndex = 0,
    this.onPageChanged,
    this.onRowsPerPageChanged,
    this.dragStartBehavior = DragStartBehavior.start,
    this.arrowHeadColor,
    this.checkboxHorizontalMargin,
    this.scrollController,
    this.primary,
    this.actions,
    this.header,
    this.canSelect = true,
    
  });

  ///Requests items at a specific zero-based page index and with a specific limit
  final Future<AsyncTableItemsResponse<T>> Function(int offset, int limit)
      requestItems;

  ///The columns to display
  final List<AsyncTableColumnDef<T>> columns;

  ///(Optional) Customize how the datarow looks like
  final DataRow Function(
    int index,
    T item,
    List<DataCell> cells,
    bool selected,
    ValueChanged<bool?>? onSelectChanged,
  )? rowBuilder;

  ///Called when the datasource gets initialized
  final ValueChanged<AsyncTableSource<T>>? initState;

  ///initial rowsPerPage value (must be one of the items in [availableRowsPerPage])
  final int rowsPerPage;

  ///Whether selections are enabled in general
  final bool canSelect;

  /// Invoked when the user selects a different number of rows per page.
  ///
  /// If this is null, then the value given by [rowsPerPage] will be used
  /// and no affordance will be provided to change the value.
  final ValueChanged<int?>? onRowsPerPageChanged;

  /// The table card's optional header.
  ///
  /// This is typically a [Text] widget, but can also be a [Row] of
  /// [TextButton]s. To show icon buttons at the top end side of the table with
  /// a header, set the [actions] property.
  ///
  /// If items in the table are selectable, then, when the selection is not
  /// empty, the header is replaced by a count of the selected items. The
  /// [actions] are still visible when items are selected.
  final Widget? header;

  /// Icon buttons to show at the top end side of the table. The [header] must
  /// not be null to show the actions.
  ///
  /// Typically, the exact actions included in this list will vary based on
  /// whether any rows are selected or not.
  ///
  /// These should be size 24.0 with default padding (8.0).
  final List<Widget> Function(
    BuildContext context,
    ActionsBuilderParams<T> params,
  )? actions;

  /// The current primary sort key's column.
  ///
  /// See [DataTable.sortColumnIndex].
  final int? sortColumnIndex;

  /// Whether the column mentioned in [sortColumnIndex], if any, is sorted
  /// in ascending order.
  ///
  /// See [DataTable.sortAscending].
  final bool sortAscending;

  final double? dataRowMinHeight;
  final double? dataRowMaxHeight;

  /// The height of the heading row.
  ///
  /// This value is optional and defaults to 56.0 if not specified.
  final double headingRowHeight;

  /// The horizontal margin between the edges of the table and the content
  /// in the first and last cells of each row.
  ///
  /// When a checkbox is displayed, it is also the margin between the checkbox
  /// the content in the first data column.
  ///
  /// This value defaults to 24.0 to adhere to the Material Design specifications.
  ///
  /// If [checkboxHorizontalMargin] is null, then [horizontalMargin] is also the
  /// margin between the edge of the table and the checkbox, as well as the
  /// margin between the checkbox and the content in the first data column.
  final double horizontalMargin;

  /// The horizontal margin between the contents of each data column.
  ///
  /// This value defaults to 56.0 to adhere to the Material Design specifications.
  final double columnSpacing;

  /// {@macro flutter.material.dataTable.showCheckboxColumn}
  final bool showCheckboxColumn;

  /// Flag to display the pagination buttons to go to the first and last pages.
  final bool showFirstLastButtons;

  /// The index of the first row to display when the widget is first created.
  final int? initialFirstRowIndex;

  /// Invoked when the user switches to another page.
  ///
  /// The value is the index of the first row on the currently displayed page.
  final ValueChanged<int>? onPageChanged;

  /// The options to offer for the rowsPerPage.
  ///
  /// The current [rowsPerPage] must be a value in this list.
  ///
  /// The values in this list should be sorted in ascending order.
  final List<int> availableRowsPerPage;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// Horizontal margin around the checkbox, if it is displayed.
  ///
  /// If null, then [horizontalMargin] is used as the margin between the edge
  /// of the table and the checkbox, as well as the margin between the checkbox
  /// and the content in the first data column. This value defaults to 24.0.
  final double? checkboxHorizontalMargin;

  /// Defines the color of the arrow heads in the footer.
  final Color? arrowHeadColor;

  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController? scrollController;

  /// {@macro flutter.widgets.scroll_view.primary}
  final bool? primary;

  @override
  State<AsyncTableWidget<T>> createState() => AsyncTableWidgetState<T>();
}

class AsyncTableWidgetState<T> extends State<AsyncTableWidget<T>> {
  int currentOffset = 0;
  GlobalObjectKey<PaginatedDataTableState>? tableKey;

  /*
  if (tableKey?.value != value) {
      tableKey = GlobalObjectKey(value);
    }
  */
  late final AsyncTableSource<T> source = AsyncTableSource<T>(
    getTableKey: () => tableKey!,
    getCanSelect: () => widget.canSelect,
    refresh: () {
      source.reset();
      doRequestOffset(currentOffset);
    },
    getRowsPerPage: () => widget.rowsPerPage,
    requestPage: (pageIndex) => doRequestOffset(pageIndex),
    mapItemToRow: (index, item, selected, onSelectChanged) {
      final cells =
          widget.columns.map((e) => e.cellBuilder(context, item)).toList();
      return widget.rowBuilder
              ?.call(index, item, cells, selected, onSelectChanged) ??
          DataRow.byIndex(
            index: index,
            selected: selected,
            onSelectChanged: onSelectChanged,
            cells: cells,
          );
    },
  );

  @override
  void initState() {
    super.initState();
    tableKey = GlobalObjectKey(widget.rowsPerPage);
    widget.initState?.call(source);
    doRequestOffset(0);
  }

  @override
  void didUpdateWidget(covariant AsyncTableWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rowsPerPage != oldWidget.rowsPerPage) {
      tableKey = GlobalObjectKey(widget.rowsPerPage);
      source.reset(notify: false);
      doRequestOffset(0);
    }
    source.doNotifyListeners();
  }

  @override
  void dispose() {
    source.dispose();
    super.dispose();
  }

  void doRequestOffset(int offset) {
    widget.requestItems(offset, widget.rowsPerPage).then(
          (resp) => source.provideItems(
            offset: offset,
            items: resp.items,
            totalCount: resp.totalCount,
            isEstimated: resp.isEstimated,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: source,
      builder: (context, child) => PaginatedDataTable(
        key: tableKey,
        columns: widget.columns.map((e) => e.column).toList(),
        source: source,
        onSelectAll: widget.canSelect
            ? source.totalCount == null
                ? null
                : (value) => source.toggleSelectAll(value)
            : null,
        onRowsPerPageChanged: widget.onRowsPerPageChanged,
        availableRowsPerPage: widget.availableRowsPerPage,
        //BuildContext context, int totalCount, int selectedCount, List<T> availableSelected
        actions: widget.actions?.call(
          context,
          ActionsBuilderParams(
            deleteIndexesFromTable: (indexes) {
              if (indexes.isEmpty) return;
              final lowestIndex = indexes.fold(
                0,
                (previousValue, element) =>
                    element < previousValue ? element : previousValue,
              );
              final lowestPageIndex =
                  (lowestIndex / widget.rowsPerPage).floor();
              final nonDeleted = source.selectedRowIndexes.difference(indexes);
              //remove deleted indexes
              source.selectedRowIndexes.clear();
              source.selectedRowIndexes
                  .addAll(nonDeleted.map((nonDeletedIndex) {
                final indexesBeforeNonDeleted = indexes
                    .where((element) => element < nonDeletedIndex)
                    .length;
                return nonDeletedIndex - indexesBeforeNonDeleted;
              }));
              //shift nonDeleted indexes backwards
              source.itemsMap
                  .removeWhere((key, value) => key >= lowestPageIndex);
              source.doNotifyListeners();
            },
            refresh: () {
              doRequestOffset(currentOffset);
              source.doNotifyListeners();
            },
            totalCount: source.totalCount,
            selectedCount: source.selectedRowCount,
            availableSelected: source.selectedRowIndexes
                .map((e) =>
                    MapEntry(e, source.getItemAtIndex(e, widget.rowsPerPage)))
                .toList(),
          ),
        ),
        arrowHeadColor: widget.arrowHeadColor,
        rowsPerPage: widget.rowsPerPage,
        checkboxHorizontalMargin: widget.checkboxHorizontalMargin,
        columnSpacing: widget.columnSpacing,
        controller: widget.scrollController,
        dataRowMinHeight: widget.dataRowMinHeight,
        dataRowMaxHeight: widget.dataRowMaxHeight,
        dragStartBehavior: widget.dragStartBehavior,
        header: widget.header,
        headingRowHeight: widget.headingRowHeight,
        horizontalMargin: widget.horizontalMargin,
        initialFirstRowIndex: widget.initialFirstRowIndex,
        primary: widget.primary,
        showCheckboxColumn: widget.showCheckboxColumn,
        sortColumnIndex: widget.sortColumnIndex,
        showFirstLastButtons: widget.showFirstLastButtons,
        sortAscending: widget.sortAscending,
        onPageChanged: (rowIndex) {
          if (!source.itemsMap.containsKey(rowIndex)) {
            doRequestOffset(rowIndex);
          }
          currentOffset = rowIndex;
          widget.onPageChanged?.call(rowIndex);
        },
      ),
    );
  }
}
