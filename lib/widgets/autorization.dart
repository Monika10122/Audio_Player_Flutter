// ignore_for_file: avoid_print, library_private_types_in_public_api
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Autorization extends StatefulWidget {
  final String accessToken;

  const Autorization({Key? key, required this.accessToken}) : super(key: key);

  @override
  _AutorizationState createState() => _AutorizationState();
}

class _AutorizationState extends State<Autorization> {
  String accessToken = '';
    String? selectedSongUri;

  @override
  void initState() {
    super.initState();
    accessToken = widget.accessToken;
    const authorizationCode = 'YOUR_AUTHORIZATION_CODE'; 
    fetchAccessToken(authorizationCode);
    fetchDeviceId(accessToken);
  }

  Future<void> fetchAccessToken(String authorizationCode) async {
    const clientId = 'YOUR_CLIENT_ID';
    const clientSecret = 'YOUR_CLIENT_SECRET';
    const redirectUri = 'http://localhost:8080/';
    const scope = 'user-read-playback-state'; 

    final tokenEndpoint = Uri.parse('https://accounts.spotify.com/api/token');

    try {
      final response = await http.post(
        tokenEndpoint,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': authorizationCode,
          'redirect_uri': redirectUri,
          'scope': scope, 
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final token = jsonResponse['access_token'];
        setState(() {
          accessToken = token;
        });
        print('Access Token: $accessToken');
      } else {
        setState(() {
          accessToken =
              'Error exchanging authorization code for token: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        accessToken = 'Error: $e';
      });
    }
  }

  Future<void> fetchDeviceId(String accessToken) async {
    final url = Uri.parse('https://api.spotify.com/v1/me/player/devices');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final devices = jsonResponse['devices'] as List<dynamic>;

      final yourDevice = devices.firstWhere((device) => device['name'] == 'Назва вашого пристрою');
      final deviceId = yourDevice['id'];

      print('Your Device ID: $deviceId');
    } else {
      print('Error fetching devices: ${response.statusCode}');
    }
  }
  
Future<void> getPlayerDetails(String accessToken) async {
  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/me/player'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> playerData = json.decode(response.body);
    final currentlyPlaying = playerData['currently_playing_type'];
    if (currentlyPlaying == 'track') {
      final trackUri = playerData['item']['uri'];
      await playSelectedSong(trackUri, accessToken);
    } else {
      print('Currently playing something other than a track');
    }
  } else {
    print('Error getting player details - Status Code: ${response.statusCode}');
  }
}

Future<void> playSelectedSong(String trackUri, String accessToken) async {
  try {
    final response = await http.put(
      Uri.parse('https://api.spotify.com/v1/me/player/play'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'uris': [trackUri],
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


  Future<void> setPlaybackDevice(String accessToken, String deviceId) async {
    final response = await http.put(
      Uri.parse('https://api.spotify.com/v1/me/player'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'device_ids': [deviceId],
      }),
    );

    if (response.statusCode == 204) {
    } else {
      print('Error setting playback device - Status Code: ${response.statusCode}');
    }
  }

 Future<void> getAvailableDevices(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/player/devices'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
    } else {
      print('Error getting available devices - Status Code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Access Token: $accessToken'),
    );
  }
}



