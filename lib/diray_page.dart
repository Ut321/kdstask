import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({Key? key}) : super(key: key);

  @override
  DiaryPageState createState() => DiaryPageState();
}

class DiaryPageState extends State<DiaryPage> {
  final _thoughtController = TextEditingController();

  void _saveThought() async {
    final thought = _thoughtController.text;
    final currentDate = DateTime.now();

    await FirebaseFirestore.instance.collection('thoughts').add({
      'content': thought,
      'date': currentDate,
    });

    _thoughtController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Diary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _thoughtController,
              decoration: InputDecoration(
                labelText: 'What\'s on your mind?',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveThought,
              child: Text('Save Thought'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Previous Thoughts:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('thoughts')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No thoughts saved yet.'));
                  }
                  final thoughtDocs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: thoughtDocs.length,
                    itemBuilder: (context, index) {
                      final thoughtData =
                          thoughtDocs[index].data() as Map<String, dynamic>;
                      final thoughtContent = thoughtData['content'];
                      final thoughtDate = thoughtData['date'].toDate();
                      return ListTile(
                        title: Text(thoughtContent),
                        subtitle: Text(
                            'Saved on: ${DateFormat.yMMMd().format(thoughtDate)}'),
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
