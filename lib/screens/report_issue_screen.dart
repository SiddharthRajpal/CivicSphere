import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedCategory;
  File? _selectedImage;
  String? _base64Image;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Sanitation Issue',
    'Road Damage',
    'Water Leakage',
    'Electrical Issue',
    'Safety Issue',
    'Other Issue',
  ];

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 30);
    if (picked != null) {
      final imageFile = File(picked.path);
      final bytes = await imageFile.readAsBytes();
      setState(() {
        _selectedImage = imageFile;
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _submitIssue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('issues').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'location': _locationController.text.trim(),
        'status': 'open',
        'reportedBy': FirebaseAuth.instance.currentUser?.email,
        'imageBase64': _base64Image,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Issue reported successfully!')),
      );

      _formKey.currentState!.reset();
      setState(() {
        _selectedCategory = null;
        _selectedImage = null;
        _base64Image = null;
        _isSubmitting = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Report an Issue'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Issue Title',
                    prefixIcon: Icon(CupertinoIcons.pencil, color: Colors.white),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(CupertinoIcons.text_alignleft, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: Colors.black,
                  iconEnabledColor: Colors.white,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(CupertinoIcons.tag, color: Colors.white),
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  validator: (val) => val == null ? 'Select a category' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(CupertinoIcons.location, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(CupertinoIcons.photo, color: Colors.white),
                        label: const Text('From Gallery', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(CupertinoIcons.camera, color: Colors.white),
                        label: const Text('From Camera', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Image.file(_selectedImage!, height: 150),
                  ),
                const SizedBox(height: 24),
                _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submitIssue,
                  icon: const Icon(CupertinoIcons.paperplane),
                  label: const Text('Submit Report'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
