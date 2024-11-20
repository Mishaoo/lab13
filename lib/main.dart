import 'package:flutter/material.dart';
import 'db.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LIFO Notes App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _dbHelper.getNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _addNoteToDatabase(String text) async {
    await _dbHelper.addNote(text);
    _loadNotes();
  }

  void _addNote() {
    if (_formKey.currentState!.validate()) {
      _addNoteToDatabase(_noteController.text);
      _noteController.clear();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _dbHelper.closeDatabase();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LIFO Notes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Введіть нотатку',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Нотатка не може бути порожньою';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addNote,
                    child: Text('Додати'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _notes.isEmpty
                  ? Center(
                child: Text(
                  'Нотаток ще немає',
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Card(
                    child: ListTile(
                      title: Text(note['text']),
                      subtitle: Text('Дата створення: ${note['date']}'),
                    ),
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
