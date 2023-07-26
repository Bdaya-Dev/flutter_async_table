<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

A convenience package over `PaginatedDataTable` optimized for fetching items asynchronously. 

## Features

- `AsyncTableWidget<T>` that wraps a `PaginatedDataTable`
- `AsyncTableSource<T>` that extends a `DataTableSource`

## Getting started

- Add the package as a dependency in `pubspec.yaml`
```
dart pub add async_table
```

## Usage

```dart
//An optional wrapper to handle rowsPerPage
RowsPerPageWrapper(
    initialRowsPerPage: initialrowsPerPage,
    builder: (context, rowsPerPage, setRowsPerPage) {
        return AsyncTableWidget<T>(
            requestItems: (offset, rowsPerPage) async {
                //send a request to the server here
            },
            //pass rowsPerPage, availableRowsPerPage, onRowsPerPageChanged    
            rowsPerPage: rowsPerPage,
            onRowsPerPageChanged: setRowsPerPage,
            //define the columns, and how each column builds the cell
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
            //store the AsyncTableSource<T> after its creation.
            initState: (value) => dataSrc = value,
        );
    }
);
```