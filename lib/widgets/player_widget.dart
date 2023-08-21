// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../logic/app_theme.dart';
import '../logic/saved_tracks_provider.dart';

class MiniAudioPlayer extends StatefulWidget {
  final void Function() onPlayerReady;
  final String selectedSongUri;
  final String accessToken;

  const MiniAudioPlayer({
    Key? key,
    required this.onPlayerReady,
    required this.selectedSongUri,
    required this.accessToken,

  }) : super(key: key);

  @override
  _MiniAudioPlayerState createState() => _MiniAudioPlayerState();
}

class _MiniAudioPlayerState extends State<MiniAudioPlayer> {
  bool _isPlaying = false;
  double _sliderValue = 0.0;
  final trackName = ''; 
  final artistName = ''; 
  final imageUrl = ''; 


  Future<void> playSelectedSong() async {
    try {
      final response = await http.put(
        Uri.parse('https://api.spotify.com/v1/me/player/play'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uris': [widget.selectedSongUri],
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

  Future<void> _playSong() async {
    try {
      final response = await http.put(
        Uri.parse('https://api.spotify.com/v1/me/player/play'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uris': [widget.selectedSongUri],
        }),
      );
      if (response.statusCode == 204) {
        setState(() {
          _isPlaying = true;
        });
        widget.onPlayerReady();
      } else {
        print('Error playing song - Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error playing song: $e');
    }
  }


  Future<void> _pauseSong() async {
    try {
      final response = await http.put(
        Uri.parse('https://api.spotify.com/v1/me/player/pause'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );
      if (response.statusCode == 204) {
        setState(() {
          _isPlaying = false;
        });
      } else {
        print('Error pausing song - Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error pausing song: $e');
    }
  }


  Future<void> _seekToPosition(double position) async {
    final newPosition = (position * 1000).toInt();
    try {
      final response = await http.put(
        Uri.parse('https://api.spotify.com/v1/me/player/seek'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'position_ms': newPosition,
        }),
      );

      if (response.statusCode == 204) {
        setState(() {
          _sliderValue = position;
        });
      } else {
        print('Error seeking song - Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error seeking song: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
  return Consumer2<AppThemeProvider, SavedTracksProvider>(
      builder: (context, appThemeProvider, savedTracksProvider, _) {
        final iconColor = appThemeProvider.themeData.iconTheme.color;
        return Container(
          height: 60,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: appThemeProvider.themeData.colorScheme.background,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () async {
                    // дії для попередньої пісні
                  },
                  icon: Icon(
                    Icons.skip_previous,
                    size: 28,
                    color: iconColor,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (_isPlaying) {
                      await _pauseSong();
                    } else {
                      await _playSong();
                    }
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                  },
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 28,
                    color: iconColor,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    //дії для наступної пісні
                  },
                  icon: Icon(
                    Icons.skip_next,
                    size: 28,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Slider(
                     thumbColor: appThemeProvider.themeData.sliderTheme.thumbColor,
                  activeColor:
                     appThemeProvider.themeData.sliderTheme.activeTrackColor,
                  inactiveColor:
                      appThemeProvider.themeData.sliderTheme.inactiveTrackColor,
                    value: _sliderValue,
                    onChanged: (newValue) {
                      setState(() {
                        _sliderValue = newValue;
                      });
                      _seekToPosition(newValue);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    savedTracksProvider.addTrack({
                                        'name': trackName,
                                        'artist': artistName,
                                        'imageUrl': imageUrl,
                                       
                                      });
                  },
                  icon: Icon(
                    Icons.favorite,
                    size: 28,
                    color: iconColor,
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
