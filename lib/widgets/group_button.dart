import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class LocationSavedActionButtons extends StatefulWidget {
  const LocationSavedActionButtons({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  State<LocationSavedActionButtons> createState() =>
      _LocationSavedActionButtonsState();
}

class _LocationSavedActionButtonsState
    extends State<LocationSavedActionButtons> {
  String _noteButtonText = 'Add Note';
  String _photoButtonText = 'Add Photo';
  bool _isLoading = true;
  bool _isLocationSaved = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkExistingNote();
    _checkLocationStatus();
    _checkExistingPhoto();
  }

  Future<void> _checkExistingNote() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? savedNote = preferences.getString('parkingNote');
    setState(() {
      _noteButtonText = (savedNote != null && savedNote.isNotEmpty)
          ? 'Edit Note'
          : 'Add Note';
      _isLoading = false;
    });
  }

  Future<void> _checkLocationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLocationSaved = prefs.getBool('isLocationSaved') ?? false;
    });
  }

  Future<void> _checkExistingPhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? photoPath = prefs.getString('parkingPhotoPath');
    if (photoPath != null && await File(photoPath).exists()) {
      setState(() {
        _photoButtonText = 'View Photo';
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName =
            'parking_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String localPath = path.join(appDir.path, fileName);

        await File(photo.path).copy(localPath);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('parkingPhotoPath', localPath);

        setState(() {
          _photoButtonText = 'View Photo';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo saved successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
      }
    }
  }

  Future<void> _handlePhotoButton() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? photoPath = prefs.getString('parkingPhotoPath');

    if (photoPath != null && await File(photoPath).exists()) {
      // Photo exists, show it
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(File(photoPath)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Delete photo and retake
                        await File(photoPath).delete();
                        await prefs.remove('parkingPhotoPath');
                        setState(() {
                          _photoButtonText = 'Add Photo';
                        });
                        if (mounted) {
                          Navigator.pop(context);
                          _takePhoto();
                        }
                      },
                      child: const Text('Retake'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    } else {
      // No photo exists, take one
      await _takePhoto();
    }
  }

  Future<void> _deleteSavedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Delete photo file if it exists
    String? photoPath = prefs.getString('parkingPhotoPath');
    if (photoPath != null) {
      try {
        final file = File(photoPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore file deletion errors
      }
    }

    await prefs.remove('latitude');
    await prefs.remove('longitude');
    await prefs.setBool('isLocationSaved', false); // Set to false, not remove
    await prefs.remove('saved_timestamp');
    await prefs.remove('parkingNote'); // Also clear parking note
    await prefs.remove('parkingPhotoPath'); // Also clear parking photo
    setState(() {
      _isLocationSaved = false;
      _noteButtonText = 'Add Note'; // Reset note button text
      _photoButtonText = 'Add Photo'; // Reset photo button text
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FilledButton(
          onPressed: _handlePhotoButton,
          child: Text(_photoButtonText),
        ),
        FilledButton(
          onPressed: _isLoading
              ? null
              : () async {
                  await Navigator.pushNamed(context, '/add_note');
                  // Refresh button text after returning from add note page
                  _checkExistingNote();
                },
          child: Text(_noteButtonText),
        ),
        FilledButton(
          onPressed: () async {
            await _deleteSavedLocation();
            Navigator.pop(context, true); // Return true to indicate change
          },
          child: Text('Delete Location'),
        ),
      ],
    );
  }
}