// ignore_for_file: library_prefixes, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../logic/app_theme.dart';
import '../widgets/search_bar.dart' as CustomSearchBar;
import 'playlist_details.dart';

class PlaylistScreen extends StatefulWidget {
  final String accessToken;

  const PlaylistScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  List<dynamic>? recommendedPlaylists;
  String? selectedSongUri;
  final AppThemeProvider appThemeProvider = AppThemeProvider();
  int loadedPlaylists = 30; 
  bool isLoading = false; 

  @override
  void initState() {
    super.initState();
    _fetchRecommendedPlaylists();
  }

  Future<void> _fetchRecommendedPlaylists() async {
    final url = Uri.https(
      'api.spotify.com',
      '/v1/browse/featured-playlists',
      {'limit': '30'},
    );

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.accessToken}',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        recommendedPlaylists = data['playlists']['items'];
      });
    } else {
      print('Failed to fetch recommended playlists');
    }
  }

  Future<void> _loadMorePlaylists() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    await Future.delayed(Duration.zero); 

    final url = Uri.https(
      'api.spotify.com',
      '/v1/browse/featured-playlists',
      {'limit': '4', 'offset': (recommendedPlaylists?.length ?? 0).toString()},
    );
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.accessToken}',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final newPlaylists = data['playlists']['items'];
      setState(() {
        recommendedPlaylists?.addAll(newPlaylists);
        isLoading = false;
      });
    } else {
      print('Failed to load more playlists');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemSelected(String item) {
    setState(() {
      selectedSongUri = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeProvider>(
      builder: (context, appThemeProvider, _) {
        return Scaffold(
          backgroundColor: appThemeProvider.themeData.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        iconSize: 34,
                        color: appThemeProvider.themeData.primaryColor,
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: CustomSearchBar.SearchBar(
                          onItemSelected: _onItemSelected,
                          accessToken: widget.accessToken,
                          selectedSongUri: selectedSongUri,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                 Text(
                  'Recommended Playlists',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: appThemeProvider.themeData.colorScheme.onPrimary
                  ),
                ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollEndNotification &&
                          scrollNotification.metrics.extentAfter == 0) {
                        _loadMorePlaylists();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: (loadedPlaylists + 1) ~/ 2 + 1,
                      itemBuilder: (context, index) {
                        if (index * 2 < loadedPlaylists) {
                          return Row(
                            children: [
                              if (recommendedPlaylists != null &&
                                  index * 2 < recommendedPlaylists!.length)
                                Expanded(
                                  child: _buildPlaylistCard(
                                    recommendedPlaylists![index * 2],
                                    appThemeProvider,
                                  ),
                                ),
                              const SizedBox(width: 16.0),
                              if (index * 2 + 1 < loadedPlaylists &&
                                  recommendedPlaylists != null &&
                                  index * 2 + 1 < recommendedPlaylists!.length)
                                Expanded(
                                  child: _buildPlaylistCard(
                                    recommendedPlaylists![index * 2 + 1],
                                    appThemeProvider,
                                  ),
                                ),
                            ],
                          );
                        } else if (index * 2 == loadedPlaylists) {
                          if (isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            return const SizedBox();
                          }
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _navigateToPlaylistDetails(String playlistId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PlaylistDetailsScreen(
        accessToken: widget.accessToken,
        playlistId: playlistId,
      ),
    ),
  );
}


  Widget _buildPlaylistCard(
      dynamic playlist, AppThemeProvider appThemeProvider) {
    final playlistName = playlist['name'];
    final imageUrl = playlist['images'][0]['url'] ?? '';
     final playlistId = playlist['id'];

    return SizedBox(
      width: 150,
      height: 250,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
             _navigateToPlaylistDetails(playlistId);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                child: Text(
                  playlistName,
                  style: TextStyle(
                    color: appThemeProvider.themeData.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

