// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:audioplayer1/widgets/player_widget.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/app_theme.dart';
import '../logic/saved_tracks_provider.dart';

class SongDetailsPage extends StatelessWidget {
  final String songName;
  final String imageUrl;
  final String accessToken;
  final String selectedSongUri; 

  const SongDetailsPage({
    Key? key,
    required this.songName,
    required this.imageUrl,
    required this.accessToken,
    required this.selectedSongUri, 
  }) : super(key: key);

  Future<void> playSelectedSong() async {
    try {
      final response = await http.put(
        Uri.parse('https://api.spotify.com/v1/me/player/play'),
        headers: {
          'Authorization': 'Bearer $accessToken', 
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
          title: Text('Song Details',
          style: appThemeProvider.themeData.textTheme.titleMedium!.copyWith(
              color: appThemeProvider.themeData.textTheme.titleMedium!.color,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.network(
                  imageUrl,
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 16),
                Text(
                  'Song Name: $songName',
                  style: TextStyle(fontSize: 18,
                  color: appThemeProvider.themeData.colorScheme.onPrimary,
                  ),),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: appThemeProvider.themeData.elevatedButtonTheme.style,
                  onPressed: () {
                    playSelectedSong(); 
                  },
                  child: Text('Play Song',
                  style: appThemeProvider.themeData.textTheme.titleMedium!.copyWith(
                color: appThemeProvider.themeData.textTheme.titleMedium!.color,
              ),),
                ),
                const SizedBox(height: 20, width: 20),
                MiniAudioPlayer(
                    onPlayerReady: () {},
                    accessToken: accessToken,
                    selectedSongUri: selectedSongUri),
              ],
            ),
          ),
        ),
      );
    });
  }
}
