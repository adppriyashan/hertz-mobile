class Switch {
  final int id;
  final bool status;
  final String createdAt;
  final String updatedAt;

  Switch({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Switch.fromJson(Map<String, dynamic> json) {
    return Switch(
      id: json['id'] ?? 0,
      status: json['status'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class SwitchResponse {
  final bool success;
  final String message;
  final List<Switch> data;
  final int statusCode;

  SwitchResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory SwitchResponse.fromJson(Map<String, dynamic> json) {
    return SwitchResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => Switch.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      statusCode: json['status_code'] ?? 0,
    );
  }
}

class SwitchUpdateRequest {
  final bool status;

  SwitchUpdateRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {'status': status};
  }
}

class SwitchUpdateResponse {
  final bool success;
  final String message;
  final Switch? data;
  final int statusCode;

  SwitchUpdateResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });

  factory SwitchUpdateResponse.fromJson(Map<String, dynamic> json) {
    return SwitchUpdateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? Switch.fromJson(json['data']) : null,
      statusCode: json['status_code'] ?? 0,
    );
  }
}
