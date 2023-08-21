// ignore_for_file: library_prefixes, avoid_print
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../logic/app_theme.dart';
import '../widgets/search_bar.dart' as CustomSearchBar;
import 'albums_details.dart'; 

class AlbumsScreen extends StatefulWidget {
  final String accessToken;

  const AlbumsScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  List<dynamic>? albums;
  final AppThemeProvider appThemeProvider = AppThemeProvider();
  String? selectedSongUri;

  @override
  void initState() {
    super.initState();
    fetchAlbums();
  }


  Future<void> fetchAlbums() async {
    final apiEndpoint = Uri.parse(
        'https://api.spotify.com/v1/browse/new-releases?country=US&limit=20');
    try {
      final response = await http.get(
        apiEndpoint,
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final albumsData = jsonResponse['albums']['items'];
        setState(() {
          albums = albumsData;
        });
      } else {
        print('Error fetching albums: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _onItemSelected(String item) {
    setState(() {
      selectedSongUri = item;
    });
  }

  void _navigateToAlbumDetails(String albumId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlbumDetailsScreen(
          accessToken: widget.accessToken,
          albumId: albumId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeProvider>(
      builder: (context, appThemeProvider, _) {
        return Scaffold(
          backgroundColor: appThemeProvider.themeData.scaffoldBackgroundColor,
          body: Column(
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
              Expanded(
                child: ListView.builder(
                  itemCount: albums?.length ?? 0,
                  itemBuilder: (context, index) {
                    final album = albums?[index];
                    return _buildAlbumCard(album, appThemeProvider);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildAlbumCard(dynamic album, AppThemeProvider appThemeProvider) {
    final albumName = album['name'];
    final imageUrl = album['images'][0]['url'] ?? '';
    final albumId = album['id']; 

    return GestureDetector(
      onTap: () {
        _navigateToAlbumDetails(
            albumId); 
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          child: Padding(
            padding:   const EdgeInsets.all(6.0),
            child: Column(
              children: [
                Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    albumName,
                    style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
