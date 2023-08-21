// ignore_for_file: library_prefixes, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../logic/app_theme.dart';
import '../widgets/search_bar.dart' as CustomSearchBar;
import 'audiobooks_details.dart';

// only available for the US, UK, Ireland, New Zealand and Australia
class AudiobookScreen extends StatefulWidget {
  final String accessToken;

  const AudiobookScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  State<AudiobookScreen> createState() => _AudiobookScreenState();
}

class _AudiobookScreenState extends State<AudiobookScreen> {
  List<dynamic>? recommendedAudiobooks;
  String? selectedAudiobookUri;
  final AppThemeProvider appThemeProvider = AppThemeProvider();
  int loadedAudiobooks = 30;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRecommendedAudiobooks();
  }

  Future<void> _fetchRecommendedAudiobooks() async {
    final url = Uri.https(
      'api.spotify.com',
      '/v1/browse/featured-audiobooks',
      {'limit': '20'},
    );
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.accessToken}',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        recommendedAudiobooks = data['audiobooks']['items'];
      });
    } else {
      print('Failed to fetch recommended audiobooks');
    }
  }

  void _onItemSelected(String item) {
    setState(() {
      selectedAudiobookUri = item;
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
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Recommended Audiobooks',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: appThemeProvider.themeData.colorScheme.onPrimary,
                  ),
                ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    child: ListView.builder(
                      itemCount: (loadedAudiobooks + 1) ~/ 2 + 1,
                      itemBuilder: (context, index) {
                        if (index * 2 < loadedAudiobooks) {
                          return Row(
                            children: [
                              if (recommendedAudiobooks != null &&
                                  index * 2 < recommendedAudiobooks!.length)
                                Expanded(
                                  child: _buildAudiobookCard(
                                    recommendedAudiobooks![index * 2],
                                    appThemeProvider,
                                  ),
                                ),
                              const SizedBox(width: 16.0),
                              if (index * 2 + 1 < loadedAudiobooks &&
                                  recommendedAudiobooks != null &&
                                  index * 2 + 1 < recommendedAudiobooks!.length)
                                Expanded(
                                  child: _buildAudiobookCard(
                                    recommendedAudiobooks![index * 2 + 1],
                                    appThemeProvider,
                                  ),
                                ),
                            ],
                          );
                        } else if (index * 2 == loadedAudiobooks) {
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

  void _navigateToAudiobookDetails(String audiobookId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudiobookDetailsScreen(
          accessToken: widget.accessToken,
          audiobookId: audiobookId,
        ),
      ),
    );
  }

  Widget _buildAudiobookCard(
      dynamic audiobook, AppThemeProvider appThemeProvider) {
    final audiobookName = audiobook['name'];
    final imageUrl = audiobook['images'][0]['url'] ?? '';
    final audiobookId = audiobook['id'];

    return SizedBox(
      width: 150,
      height: 250,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            _navigateToAudiobookDetails(audiobookId);
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
                  audiobookName,
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
