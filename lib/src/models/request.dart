import 'table_source.dart';

class AsyncTableItemsRequest<T> {
  final int offset;
  final int limit;
  final List<T>? previousOffsetItems;
  final AsyncTableSource<T> dataSource;

  const AsyncTableItemsRequest({
    required this.offset,
    required this.limit,
    required this.previousOffsetItems,
    required this.dataSource,
  });
}
