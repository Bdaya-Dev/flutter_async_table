class AsyncTableItemsResponse<T> {
  final int totalCount;
  final bool isEstimated;
  final List<T> items;

  const AsyncTableItemsResponse({
    required this.totalCount,
    required this.isEstimated,
    required this.items,
  });
}
