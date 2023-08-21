// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../logic/app_theme.dart';
import '../logic/saved_tracks_provider.dart';

class AudiobookDetailsScreen extends StatefulWidget {
  final String accessToken;
  final String audiobookId;

  const AudiobookDetailsScreen({
    Key? key,
    required this.accessToken,
    required this.audiobookId,
  }) : super(key: key);

  @override
  _AudiobookDetailsScreenState createState() => _AudiobookDetailsScreenState();
}

class _AudiobookDetailsScreenState extends State<AudiobookDetailsScreen> {
  dynamic audiobookData; 

  @override
  void initState() {
    super.initState();
    _fetchAudiobookDetails();
  }

  Future<void> _fetchAudiobookDetails() async {
    final url = Uri.https(
      'api.spotify.com',
      '/v1/audiobooks/${widget.audiobookId}',
    );
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.accessToken}',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        audiobookData = data;
      });
    } else {
      print('Failed to fetch audiobook details');
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
            audiobookData != null ? audiobookData['title'] : 'Audiobook Details',
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
                if (audiobookData != null)
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
                              audiobookData['cover_image_url'] ?? '',
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Author: ${audiobookData['author'] ?? 'N/A'}',
                            style: TextStyle(
                                fontSize: 16.0,
                                color: appThemeProvider
                                    .themeData.colorScheme.onPrimary),
                          ),
                          Text(
                            'Narrator: ${audiobookData['narrator'] ?? 'N/A'}',
                            style: TextStyle(
                                fontSize: 16.0,
                                color: appThemeProvider
                                    .themeData.colorScheme.onPrimary),
                          ),
                          Text(
                            'Publisher: ${audiobookData['publisher'] ?? 'N/A'}',
                            style: TextStyle(
                                fontSize: 16.0,
                                color: appThemeProvider
                                    .themeData.colorScheme.onPrimary),
                          ),
                          Text(
                            'Duration: ${audiobookData['duration'] ?? 'N/A'}',
                            style: TextStyle(
                                fontSize: 16.0,
                                color: appThemeProvider
                                    .themeData.colorScheme.onPrimary),
                          ),
                        ],
                      ),
                    ),
                  ), 
              ],
            ),
          ),
        ),
      );
    });
  }
}
