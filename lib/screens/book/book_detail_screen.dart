import 'package:flutter/material.dart';
import '../../services/book_service.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool isLoading = false;

  void _showPopup(BuildContext context, String title, String message, {bool isSuccess = true, bool autoPop = false}) {
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
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              if (isSuccess && autoPop) {
                Navigator.pop(context, true); // return to book list
              }
            },
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleAction() async {
    setState(() {
      isLoading = true;
    });

    final status = widget.book['status'];
    final bookId = widget.book['_id'];
    bool success = false;
    String message = '';
    String title = '';

    try {
      if (status == 'available') {
        success = await BookService.borrowBook(bookId);
        title = success ? 'Success' : 'Borrowing Failed';
        message = success ? '✅ Book borrowed successfully' : '❌ Borrowing failed';
      } else {
        final response = await BookService.reserveBookWithMessage(bookId);
        success = response['success'];
        title = success ? 'Reservation Confirmed' : 'Reservation Failed';
        message = success ? '📌 Reservation placed successfully' : '❌ ${response['message']}';
      }
    } catch (e) {
      title = 'Error';
      message = '❌ Unexpected error: $e';
    }

    setState(() => isLoading = false);

    _showPopup(context, title, message, isSuccess: success, autoPop: success);
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Book Details'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['title'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'by ${book['author']}',
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.black54),
                ),
                const Divider(height: 30, thickness: 1.2),
                _buildDetailRow('Genre:', book['genre']),
                _buildDetailRow('ISBN:', book['isbn']),
                _buildDetailRow('Status:', book['status'].toString().toUpperCase()),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  book['description'] ?? 'No description available.',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _handleAction,
                    icon: const Icon(Icons.book_outlined, color: Colors.white),
                    label: Text(
                      book['status'] == 'available' ? 'Borrow Book' : 'Reserve Book',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}
