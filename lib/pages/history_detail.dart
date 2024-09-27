// history_page.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    _historyFuture = _loadHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Detection History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text("No history found"));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Dismissible(
                      key: Key(item['imageHash'] ?? 'unknown_hash'),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _deleteHistoryItem(item['imageHash'] ?? '');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.white),
                        child: ListTile(
                          leading: File(item['image'] ?? '').existsSync()
                              ? Image.file(File(item['image']),
                                  width: 50, height: 50, fit: BoxFit.cover)
                              : const Icon(Icons.image_not_supported, size: 50),
                          title: Text(item['disease'] ?? 'Unknown disease'),
                          subtitle: Text(_formatDate(item['timestamp'] ??
                              DateTime.now().toIso8601String())),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HistoryDetailsPage(historyItem: item),
                              ),
                            );
                          },
                          onLongPress: () {
                            _showDeleteDialog(item['imageHash'] ?? '');
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('detection_history') ?? [];
    final decodedHistory = history
        .map((item) => json.decode(item) as Map<String, dynamic>)
        .toList();
    decodedHistory.sort((a, b) => DateTime.parse(b['timestamp'])
        .compareTo(DateTime.parse(a['timestamp'])));
    return decodedHistory;
  }

  void _showDeleteDialog(String imageHash) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete History Item'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteHistoryItem(imageHash);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteHistoryItem(String imageHash) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('detection_history') ?? [];

    history.removeWhere((item) {
      final decoded = json.decode(item);
      return decoded['imageHash'] == imageHash;
    });

    await prefs.setStringList('detection_history', history);

    // Update the UI
    setState(() {
      _historyFuture = _loadHistory();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('History item deleted')),
    );
  }

  String _formatDate(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('MMM d, y HH:mm').format(dateTime);
  }
}

class HistoryDetailsPage extends StatelessWidget {
  final Map<String, dynamic> historyItem;

  const HistoryDetailsPage({Key? key, required this.historyItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.file(
                  File(historyItem['image']),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Disease: ${historyItem['disease']}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Detected on: ${_formatDate(historyItem['timestamp'])}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(historyItem['description']),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('MMMM d, y HH:mm').format(dateTime);
  }
}
