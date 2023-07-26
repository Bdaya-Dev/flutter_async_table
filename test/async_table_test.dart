import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:async_table/async_table.dart';

import '_models.dart';

final db = MyFakeDatabase();

void main() {
  testWidgets('AsyncTableWidget initial state (first page)', (tester) async {
    // Test code goes here
    final k = GlobalKey<AsyncTableWidgetState<MyModel>>();
    AsyncTableSource<MyModel>? dataSrc;
    const rowsPerPage = 6;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AsyncTableWidget<MyModel>(
            key: k,
            requestItems: db.getPage,
            rowsPerPage: rowsPerPage,
            availableRowsPerPage: const [rowsPerPage, rowsPerPage * 2],
            columns: [
              AsyncTableColumnDef(
                cellBuilder: (context, item) => DataCell(Text(item.id)),
                column: const DataColumn(label: Text('Id')),
              ),
              AsyncTableColumnDef(
                cellBuilder: (context, item) => DataCell(Text(item.title)),
                column: const DataColumn(label: Text('Title')),
              ),
            ],
            initState: (value) => dataSrc = value,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final allItems = db.items;
    final ds = dataSrc;
    expect(ds, isNotNull);
    expect(ds!.itemsMap.length, 1);
    expect(ds.itemsMap.keys.first, 0);
    expect(ds.itemsMap.values.first.length, rowsPerPage);
    final firstPage = allItems.skip(0).take(rowsPerPage).toList();
    expect(ds.itemsMap.values.first, firstPage);
    final tableKey =
        ds.getTableKey() as GlobalObjectKey<PaginatedDataTableState>;
    expect(tableKey.value, rowsPerPage);
    // final tableState = tableKey.currentState;
    // tableState?.pageTo(rowIndex);
  });

  testWidgets('AsyncTableWidget second page', (tester) async {
    // Test code goes here
    final k = GlobalKey<AsyncTableWidgetState<MyModel>>();
    AsyncTableSource<MyModel>? dataSrc;
    const rowsPerPage = 6;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AsyncTableWidget<MyModel>(
            key: k,
            requestItems: db.getPage,
            rowsPerPage: rowsPerPage,
            availableRowsPerPage: const [rowsPerPage, rowsPerPage * 2],
            columns: [
              AsyncTableColumnDef(
                cellBuilder: (context, item) => DataCell(Text(item.id)),
                column: const DataColumn(label: Text('Id')),
              ),
              AsyncTableColumnDef(
                cellBuilder: (context, item) => DataCell(Text(item.title)),
                column: const DataColumn(label: Text('Title')),
              ),
            ],
            initState: (value) => dataSrc = value,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final ds = dataSrc;
    final tableKey =
        ds!.getTableKey() as GlobalObjectKey<PaginatedDataTableState>;
    //go to second page
    tableKey.currentState!.pageTo(rowsPerPage * 1);
    await tester.pumpAndSettle();
    final allItems = db.items;
    expect(ds.itemsMap.length, 2);
    expect(ds.itemsMap[0], allItems.skip(0).take(rowsPerPage));
    expect(
      ds.itemsMap[rowsPerPage],
      allItems.skip(rowsPerPage).take(rowsPerPage),
    );
  });

  testWidgets('AsyncTableWidget change rowsPerPage', (tester) async {
    // Test code goes here
    final k = GlobalKey<AsyncTableWidgetState<MyModel>>();
    AsyncTableSource<MyModel>? dataSrc;
    // final rowsPerPageStream = StreamController<int>.broadcast();
    const initialrowsPerPage = 6;
    // rowsPerPageStream.add(initialrowsPerPage);
    late void Function(int? rowsPerPage) _setRowsPerPage;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RowsPerPageWrapper(
              initialRowsPerPage: initialrowsPerPage,
              builder: (context, rowsPerPage, setRowsPerPage) {
                _setRowsPerPage = setRowsPerPage;
                return AsyncTableWidget<MyModel>(
                  key: k,
                  requestItems: db.getPage,
                  rowsPerPage: rowsPerPage,
                  availableRowsPerPage: const [
                    initialrowsPerPage,
                    initialrowsPerPage * 2
                  ],
                  onRowsPerPageChanged: setRowsPerPage,
                  columns: [
                    AsyncTableColumnDef(
                      cellBuilder: (context, item) => DataCell(Text(item.id)),
                      column: const DataColumn(label: Text('Id')),
                    ),
                    AsyncTableColumnDef(
                      cellBuilder: (context, item) =>
                          DataCell(Text(item.title)),
                      column: const DataColumn(label: Text('Title')),
                    ),
                  ],
                  initState: (value) => dataSrc = value,
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final ds = dataSrc!;
    //go to second page
    _setRowsPerPage(initialrowsPerPage * 2);
    // rowsPerPageStream.add(initialrowsPerPage * 2);
    await tester.pumpAndSettle();
    final allItems = db.items;
    expect(ds.itemsMap.length, 1);
    expect(ds.itemsMap[0], allItems.skip(0).take(initialrowsPerPage * 2));
  });
}
