import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import '../models/user_model.dart';

class FirebaseService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // ✅ GLOBAL books collection
  CollectionReference<Map<String, dynamic>> get _books {
    return _db.collection('books');
  }

  // ── AUTH ─────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save name in Firebase Auth
      await cred.user!.updateDisplayName(name);

      // Save user in Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {'success': true};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _friendlyError(e.code)};
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'success': true};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _friendlyError(e.code)};
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }

  Future<void> logout() => _auth.signOut();

  UserModel? getLoggedInUser() {
    final u = _auth.currentUser;
    if (u == null) return null;

    return UserModel(
      id: u.uid,
      name: u.displayName ?? 'Librarian',
      email: u.email ?? '',
      passwordHash: '',
      createdAt: u.metadata.creationTime ?? DateTime.now(),
    );
  }

  // ── BOOKS ─────────────────────────────────────────────

  Future<List<BookModel>> getBooks() async {
    final snap = await _books
        .orderBy('addedAt', descending: true)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return BookModel.fromJson({
        ...data,
        'id': doc.id, // ✅ inject ID
      });
    }).toList();
  }

  Future<BookModel> addBook({
    required String title,
    required String author,
    required String isbn,
    required int quantity,
  }) async {
    final ref = _books.doc();
    final user = _auth.currentUser;

    final book = BookModel(
      id: ref.id,
      title: title,
      author: author,
      isbn: isbn,
      quantity: quantity,
      addedAt: DateTime.now(),
      addedByName: user?.displayName ?? 'User', // ✅ important
    );

    await ref.set({
      ...book.toJson(),
      'addedBy': user?.uid, // optional tracking
      'addedByName': user?.displayName ?? 'User', // ✅ store name
    });

    return book;
  }

  Future<BookModel> updateBook(BookModel book) async {
    await _books.doc(book.id).update(book.toJson());
    return book;
  }

  Future<void> deleteBook(String id) async {
    await _books.doc(id).delete();
  }

  Future<BookModel> issueBook(String bookId, String issuedTo) async {
    await _books.doc(bookId).update({
      'status': BookStatus.issued.name,
      'issuedTo': issuedTo,
      'issuedAt': DateTime.now().toIso8601String(),
    });

    final snap = await _books.doc(bookId).get();

    return BookModel.fromJson({
      ...snap.data()!,
      'id': snap.id,
    });
  }

  Future<BookModel> returnBook(String bookId) async {
    await _books.doc(bookId).update({
      'status': BookStatus.available.name,
      'issuedTo': null,
      'issuedAt': null,
    });

    final snap = await _books.doc(bookId).get();

    return BookModel.fromJson({
      ...snap.data()!,
      'id': snap.id,
    });
  }

  // ── ERROR HANDLING ────────────────────────────────────

  String _friendlyError(String code) => switch (code) {
        'email-already-in-use' => 'This email is already registered.',
        'user-not-found' => 'No account found with this email.',
        'wrong-password' => 'Incorrect password.',
        'invalid-credential' => 'Invalid email or password.',
        'weak-password' => 'Password must be at least 6 characters.',
        'invalid-email' => 'Enter a valid email address.',
        'too-many-requests' => 'Too many attempts. Try again later.',
        'network-request-failed' => 'Check your internet connection.',
        _ => 'Something went wrong. Please try again.',
      };
}