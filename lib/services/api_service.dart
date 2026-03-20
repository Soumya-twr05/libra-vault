// lib/services/api_service.dart

import '../models/book_model.dart';
import '../models/user_model.dart';
import 'firebase_services.dart';

class ApiService {
  final _fb = FirebaseService();

  // ── Auth ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) =>
      _fb.register(name: name, email: email, password: password);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) =>
      _fb.login(email: email, password: password);

  // ✅ NEW: Google Sign-In
  Future<Map<String, dynamic>> signInWithGoogle() =>
      _fb.signInWithGoogle();

  Future<void> logout() => _fb.logout();

  Future<UserModel?> getLoggedInUser() async => _fb.getLoggedInUser();

  // ── Books ─────────────────────────────────────────────────────────────

  Future<List<BookModel>> getBooks() => _fb.getBooks();

  Future<BookModel> addBook({
    required String title,
    required String author,
    required String isbn,
    required int quantity,
  }) =>
      _fb.addBook(title: title, author: author, isbn: isbn, quantity: quantity);

  Future<BookModel> updateBook(BookModel book) => _fb.updateBook(book);

  Future<void> deleteBook(String id) => _fb.deleteBook(id);

  Future<BookModel> issueBook(String bookId, String issuedTo) =>
      _fb.issueBook(bookId, issuedTo);

  Future<BookModel> returnBook(String bookId) => _fb.returnBook(bookId);
}