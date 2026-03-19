// lib/models/book_model.dart

enum BookStatus { available, issued }

class BookModel {
  final String id;
  String title;
  String author;
  String isbn;
  int quantity;
  BookStatus status;
  DateTime addedAt;
  String? issuedTo;
  DateTime? issuedAt;

  // ✅ NEW FIELD
  final String? addedByName;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.quantity,
    this.status = BookStatus.available,
    required this.addedAt,
    this.issuedTo,
    this.issuedAt,
    this.addedByName, // ✅ added
  });

  Map<String, dynamic> toJson() => {
        // ❌ don't store id in Firestore (we use doc.id)
        'title': title,
        'author': author,
        'isbn': isbn,
        'quantity': quantity,
        'status': status.name,
        'addedAt': addedAt.toIso8601String(),
        'issuedTo': issuedTo,
        'issuedAt': issuedAt?.toIso8601String(),
        'addedByName': addedByName, // ✅ NEW
      };

  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
        id: json['id'], // injected manually from service
        title: json['title'],
        author: json['author'],
        isbn: json['isbn'],
        quantity: json['quantity'],
        status: BookStatus.values
            .firstWhere((e) => e.name == json['status']),
        addedAt: DateTime.parse(json['addedAt']),
        issuedTo: json['issuedTo'],
        issuedAt:
            json['issuedAt'] != null ? DateTime.parse(json['issuedAt']) : null,
        addedByName: json['addedByName'], // ✅ NEW
      );

  BookModel copyWith({
    String? title,
    String? author,
    String? isbn,
    int? quantity,
    BookStatus? status,
    String? issuedTo,
    DateTime? issuedAt,
    String? addedByName, // ✅ NEW
  }) {
    return BookModel(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      addedAt: addedAt,
      issuedTo: issuedTo ?? this.issuedTo,
      issuedAt: issuedAt ?? this.issuedAt,
      addedByName: addedByName ?? this.addedByName, // ✅
    );
  }
}