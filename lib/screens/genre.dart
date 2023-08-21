// ignore_for_file: library_prefixes, avoid_print

import 'package:audioplayer1/screens/genre_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/search_bar.dart' as CustomSearchBar;
import '../logic/app_theme.dart';

class GenreScreen extends StatefulWidget {
  final String accessToken;

  const GenreScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  List<String> allGenres = [];
  List<String> filteredGenres = [];
  String? selectedSongUri;

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  void _onItemSelected(String item) {
    setState(() {
      selectedSongUri = item;
    });
  }

  Future<void> _fetchGenres() async {
    final url = Uri.https(
        'api.spotify.com', '/v1/recommendations/available-genre-seeds');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.accessToken}',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        allGenres = List<String>.from(data['genres']);
        filteredGenres = allGenres;
      });
    } else {
      print('Failed to fetch genres');
    }
  }

  void _navigateToGenreDetails(String genre) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GenreDetailsScreen(
        accessToken: widget.accessToken, genreName: genre,
       // playlistId: playlistId,
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
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        iconSize: 34,
                        color: appThemeProvider.themeData.primaryColor,
                        icon: const Icon(Icons.arrow_back_rounded,                        
                        ),                    
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
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      childAspectRatio: 2.0,
                    ),
                    itemCount: filteredGenres.length,
                    itemBuilder: (context, index) {
                      final genre = filteredGenres[index];
                      return GestureDetector(
                        onTap: () {
                          _navigateToGenreDetails(genre);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: appThemeProvider
                                  .themeData.colorScheme.background,
                                  
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Center(
                              child: Text(
                                genre,
                                style: TextStyle(
                                  color: appThemeProvider
                                      .themeData.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
