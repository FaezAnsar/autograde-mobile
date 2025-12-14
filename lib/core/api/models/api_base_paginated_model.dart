import 'package:autograde_mobile/core/api/models/deserializable.dart';

class ApiBasePaginatedModel<T extends Deserializable>
    implements Deserializable {
  ApiBasePaginatedModel({
    this.currentPage,
    required this.data,
    this.firstPageUrl,
    this.from,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
  });

  factory ApiBasePaginatedModel.fromJson(
    Map<String, dynamic> json, {
    required T Function(dynamic data) dataParser,
  }) {
    return ApiBasePaginatedModel<T>(
      data: (json['data'] as List?)?.map((item) => dataParser(item)).toList() ??
          [],
      currentPage: json['current_page'] as int?,
      firstPageUrl: json['first_page_url'] as String,
      from: json['from'] as int?,
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String?,
      perPage: json['per_page'] as int?,
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] as int?,
    );
  }

  int? currentPage;
  List<T> data;
  String? firstPageUrl;
  int? from;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;

  @override
  String toString() {
    return toJson().toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['current_page'] = currentPage;
    data['data'] = this.data.map((v) => v.toString()).toList();
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    return data;
  }
}
