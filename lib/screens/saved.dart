// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/app_theme.dart';
import '../logic/saved_tracks_provider.dart';
import '../widgets/player_widget.dart';

class SavedTracksScreen extends StatefulWidget {
  final String accessToken;

  const SavedTracksScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  State<SavedTracksScreen> createState() => _SavedTracksScreenState();
}

class _SavedTracksScreenState extends State<SavedTracksScreen> {
  List<Map<String, dynamic>> savedTracks = [];
  String? selectedSongUri;


  Future<void> playSelectedSong() async {
    try {
      final response = await http.put(
        Uri.parse('https://api.spotify.com/v1/me/player/play'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uris': [selectedSongUri],
        }),
      );
      if (response.statusCode == 204) {
      } else {
        print('Error playing song - Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error playing song: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppThemeProvider, SavedTracksProvider>(
      builder: (context, appThemeProvider, savedTracksProvider, _) {
        return Scaffold(
          backgroundColor: appThemeProvider.themeData.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: appThemeProvider.themeData.colorScheme.background,
            title: Center(child: Text(
              'Saved Tracks',
              style: appThemeProvider.themeData.textTheme.titleMedium!.copyWith(
                color: appThemeProvider.themeData.textTheme.titleMedium!.color,
              ),
            ),
          ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: appThemeProvider.themeData.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        itemCount: savedTracksProvider.savedTracks.length,
                        itemBuilder: (context, index) {
                          final savedTrack = savedTracksProvider.savedTracks[index];
                          return _buildSavedTrackCard(savedTrack, index, appThemeProvider, savedTracksProvider);
                        },
                      ),
                    ),
                  ),
                  MiniAudioPlayer(
                    onPlayerReady: () {},
                    accessToken: widget.accessToken,
                    selectedSongUri: selectedSongUri ?? '',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedTrackCard(
    Map<String, dynamic> savedTrack, int index, AppThemeProvider appThemeProvider, SavedTracksProvider savedTracksProvider) {
    final trackName = savedTrack['name'];
    final artistName = savedTrack['artist'];
    final imageUrl = savedTrack['imageUrl'];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        textColor: appThemeProvider.themeData.listTileTheme.textColor,
        tileColor: appThemeProvider.themeData.listTileTheme.tileColor,
        iconColor: appThemeProvider.themeData.listTileTheme.iconColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.all(8.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          trackName,
          style: TextStyle(
            color: appThemeProvider.themeData.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
          ),
        ),
        subtitle: Text(
          artistName,
          style: TextStyle(
            color: appThemeProvider.themeData.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.play_arrow,
                size: 28,
                color: appThemeProvider.themeData.colorScheme.onPrimary,
              ),
              onPressed: () {
                setState(() {
                  selectedSongUri = savedTrack['uri']; 
                });
                playSelectedSong();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                size: 28,
                color: appThemeProvider.themeData.colorScheme.onPrimary,
              ),
              onPressed: () {
                savedTracksProvider.removeTrack(index);
              },
            ),
          ],
        ),
      ),
    );
  }
}

