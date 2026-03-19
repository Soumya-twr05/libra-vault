// lib/screens/home/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../models/book_model.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  List<BookModel> _books = [];
  List<BookModel> _filtered = [];
  UserModel? _user;
  bool _loading = true;
  String _search = '';
  String _filterStatus = 'All';
  late TabController _tabCtrl;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      _filterStatus = ['All', 'Available', 'Issued'][_tabCtrl.index];
      setState(() => _applyFilter());
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final results =
        await Future.wait([_api.getBooks(), _api.getLoggedInUser()]);
    _books = results[0] as List<BookModel>;
    _user = results[1] as UserModel?;
    _applyFilter();
    setState(() => _loading = false);
  }

  void _applyFilter() {
    _filtered = _books.where((b) {
      final matchSearch = _search.isEmpty ||
          b.title.toLowerCase().contains(_search.toLowerCase()) ||
          b.author.toLowerCase().contains(_search.toLowerCase()) ||
          b.isbn.contains(_search);
      final matchStatus = _filterStatus == 'All' ||
          (_filterStatus == 'Available' && b.status == BookStatus.available) ||
          (_filterStatus == 'Issued' && b.status == BookStatus.issued);
      return matchSearch && matchStatus;
    }).toList();
  }

  Future<void> _deleteBook(BookModel book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _api.deleteBook(book.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Book deleted successfully'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  Future<void> _showIssueDialog(BookModel book) async {
    final ctrl = TextEditingController();
    final action = book.status == BookStatus.issued ? 'return' : 'issue';
    if (action == 'return') {
      await _api.returnBook(book.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('"${book.title}" returned successfully'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
      return;
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Issue Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Issue "${book.title}" to:'),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'Student / Member Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              await _api.issueBook(book.id, ctrl.text.trim());
              await _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text('"${book.title}" issued to ${ctrl.text.trim()}'),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ));
              }
            },
            child: const Text('Issue'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await _api.logout();
    if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  int get _totalBooks => _books.length;
  int get _availableBooks =>
      _books.where((b) => b.status == BookStatus.available).length;
  int get _issuedBooks =>
      _books.where((b) => b.status == BookStatus.issued).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primary.withBlue(160)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                            'Hello, ${_user?.name.split(' ').first ?? 'Librarian'} 👋',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text('LibraVault',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 16),
                        // Stats Row
                        Row(
                          children: [
                            _StatChip(
                                label: 'Total',
                                value: _totalBooks,
                                color: Colors.white),
                            const SizedBox(width: 10),
                            _StatChip(
                                label: 'Available',
                                value: _availableBooks,
                                color: const Color(0xFF86EFAC)),
                            const SizedBox(width: 10),
                            _StatChip(
                                label: 'Issued',
                                value: _issuedBooks,
                                color: const Color(0xFFFBBF24)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by title, author or ISBN...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            setState(() {
                              _search = '';
                              _applyFilter();
                            });
                          })
                      : null,
                ),
                onChanged: (v) {
                  _search = v;
                  _searchDebounce?.cancel();
                  _searchDebounce =
                      Timer(const Duration(milliseconds: 500), () {
                    setState(() => _applyFilter());
                  });
                },
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                      ? _EmptyState(
                          onAdd: () async {
                            await Navigator.of(context)
                                .pushNamed(AppRoutes.addBook);
                            _loadData();
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) => _BookCard(
                            book: _filtered[i],
                            onEdit: () async {
                              await Navigator.of(context).pushNamed(
                                  AppRoutes.editBook,
                                  arguments: _filtered[i]);
                              _loadData();
                            },
                            onDelete: () => _deleteBook(_filtered[i]),
                            onIssueReturn: () => _showIssueDialog(_filtered[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).pushNamed(AppRoutes.addBook);
          _loadData();
        },
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Book',
            style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 4,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text('$value',
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onIssueReturn;

  const _BookCard({
    required this.book,
    required this.onEdit,
    required this.onDelete,
    required this.onIssueReturn,
  });

  @override
  Widget build(BuildContext context) {
    final isIssued = book.status == BookStatus.issued;
    final statusColor = isIssued ? AppTheme.issued : AppTheme.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE8E0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.book_rounded,
                      color: AppTheme.primary, size: 28),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 1.3)),
                      const SizedBox(height: 4),
                      Text(book.author,
                          style: TextStyle(
                              color: AppTheme.textMuted, fontSize: 13)),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isIssued ? 'Issued' : 'Available',
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          // Meta info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _MetaTag(
                    icon: Icons.numbers_rounded, label: 'ISBN: ${book.isbn}'),
                _MetaTag(
                    icon: Icons.inventory_2_outlined,
                    label: 'Qty: ${book.quantity}'),
                if (book.addedByName != null)
                  _MetaTag(
                    icon: Icons.person_rounded,
                    label: 'Added by: ${book.addedByName!}',
                  ),
                if (isIssued && book.issuedTo != null)
                  _MetaTag(
                      icon: Icons.person_outline_rounded,
                      label: 'To: ${book.issuedTo!}'),
                if (isIssued && book.issuedAt != null)
                  _MetaTag(
                      icon: Icons.calendar_today_outlined,
                      label: DateFormat('dd MMM yyyy').format(book.issuedAt!)),
              ],
            ),
          ),

          // Divider + actions
          const Divider(height: 1, color: Color(0xFFF0EBE3)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _ActionBtn(
                    icon: Icons.edit_outlined, label: 'Edit', onTap: onEdit),
                _ActionBtn(
                  icon: isIssued ? Icons.undo_rounded : Icons.output_rounded,
                  label: isIssued ? 'Return' : 'Issue',
                  color: isIssued ? AppTheme.success : AppTheme.issued,
                  onTap: onIssueReturn,
                ),
                _ActionBtn(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  color: AppTheme.danger,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon,
      required this.label,
      this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return Expanded(
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: c),
        label: Text(label,
            style:
                TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600)),
        style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.library_books_outlined,
                size: 44, color: AppTheme.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          Text('No Books Found', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Tap the button below to add your first book.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add First Book'),
          ),
        ],
      ),
    );
  }
}
