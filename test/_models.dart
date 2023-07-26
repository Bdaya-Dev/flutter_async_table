import 'package:flutter/foundation.dart';

import 'package:async_table/src/models/response.dart';

import '_helpers.dart';

class MyModel {
  final String id;
  final String title;
  factory MyModel.rand() {
    return MyModel(
      id: getRandString(20),
      title: getRandString(100),
    );
  }
  const MyModel({
    required this.id,
    required this.title,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MyModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class MyFakeDatabase {
  static const idLen = 20;
  static const titleLen = 100;

  final items = List.generate(100, (index) => MyModel.rand());

  Future<AsyncTableItemsResponse<MyModel>> getPage(
    int offset,
    int limit,
  ) {
    return SynchronousFuture(
      AsyncTableItemsResponse(
        items: items.skip(offset).take(limit).toList(),
        isEstimated: false,
        totalCount: items.length,
      ),
    );
  }

  Future<AsyncTableItemsResponse<MyModel>> getPageEstimated(
    int offset,
    int limit,
  ) async {
    return AsyncTableItemsResponse(
      items: items.skip(offset).take(limit).toList(),
      isEstimated: true,
      totalCount: items.length,
    );
  }
}
