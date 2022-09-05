// To parse this JSON data, do
//
//     final savePresensiResponseModel = savePresensiResponseModelFromJson(jsonString);

import 'dart:convert';

SavePresensiResponseModel savePresensiResponseModelFromJson(String str) =>
    SavePresensiResponseModel.fromJson(json.decode(str));

String savePresensiResponseModelToJson(SavePresensiResponseModel data) =>
    json.encode(data.toJson());

class SavePresensiResponseModel {
  SavePresensiResponseModel({
    required this.success,
    required this.data,
    required this.message,
  });

  bool success;
  Data data;
  String message;

  factory SavePresensiResponseModel.fromJson(Map<String, dynamic> json) =>
      SavePresensiResponseModel(
        success: json["success"],
        data: Data.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.toJson(),
        "message": message,
      };
}

class Data {
  Data({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.tanggal,
    required this.masuk,
    required this.pulang,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String userId;
  String latitude;
  String longitude;
  DateTime tanggal;
  String masuk;
  dynamic pulang;
  DateTime createdAt;
  DateTime updatedAt;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        userId: json["user_id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        tanggal: DateTime.parse(json["tanggal"]),
        masuk: json["masuk"],
        pulang: json["pulang"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "latitude": latitude,
        "longitude": longitude,
        "tanggal":
            "${tanggal.year.toString().padLeft(4, '0')}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}",
        "masuk": masuk,
        "pulang": pulang,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
