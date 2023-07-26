class ActionsBuilderParams<T> {
  ///Deletes the items from the UI first before sending the request
  final void Function(Set<int> indexes) deleteIndexesFromTable;
  final void Function() refresh;
  final int? totalCount;
  final int selectedCount;
  final List<MapEntry<int, T?>> availableSelected;

  const ActionsBuilderParams({
    required this.deleteIndexesFromTable,
    required this.refresh,
    required this.totalCount,
    required this.selectedCount,
    required this.availableSelected,
  });
}
