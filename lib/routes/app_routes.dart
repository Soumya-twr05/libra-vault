// lib/routes/app_routes.dart

import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/books/add_book_screen.dart';
import '../screens/books/edit_book_screen.dart';
import '../models/book_model.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addBook = '/add-book';
  static const String editBook = '/edit-book';

  /// All routes go through [onGenerateRoute] — keeps one source of truth
  /// and avoids the conflict between `routes` map and `onGenerateRoute`.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case addBook:
        return MaterialPageRoute(builder: (_) => const AddBookScreen());
      case editBook:
        final book = settings.arguments as BookModel;
        return MaterialPageRoute(builder: (_) => EditBookScreen(book: book));
      default:
        // Fallback: redirect unknown routes to login
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}