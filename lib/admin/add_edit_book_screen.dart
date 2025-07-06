import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';

class AddEditBookScreen extends StatefulWidget {
  final BookModel? book;

  const AddEditBookScreen({super.key, this.book});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _isbnController;
  late TextEditingController _descriptionController;

  String? _selectedGenre;
  final List<String> _genres = [
    'Fiction',
    'Realism',
    'Science',
    'History',
    "Programming",
    "Romantic",
    'Biography',
    'Children'
  ];

  File? _coverImage;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _isbnController = TextEditingController(text: book?.isbn ?? '');
    _descriptionController = TextEditingController(text: book?.description ?? '');
    _selectedGenre = book?.genre;
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _coverImage = File(result.files.single.path!));
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSaving = true);

      String? base64Image;
      if (_coverImage != null) {
        final bytes = await _coverImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final newBook = BookModel(
        id: widget.book?.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        genre: _selectedGenre,
        isbn: _isbnController.text.trim(),
        description: _descriptionController.text.trim(),
        status: 'available', // Always set to "available"
      );

      final data = newBook.toJson();
      if (base64Image != null) {
        data['coverImage'] = base64Image;
      }

      try {
        final success = widget.book == null
            ? await BookService.addBook(data)
            : await BookService.updateBook(newBook.id!, data);

        if (success) {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('✅ Success'),
              content: Text(widget.book != null
                  ? 'Book updated successfully!'
                  : 'Book added successfully!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save book')),
          );
        }
      } catch (e, stack) {
        print('❌ Exception while saving book: $e');
        print(stack);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => isSaving = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book != null ? '✏️ Edit Book' : '➕ Add Book'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                        image: _coverImage != null
                            ? DecorationImage(
                            image: FileImage(_coverImage!),
                            fit: BoxFit.cover)
                            : null,
                      ),
                      child: _coverImage == null
                          ? const Center(child: Text("Tap to upload cover image"))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration('Title'),
                    validator: (val) =>
                    val == null || val.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _authorController,
                    decoration: _inputDecoration('Author'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGenre,
                    decoration: _inputDecoration('Genre'),
                    items: _genres
                        .map((genre) =>
                        DropdownMenuItem(value: genre, child: Text(genre)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedGenre = val),
                    validator: (val) =>
                    val == null || val.isEmpty ? 'Select a genre' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _isbnController,
                    decoration: _inputDecoration('ISBN'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _inputDecoration('Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : _save,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        widget.book != null ? 'Update Book' : 'Save Book',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
