import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackIssuesScreen extends StatefulWidget {
  const TrackIssuesScreen({super.key});

  @override
  State<TrackIssuesScreen> createState() => _TrackIssuesScreenState();
}

class _TrackIssuesScreenState extends State<TrackIssuesScreen> {
  String _selectedFilter = 'All';

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.redAccent;
      case 'in progress':
        return Colors.amber;
      case 'closed':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Track Reported Issues'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedFilter == 'All',
                    onSelected: (_) => setState(() => _selectedFilter = 'All'),
                    backgroundColor: Colors.grey[800],
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _selectedFilter == 'All' ? Colors.black : Colors.white,
                    ),
                  ),
                  FilterChip(
                    label: const Text('Open'),
                    selected: _selectedFilter == 'open',
                    onSelected: (_) => setState(() => _selectedFilter = 'open'),
                    backgroundColor: Colors.red[300],
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _selectedFilter == 'open' ? Colors.black : Colors.white,
                    ),
                  ),
                  FilterChip(
                    label: const Text('In Progress'),
                    selected: _selectedFilter == 'in progress',
                    onSelected: (_) => setState(() => _selectedFilter = 'in progress'),
                    backgroundColor: Colors.amber[300],
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _selectedFilter == 'in progress' ? Colors.black : Colors.white,
                    ),
                  ),
                  FilterChip(
                    label: const Text('Closed'),
                    selected: _selectedFilter == 'closed',
                    onSelected: (_) => setState(() => _selectedFilter = 'closed'),
                    backgroundColor: Colors.green[300],
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _selectedFilter == 'closed' ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('issues')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  final filteredDocs = _selectedFilter == 'All'
                      ? docs
                      : docs.where((doc) =>
                  (doc.data() as Map<String, dynamic>)['status'].toString().toLowerCase() == _selectedFilter).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(child: Text('No issues match the selected filter.', style: TextStyle(color: Colors.white)));
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final data = filteredDocs[index].data() as Map<String, dynamic>;
                      final title = data['title'] ?? 'Untitled';
                      final category = data['category'] ?? 'Unknown';
                      final location = data['location'] ?? 'Not specified';
                      final status = data['status'] ?? 'open';
                      final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                      final base64Img = data['imageBase64'];

                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(CupertinoIcons.exclamationmark_circle, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(CupertinoIcons.tag, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(category, style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(CupertinoIcons.location, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(location, style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(CupertinoIcons.check_mark, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('Status: ', style: const TextStyle(color: Colors.grey)),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (timestamp != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Row(
                                    children: [
                                      const Icon(CupertinoIcons.time, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Reported: ${timestamp.toLocal().toString().split('.')[0]}',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              if (base64Img != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      base64Decode(base64Img),
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
