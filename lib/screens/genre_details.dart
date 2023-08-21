// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../logic/app_theme.dart';
import '../logic/saved_tracks_provider.dart';
import '../widgets/player_widget.dart';

class GenreDetailsScreen extends StatefulWidget {
  final String accessToken;
  final String genreName;

  const GenreDetailsScreen({
    required this.accessToken,
    required this.genreName,
    Key? key,
  }) : super(key: key);

  @override
  State<GenreDetailsScreen> createState() => _GenreDetailsScreenState();
}

class _GenreDetailsScreenState extends State<GenreDetailsScreen> {
  dynamic playlistData; 
  List<dynamic>? playlistTracks; 
  String? selectedSongUri;

  Future<void> _fetchGenreDetails() async {
    final url = Uri.https(
      'api.spotify.com',
      '/v1/recommendations',
      {'seed_genres': widget.genreName}, 
    );
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.accessToken}',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        playlistData = {
          'name': 'Recommended ${widget.genreName} Tracks',
          'images': [
            {
              'url':
                  'https://www.freeiconspng.com/uploads/music-icon-8.png', 
            }
          ],
          'description': 'Recommended tracks in the ${widget.genreName} genre',
        };
        playlistTracks = data['tracks'];
      });
    } else {
      print('Failed to fetch genre details');
    }
  }


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
  void initState() {
    super.initState();
    _fetchGenreDetails();
  }

  @override
  Widget build(BuildContext context) {
   return Consumer2<AppThemeProvider, SavedTracksProvider>(
      builder: (context, appThemeProvider, savedTracksProvider, _) {
      return Scaffold(
        backgroundColor: appThemeProvider.themeData.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: appThemeProvider.themeData.colorScheme.background,
          title: Text(
            playlistData != null ? playlistData['name'] : 'Genre Details',
            style: appThemeProvider.themeData.textTheme.titleMedium!.copyWith(
              color: appThemeProvider.themeData.textTheme.titleMedium!.color,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (playlistData != null)
                  Container(
                     color: appThemeProvider.themeData.scaffoldBackgroundColor,
                     alignment: Alignment.topCenter,
                     height: 250,
                     width: 550,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16.0),
                          Text(
                            'Description: ${playlistData['description'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: appThemeProvider
                                  .themeData.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Divider(),
                if (playlistTracks != null)
                  Expanded(
                    child: ListView.builder(
                      itemCount: playlistTracks!.length,
                      itemBuilder: (context, index) {
                        final track = playlistTracks![index];
                        final trackName = track['name'];
                        final artistName = track['artists'][0]['name'];
                        final imageUrl = track['album']['images'][0]['url'];
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListTile(
                            textColor: appThemeProvider
                                .themeData.listTileTheme.textColor,
                            tileColor: appThemeProvider
                                .themeData.listTileTheme.tileColor,
                            iconColor: appThemeProvider
                                .themeData.listTileTheme.iconColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(trackName),
                            subtitle: Text(artistName),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.play_arrow,
                                    size: 28,
                                    color: appThemeProvider
                                        .themeData.colorScheme.onPrimary,
                                  ),
                                  onPressed: () {
                                     setState(() {
                                        selectedSongUri = track['uri']; 
                                      });
                                      playSelectedSong(); 
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    size: 28,
                                    color: appThemeProvider
                                        .themeData.colorScheme.onPrimary,
                                  ),
                                  onPressed: () {
                                    savedTracksProvider.addTrack({
                                        'name': trackName,
                                        'artist': artistName,
                                        'imageUrl': imageUrl,
                                      });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                MiniAudioPlayer(  onPlayerReady: () {},
                    accessToken: widget.accessToken,
                    selectedSongUri: selectedSongUri ?? '',),
              ],
            ),
          ),
        ),
      );
    });
  }
}

