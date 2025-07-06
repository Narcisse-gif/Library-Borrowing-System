import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';

class BookCatalogScreen extends StatefulWidget {
  const BookCatalogScreen({super.key});

  @override
  State<BookCatalogScreen> createState() => _BookCatalogScreenState();
}

class _BookCatalogScreenState extends State<BookCatalogScreen> {
  List<BookModel> books = [];
  List<BookModel> filteredBooks = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    setState(() => isLoading = true);
    try {
      final data = await BookService.getBooks();
      setState(() {
        books = data.map((e) => BookModel.fromJson(e)).toList();
        filteredBooks = books.where((b) {
          return (b.title ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
              (b.author ?? '').toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showPopup(context, "Error", "Failed to load books:\n$e", isSuccess: false);
    }
  }

  void searchBooks(String query) {
    setState(() {
      searchQuery = query;
      filteredBooks = books.where((b) {
        return (b.title ?? '').toLowerCase().contains(query.toLowerCase()) ||
            (b.author ?? '').toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _showPopup(BuildContext context, String title, String message, {bool isSuccess = true}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: searchBooks,
              decoration: InputDecoration(
                hintText: "Search by title or author...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchBooks,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        Icons.book,
                        color: book.status == "available" ? Colors.green : Colors.orange,
                      ),
                      title: Text(book.title ?? ''),
                      subtitle: Text("by ${book.author ?? 'Unknown'}"),
                      trailing: Text(book.status ?? ''),
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/book-detail',
                          arguments: book.toJson(),
                        );

                        if (result == true) {
                          await fetchBooks(); // Refresh data
                          searchBooks(searchQuery); // Apply current filter again
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
