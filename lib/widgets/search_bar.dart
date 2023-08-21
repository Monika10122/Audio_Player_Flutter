// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayer1/logic/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/song_details.dart';

class SearchBar extends StatefulWidget {
  final void Function(String) onItemSelected;
  final String accessToken;
  final String? selectedSongUri;

  const SearchBar({
    Key? key,
    required this.onItemSelected,
    required this.accessToken,
    this.selectedSongUri,
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _showResults = false;
  String? selectedSongUri;

  void _searchItems(String query) async {
    final url =
        'https://api.spotify.com/v1/search?q=$query&type=track,artist,album,playlist';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tracks = data['tracks']['items'];

      final List<Map<String, dynamic>> results = [];
      for (var i = 0; i < tracks.length && i < 4; i++) {
        final track = tracks[i];
        final trackUri = track['uri'];
        final trackName = track['name'];
        final album = track['album'];
        final albumImages = album['images'];
        final imageUrl = albumImages.isNotEmpty ? albumImages[0]['url'] : '';

        results.add({
          'uri': trackUri,
          'name': trackName,
          'imageUrl': imageUrl,
        });
      }
      setState(() {
        _searchResults = results;
      });
    } else {
      setState(() {
        _searchResults = [
          {
            'uri': '',
            'name': 'Request failed with status: ${response.statusCode}',
            'imageUrl': ''
          }
        ];
      });
    }
  }

  void _searchItem(String item) async {
    final selectedSongUri =
        _searchResults.firstWhere((result) => result['name'] == item)['uri'];
    widget.onItemSelected(selectedSongUri);
    _clearScreen();
  }

  void _clearScreen() {
    setState(() {
      _searchController.clear();
      _searchResults = [];
      _showResults = false;
    });
    FocusScope.of(context).unfocus();
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

  void _showSongDetails(Map<String, dynamic> songData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongDetailsPage(
          songName: songData['name'],
          imageUrl: songData['imageUrl'],
          accessToken: widget.accessToken,
          selectedSongUri: songData['uri'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeProvider>(
      builder: (context, appThemeProvider, _) {
        return Column(
          children: <Widget>[
            Stack(
              children: [
                TextField(
                  controller: _searchController,
                  style:
                      TextStyle(color: appThemeProvider.themeData.primaryColor),
                  decoration: InputDecoration(
                    fillColor:
                        appThemeProvider.themeData.colorScheme.background,
                    filled: true,
                    hintStyle: TextStyle(
                        color: appThemeProvider.themeData.primaryColor),
                    hintText: 'Search',
                    suffixIcon: IconButton(
                      onPressed: _clearScreen,
                      icon: Icon(Icons.clear,
                          color: appThemeProvider.themeData.primaryColor),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color:
                              appThemeProvider.themeData.colorScheme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color:
                              appThemeProvider.themeData.colorScheme.primary),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _showResults = value.isNotEmpty;
                    });
                    if (value.isNotEmpty) {
                      _searchItems(value);
                    } else {
                      setState(() {
                        _searchResults = [];
                      });
                    }
                  },
                ),
              ],
            ),
            if (_showResults)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2.0,
                      blurRadius: 5.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = _searchResults[index];
                    final itemName = item['name'];
                    final itemImageUrl = item['imageUrl'];
                    return ListTile(
                      leading: itemImageUrl.isNotEmpty
                          ? SizedBox(
                              width: 40,
                              height: 40,
                              child: Image.network(itemImageUrl),
                            )
                          : const SizedBox(width: 40, height: 40),
                      title: Text(itemName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info),
                            onPressed: () {
                              _showSongDetails(item);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        playSelectedSong();
                        _searchItem(itemName);
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}