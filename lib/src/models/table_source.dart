import 'package:flutter/material.dart';

class AsyncTableSource<T> extends DataTableSource {
  /// map item to DataRow
  final DataRow Function(
    int index,
    T item,
    bool selected,
    ValueChanged<bool?>? onSelectChanged,
  ) mapItemToRow;
  final selectedRowIndexes = <int>{};

  void doNotifyListeners() {
    notifyListeners();
  }

  int get foldCount => itemsMap.values
      .map((value) => value.length)
      .fold(0, (previousValue, element) => previousValue + element);
  void toggleSelectAll(bool? value) {
    if (value == null) {
      return;
    }
    //
    selectedRowIndexes.clear();
    if (value) {
      selectedRowIndexes.addAll(Iterable.generate(totalCount!));
    }
    notifyListeners();
  }

  void provideItems({
    required int totalCount,
    required int offset,
    required List<T> items,
    required bool isEstimated,
  }) {
    if (isDisposed) return;
    this.totalCount = totalCount;
    itemsMap[offset] = items;
    isExplicitEstimated = isEstimated;
    notifyListeners();
  }

  void reset({bool notify = true}) {
    itemsMap.clear();
    selectedRowIndexes.clear();
    if (notify) {
      notifyListeners();
    }
  }

  bool isDisposed = false;
  @override
  void dispose() {
    isDisposed = true;
    itemsMap.clear();
    selectedRowIndexes.clear();
    super.dispose();
  }

  /// key is offset, limit is [getRowsPerPage]
  final itemsMap = <int, List<T>>{};
  int? totalCount;

  final int Function() getRowsPerPage;
  T? getItemAtIndex(int index, int rowsPerPage) {
    final relativeIndex = index % rowsPerPage;
    final itemsKey = index - relativeIndex;
    final items = itemsMap[itemsKey];
    if (items == null) {
      //items not requested yet
      return null;
    }
    if (relativeIndex >= items.length) {
      return null;
    }
    return items[relativeIndex];
  }

  final void Function(int offset) requestPage;
  final void Function() refresh;
  final bool Function() getCanSelect;
  final GlobalKey<PaginatedDataTableState> Function() getTableKey;

  AsyncTableSource({
    required this.mapItemToRow,
    required this.getRowsPerPage,
    required this.requestPage,
    required this.refresh,
    required this.getCanSelect,
    required this.getTableKey,
  });

  @override
  DataRow? getRow(int index) {
    final item = getItemAtIndex(index, this.getRowsPerPage());
    if (item == null) {
      return null;
    }
    return mapItemToRow(
      index,
      item,
      selectedRowIndexes.contains(index),
      getCanSelect()
          ? (value) {
              if (value == null) return;
              if (value) {
                selectedRowIndexes.add(index);
              } else {
                selectedRowIndexes.remove(index);
              }
              notifyListeners();
            }
          : null,
    );
  }

  bool isExplicitEstimated = false;
  @override
  bool get isRowCountApproximate => isExplicitEstimated || totalCount == null;

  @override
  int get rowCount =>
      totalCount ??
      itemsMap.values
          .map((e) => e.length)
          .fold(0, (value, element) => value + element);

  @override
  int get selectedRowCount => selectedRowIndexes.length;
}
