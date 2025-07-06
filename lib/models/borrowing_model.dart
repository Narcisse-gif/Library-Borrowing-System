import 'package:library_borrowing_system/models/user_model.dart';
import 'book_model.dart';

class BorrowingModel {
  final String id;
  final BookModel book;
  final UserModel user;
  final DateTime borrowDate;
  final DateTime? returnDate;
  final DateTime dueDate;
  final String status;

  BorrowingModel({
    required this.id,
    required this.book,
    required this.user,
    required this.borrowDate,
    this.returnDate,
    required this.dueDate,
    required this.status,
  });

  factory BorrowingModel.fromJson(Map<String, dynamic> json) {
    return BorrowingModel(
      id: json['_id'] ?? json['id'] ?? '',
      book: BookModel.fromJson(json['book']),
      user: UserModel.fromJson(json['user']),
      borrowDate: DateTime.parse(json['borrowDate']),
      returnDate: json['returnDate'] != null
          ? DateTime.tryParse(json['returnDate'])
          : null,
      dueDate: DateTime.parse(json['dueDate']),
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'book': book.toJson(),
      'user': user.toJson(),
      'borrowDate': borrowDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'status': status,
    };
  }
}
