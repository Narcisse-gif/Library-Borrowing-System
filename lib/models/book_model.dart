class BookModel {
  final String? id; // made nullable to support adding
  final String title;
  final String? author;
  final String? genre;
  final String? isbn;
  final String? description;
  final bool available;
  final String? status;

  BookModel({
    this.id,
    required this.title,
    this.author,
    this.genre,
    this.isbn,
    this.description,
    this.available = true,
    this.status,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      author: json['author'],
      genre: json['genre'],
      isbn: json['isbn'],
      description: json['description'],
      available: json['available'] ?? true,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      'author': author,
      'genre': genre,
      'isbn': isbn,
      'description': description,
      'available': available,
      if (status != null) 'status': status,
    };
  }

  bool get isAvailable => status == 'available';
}
