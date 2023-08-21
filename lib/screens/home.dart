// ignore_for_file: avoid_print, library_prefixes

import 'dart:async';
import 'package:audioplayer1/logic/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/player_widget.dart';
import '../widgets/search_bar.dart' as CustomSearchBar;

class Home extends StatefulWidget {
  final Function(String)? onAuthorizationCodeReceived;
  final String accessToken;

  const Home({
    Key? key,
    this.onAuthorizationCodeReceived,
    required this.accessToken,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  List<String> playlists = [];
  List<String> genres = [];
  List<String> editors = [];
  List<String> albums = [];
  List<String> searchResults = [];

  StreamSubscription? _sub;
  String? selectedSongUri;

  @override
  void initState() {
    super.initState();
    _sub = Stream.fromIterable(Uri.base.queryParameters.entries).listen(
      (entry) {
        if (entry.key == 'code' && widget.onAuthorizationCodeReceived != null) {
          widget.onAuthorizationCodeReceived!(entry.value);
        }
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _sub?.cancel();
    super.dispose();
  }

  void _onItemSelected(String item) {
    setState(() {
      selectedSongUri = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeProvider>(builder: (context, appThemeProvider, _) {
      return Scaffold(
        backgroundColor: appThemeProvider.themeData.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                CustomSearchBar.SearchBar(
                  onItemSelected: _onItemSelected,
                  accessToken: widget.accessToken,
                  selectedSongUri: selectedSongUri,
                ),
                const SizedBox(
                  height: 15,
                  width: 10,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: [
                        SafeArea(
                          child: ListTile(
                            textColor: appThemeProvider.themeData.listTileTheme.textColor,
                            tileColor: appThemeProvider.themeData.listTileTheme.tileColor,
                            iconColor: appThemeProvider.themeData.listTileTheme.iconColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            leading: const Icon(Icons.library_music),
                            title: const Text('Playlists'),
                            subtitle: Column(
                              children: playlists
                                  .map((playlist) => Text(playlist))
                                  .toList(),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/playlist');
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                            textColor: appThemeProvider.themeData.listTileTheme.textColor,
                            tileColor: appThemeProvider.themeData.listTileTheme.tileColor,
                            iconColor: appThemeProvider.themeData.listTileTheme.iconColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          leading: const Icon(Icons.music_note),
                          title: const Text('Genres'),
                          subtitle: Column(
                            children:
                                genres.map((genre) => Text(genre)).toList(),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/genre');
                          },
                        ),
                        const SizedBox(height: 10),
                       
                        ListTile(
                            textColor: appThemeProvider.themeData.listTileTheme.textColor,
                            tileColor: appThemeProvider.themeData.listTileTheme.tileColor,
                            iconColor: appThemeProvider.themeData.listTileTheme.iconColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          leading: const Icon(Icons.edit),
                          title: const Text('Audiobooks'),
                          subtitle: Column(
                            children:
                                editors.map((editor) => Text(editor)).toList(),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/audiobooks');
                          },
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                            textColor: appThemeProvider.themeData.listTileTheme.textColor,
                            tileColor: appThemeProvider.themeData.listTileTheme.tileColor,
                            iconColor: appThemeProvider.themeData.listTileTheme.iconColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          leading: const Icon(Icons.album),
                          title: const Text('Albums'),
                          subtitle: Column(
                            children:
                                albums.map((album) => Text(album)).toList(),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/albums');
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
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
    });
  }
}
















/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  final Function(String)? onAuthorizationCodeReceived;

  const Home({Key? key, this.onAuthorizationCodeReceived}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();

  List<String> playlists = [];
  List<String> genres = [];
  List<String> artists = [];
  List<String> editors = [];
  List<String> albums = [];
  List<String> searchResults = [];

  StreamSubscription? _sub;

  void _clearScreen() {
    setState(() {
      _searchController.clear();
      searchResults.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void initState() {
    super.initState();
    _sub = Stream.fromIterable(Uri.base.queryParameters.entries)
    .listen((entry) {
  if (entry.key == 'code' && widget.onAuthorizationCodeReceived != null) {
    widget.onAuthorizationCodeReceived!(entry.value);
  }
});

  }

  @override
  void dispose() {
    _searchController.dispose();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
          cursorColor: Theme.of(context).primaryColor,
          decoration: InputDecoration(
            prefixIcon: IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {
                // _search(_searchController.text);
              },
              color: Theme.of(context).primaryColor,
              iconSize: 30,
            ),
            suffixIcon: IconButton(
              color: Theme.of(context).primaryColor,
              icon: const Icon(Icons.clear),
              onPressed: _clearScreen,
            ),
            hintText: 'Search...',
            hintStyle: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 18,
            ),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // Perform search as the user types (optional)
            // ...
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SafeArea(
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: const Icon(Icons.library_music),
                title: const Text('Playlists'),
                subtitle: Column(
                  children: playlists.map((playlist) => Text(playlist)).toList(),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/playlist');
                  // Navigate to playlists screen
                  // ...
                },
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: const Icon(Icons.music_note),
              title: const Text('Genres'),
              subtitle: Column(
                children: genres.map((genre) => Text(genre)).toList(),
              ),
              onTap: () {
                // Navigate to genres screen
                // ...
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: const Icon(Icons.person),
              title: const Text('Artists'),
              subtitle: Column(
                children: artists.map((artist) => Text(artist)).toList(),
              ),
              onTap: () {
                // Navigate to artists screen
                // ...
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: const Icon(Icons.edit),
              title: const Text('Editors'),
              subtitle: Column(
                children: editors.map((editor) => Text(editor)).toList(),
              ),
              onTap: () {
                // Navigate to editors screen
                // ...
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: const Icon(Icons.album),
              title: const Text('Albums'),
              subtitle: Column(
                children: albums.map((album) => Text(album)).toList(),
              ),
              onTap: () {
                // Navigate to albums screen
                // ...
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: const Icon(Icons.search),
              title: const Text('Search Results'),
              subtitle: Column(
                children: searchResults.map((result) => Text(result)).toList(),
              ),
              onTap: () {
                // Navigate to search results screen
                // ...
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}


*/





/*
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();

  List<String> playlists = []; // Список плейлистів
  List<String> recentTracks = []; // Останні треки
  List<String> recommendations = []; // Рекомендації

  void _clearScreen() {
    setState(() {
      _searchController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  // Метод для отримання списку плейлистів з Spotify API
  Future<void> _fetchPlaylists(String accessToken) async {
    // ignore: unused_local_variable
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/playlists'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    // Обробка відповіді та оновлення значення 'playlists'
    // Можливо, вам знадобиться розпарсити відповідь та оновити стан playlists
  }

  // Метод для отримання останніх треків з Spotify API
  Future<void> _fetchRecentTracks(String accessToken) async {
    // ignore: unused_local_variable
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/recent-tracks'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    // Обробка відповіді та оновлення значення 'recentTracks'
    // Можливо, вам знадобиться розпарсити відповідь та оновити стан recentTracks
  }

  // Метод для отримання рекомендацій з Spotify API
  Future<void> _fetchRecommendations(String accessToken) async {
    // ignore: unused_local_variable
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/recommendations'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    // Обробка відповіді та оновлення значення 'recommendations'
    // Можливо, вам знадобиться розпарсити відповідь та оновити стан recommendations
  }

  // Метод для обміну коду авторизації на токен доступу
  Future<String?> _exchangeCodeForAccessToken(String code) async {
    final clientId = '6sFIWsNpZYqfjUpaCgueju';
    final clientSecret = 'YOUR_CLIENT_SECRET';
    final redirectUri = 'http://localhost:8000/callback';

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final accessToken = responseData['access_token'];
      return accessToken;
    } else {
      // Обробка помилки обміну коду авторизації на токен доступу
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Викликайте необхідні методи під час ініціалізації стану
    final code = '6sFIWsNpZYqfjUpaCgueju'; // Отриманий код авторизації після перенаправлення на Redirect URI
    _exchangeCodeForAccessToken(code).then((accessToken) {
      if (accessToken != null) {
        _fetchPlaylists(accessToken);
        _fetchRecentTracks(accessToken);
        _fetchRecommendations(accessToken);
      } else {
        // Обробка помилки обміну коду авторизації на токен доступу
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeProvider>(
      builder: (context, appThemeProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: _searchController,
              style: TextStyle(
                color: appThemeProvider.themeData.primaryColor,
              ),
              cursorColor: appThemeProvider.themeData.primaryColor,
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () {},
                  color: appThemeProvider.themeData.primaryColor,
                  iconSize: 30,
                ),
                suffixIcon: IconButton(
                  color: appThemeProvider.themeData.primaryColor,
                  icon: const Icon(Icons.clear),
                  onPressed: _clearScreen,
                ),
                hintText: 'Search...',
                hintStyle: TextStyle(
                  color: appThemeProvider.themeData.primaryColor,
                  fontSize: 18,
                ),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                // Виконайте функціонал пошуку тут
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                SafeArea(
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    style: appThemeProvider.themeData.listTileTheme.style,
                    leading: const Icon(Icons.library_music),
                    title: const Text('Playlists'),
                    subtitle: Column(
                      children: playlists.map((playlist) => Text(playlist)).toList(),
                    ),
                    onTap: () {
                      // Navigate to playlists screen
                    },
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  style: appThemeProvider.themeData.listTileTheme.style,
                  leading: const Icon(Icons.history),
                  title: const Text('Recent Tracks'),
                  subtitle: Column(
                    children: recentTracks.map((track) => Text(track)).toList(),
                  ),
                  onTap: () {
                    // Navigate to recent tracks screen
                  },
                ),
                const SizedBox(height: 10.0),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  style: appThemeProvider.themeData.listTileTheme.style,
                  leading: const Icon(Icons.star),
                  title: const Text('Recommendations'),
                  subtitle: Column(
                    children: recommendations.map((recommendation) => Text(recommendation)).toList(),
                  ),
                  onTap: () {
                    // Navigate to recommendations screen
                  },
                ),
                const SizedBox(height: 10.0),
              ],
            ),
            
          ),
        );
      },
    );
  }
}
*/