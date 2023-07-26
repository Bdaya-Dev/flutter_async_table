# Flutter Async Table
![Pub Version](https://img.shields.io/pub/v/async_table)
![GitHub last commit on main](https://img.shields.io/github/last-commit/Bdaya-Dev/flutter_async_table/main)
![Build GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/Bdaya-Dev/flutter_async_table/dart.yml)
![Publish GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/Bdaya-Dev/flutter_async_table/publish.yml?label=publish)


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