import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNote extends StatefulWidget {
  const AddNote({super.key});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  late TextEditingController _noteController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _loadSavedNote();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedNote() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String savedNote = preferences.getString('parkingNote') ?? '';
    setState(() {
      _noteController.text = savedNote;
      _isLoading = false;
    });
  }

  Future<void> _saveNote() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('parkingNote', _noteController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Note')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  SizedBox(
                    width: 500,
                    child: TextField(
                      autofocus: true,
                      controller: _noteController,
                      cursorWidth: 2.0,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Parking Note',
                        hintText: 'Add details about your parking spot...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  FilledButton(
                    onPressed: () async {
                      await _saveNote();
                      Navigator.pop(context);
                    },
                    child: Text('Save Note'),
                  ),
                ],
              ),
            ),
    );
  }
}
