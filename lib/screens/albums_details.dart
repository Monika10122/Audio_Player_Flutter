// ignore_for_file: library_private_types_in_public_api, avoid_print
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../logic/app_theme.dart';
import '../logic/saved_tracks_provider.dart';
import '../widgets/player_widget.dart';

class AlbumDetailsScreen extends StatefulWidget {
  final String accessToken;
  final String albumId;

  const AlbumDetailsScreen({
    Key? key,
    required this.accessToken,
    required this.albumId,
  }) : super(key: key);

  @override
  _AlbumDetailsScreenState createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  dynamic albumData; 
  List<dynamic>? albumTracks; 
  String? selectedSongUri;

  @override
  void initState() {
    super.initState();
    _fetchAlbumDetails();
    _fetchAlbumTracks();
  }

  Future<void> _fetchAlbumDetails() async {
    final url = Uri.https(
      'api.spotify.com',
      '/v1/albums/${widget.albumId}',
    );
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.accessToken}',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        albumData = data;
      });
    } else {
      print('Failed to fetch album details');
    }
  }


  Future<void> _fetchAlbumTracks() async {
    final url = Uri.https(
      'api.spotify.com',
      '/v1/albums/${widget.albumId}/tracks',
    );
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.accessToken}',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        albumTracks = data['items'];
      });
    } else {
      print('Failed to fetch album tracks');
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
  Widget build(BuildContext context) {
    return Consumer2<AppThemeProvider, SavedTracksProvider>(
      builder: (context, appThemeProvider, savedTracksProvider, _) {
        return Scaffold(
          backgroundColor: appThemeProvider.themeData.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: appThemeProvider.themeData.colorScheme.background,
            title: Text(
              albumData != null ? albumData['name'] : 'Album Details',
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
                  if (albumData != null)
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                albumData['images'][0]['url'] ?? '',
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              'Release Date: ${albumData['release_date'] ?? 'N/A'}',
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
                  if (albumTracks != null)
                    Expanded(
                      child: ListView.builder(
                        itemCount: albumTracks!.length,
                        itemBuilder: (context, index) {
                          final track = albumTracks![index];
                          final trackName = track['name'];
                          final artistName = track['artists'][0]['name'];
                          final imageUrl = albumData['images'][0]['url'];

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
                                  const SizedBox(width: 8.0),
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
}
