class VoiceSubmitResponse {
  final bool success;
  final String message;
  final VoiceData? data;
  final int statusCode;
  final Map<String, dynamic>? errors;

  VoiceSubmitResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
    this.errors,
  });

  factory VoiceSubmitResponse.fromJson(Map<String, dynamic> json) {
    return VoiceSubmitResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? VoiceData.fromJson(json['data']) : null,
      statusCode: json['status_code'] ?? json['statusCode'] ?? 0,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
}

class VoiceData {
  final int id;
  final String path;
  final String status;
  final String? result;
  final String? createdAt;
  final String? updatedAt;

  VoiceData({
    required this.id,
    required this.path,
    required this.status,
    this.result,
    this.createdAt,
    this.updatedAt,
  });

  factory VoiceData.fromJson(Map<String, dynamic> json) {
    return VoiceData(
      id: json['id'] ?? 0,
      path: json['path'] ?? '',
      status: json['status'] ?? '',
      result: json['result'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class VoiceRetrieveResponse {
  final bool success;
  final String message;
  final VoiceData? data;
  final int statusCode;

  VoiceRetrieveResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });

  factory VoiceRetrieveResponse.fromJson(Map<String, dynamic> json) {
    return VoiceRetrieveResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? VoiceData.fromJson(json['data']) : null,
      statusCode: json['status_code'] ?? json['statusCode'] ?? 0,
    );
  }
}
