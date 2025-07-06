import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/borrowing_model.dart';
import '../../models/reservation_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/borrowing_service.dart';
import '../../services/reservation_service.dart';

class StudentHistoryScreen extends StatefulWidget {
  const StudentHistoryScreen({super.key});

  @override
  State<StudentHistoryScreen> createState() => _StudentHistoryScreenState();
}

class _StudentHistoryScreenState extends State<StudentHistoryScreen> {
  List<BorrowingModel> borrowings = [];
  List<ReservationModel> reservations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    setState(() => isLoading = true);
    try {
      final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
      if (userId == null) {
        setState(() {
          borrowings = [];
          reservations = [];
          isLoading = false;
        });
        return;
      }

      final allBorrowings = await BorrowingService.fetchUserBorrowings(userId);
      final allReservations = await ReservationService.fetchUserReservations(userId);

      // ✅ Filter only returned borrowings and fulfilled/cancelled reservations
      borrowings = allBorrowings.where((b) => b.status == 'returned').toList();
      reservations = allReservations
          .where((r) =>
      r.status.toLowerCase() == 'fulfilled' ||
          r.status.toLowerCase() == 'cancelled')
          .toList();
    } catch (e) {
      _showPopup(
        context,
        "Error",
        "Failed to fetch your history.\nPlease try again.\n\nDetails: $e",
        isSuccess: false,
      );
    }

    setState(() => isLoading = false);
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

  String formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      final parsed = date is DateTime ? date : DateTime.tryParse(date.toString());
      return parsed != null
          ? DateFormat('EEEE, MMM d, yyyy').format(parsed)
          : 'Invalid date';
    } catch (_) {
      return 'Invalid date';
    }
  }

  Widget _buildSection<T>(String title, List<T> items, bool isBorrowing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Text("No records found."),
        ...items.map((item) {
          if (item is BorrowingModel) {
            return Card(
              child: ListTile(
                title: Text(item.book.title),
                subtitle: Text(
                  "Borrowed: ${formatDate(item.borrowDate)} | Returned: ${item.returnDate != null ? formatDate(item.returnDate) : 'Not yet'}",
                ),
              ),
            );
          } else if (item is ReservationModel) {
            return Card(
              child: ListTile(
                title: Text(item.book.title),
                subtitle: Text(
                  "Reserved on: ${formatDate(item.reservedAt)} | Status: ${item.status}",
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("My History"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchHistory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection("📘 Borrowing History", borrowings, true),
              const SizedBox(height: 20),
              _buildSection("📌 Reservation History", reservations, false),
            ],
          ),
        ),
      ),
    );
  }
}
