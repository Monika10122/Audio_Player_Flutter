import 'package:flutter/material.dart';

class SavedTracksProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _savedTracks = [];

  List<Map<String, dynamic>> get savedTracks => _savedTracks;

  void addTrack(Map<String, dynamic> track) {
    _savedTracks.add(track);
    notifyListeners();
  }

  void removeTrack(int index) {
    if (index >= 0 && index < _savedTracks.length) {
      _savedTracks.removeAt(index);
      notifyListeners();
    }
  }
}
