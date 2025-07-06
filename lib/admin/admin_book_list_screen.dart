// ... imports stay the same
import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';
import 'add_edit_book_screen.dart';

class AdminBookListScreen extends StatefulWidget {
  const AdminBookListScreen({super.key});

  @override
  State<AdminBookListScreen> createState() => _AdminBookListScreenState();
}

class _AdminBookListScreenState extends State<AdminBookListScreen> {
  List<BookModel> books = [];
  bool isLoading = true;
  String searchQuery = "";
  String selectedGenre = "All";
  String selectedStatus = "All";

  final List<String> genres = ['All', 'Fiction', 'Science', 'History', 'Technology'];
  final List<String> statuses = ['All', 'available', 'borrowed', 'reserved'];

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    setState(() => isLoading = true);
    try {
      final result = await BookService.getBooks();
      books = result.map<BookModel>((e) => BookModel.fromJson(e)).toList();
    } catch (e) {
      _showPopup("Error", "Failed to load books: $e", isSuccess: false);
    }
    setState(() => isLoading = false);
  }

  void _showPopup(String title, String message, {bool isSuccess = true}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  List<BookModel> get filteredBooks {
    return books.where((b) {
      final matchesSearch = b.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (b.author?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
      final matchesGenre = selectedGenre == 'All' || b.genre == selectedGenre;
      final matchesStatus = selectedStatus == 'All' || b.status == selectedStatus;
      return matchesSearch && matchesGenre && matchesStatus;
    }).toList();
  }

  void _goToAddBook() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditBookScreen()),
    ).then((updated) {
      if (updated == true) fetchBooks();
    });
  }

  void _goToEditBook(BookModel book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Book"),
        content: const Text("Do you want to edit this book?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes")),
        ],
      ),
    );

    if (confirm == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddEditBookScreen(book: book)),
      ).then((updated) {
        if (updated == true) fetchBooks();
      });
    }
  }

  void _deleteBook(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Book"),
        content: const Text("Are you sure you want to delete this book?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      final success = await BookService.deleteBook(id);
      if (success) {
        fetchBooks();
        _showPopup("Success", "Book deleted successfully ✅", isSuccess: true);
      } else {
        _showPopup("Failed", "Failed to delete book ❌", isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Books"),
        backgroundColor: Colors.blueGrey.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchBooks,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            color: Colors.blueGrey.shade400,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by title or author...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.blueGrey.shade600,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedGenre,
                    items: genres
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedGenre = val!),
                    decoration: const InputDecoration(labelText: "Genre"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: statuses
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedStatus = val!),
                    decoration: const InputDecoration(labelText: "Status"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchBooks,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  return ListTile(
                    leading: Icon(
                      book.isAvailable ? Icons.book : Icons.bookmark_remove,
                      color: book.isAvailable ? Colors.green : Colors.red,
                    ),
                    title: Text(book.title),
                    subtitle: Text("Author: ${book.author ?? 'Unknown'}"),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _goToEditBook(book);
                        } else if (value == 'delete') {
                          _deleteBook(book.id!);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddBook,
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
