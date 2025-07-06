import 'package:library_borrowing_system/models/user_model.dart';
import 'book_model.dart';

class ReservationModel {
  final String id;
  final BookModel book;
  final UserModel user;
  final DateTime reservedAt;
  final String status;

  ReservationModel({
    required this.id,
    required this.book,
    required this.user,
    required this.reservedAt,
    required this.status,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['_id'] ?? json['id'] ?? '',
      book: BookModel.fromJson(json['book']),
      user: UserModel.fromJson(json['user']),
      reservedAt: DateTime.parse(json['reservationDate']),
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'book': book.toJson(),
      'user': user.toJson(),
      'reservationDate': reservedAt.toIso8601String(),
      'status': status,
    };
  }
}
