import 'package:audioplayer1/screens/saved.dart';
import 'logic/app_theme.dart';
import 'logic/saved_tracks_provider.dart';
import 'screens/autorization/account_page.dart';
import 'screens/autorization/log_in.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/albums.dart';
import 'screens/audiobooks.dart';
import 'screens/autorization/sing_in.dart';
import 'screens/genre.dart';
import 'screens/home.dart';
import 'screens/home_page.dart';
import 'screens/playlist.dart';
import 'screens/settings.dart';
import 'logic/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const String accessToken = 'YOUR_ACCESS_TOKEN';

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  UserModel userModel = UserModel();
  runApp(MyApp(accessToken: accessToken, prefs: prefs, userModel: userModel));
}

class MyApp extends StatelessWidget {
  final String accessToken;
  final SharedPreferences prefs;
  final UserModel userModel;

  const MyApp(
      {super.key,
      required this.accessToken,
      required this.prefs,
      required this.userModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider<AppThemeProvider>(
          create: (_) => AppThemeProvider(),
        ),
        ChangeNotifierProvider<UserModel>(
          create: (_) => userModel,
        ),
        ChangeNotifierProvider<SavedTracksProvider>(
          create: (_) => SavedTracksProvider(),
        ),
      ],
      child: Consumer3<AppThemeProvider, UserModel, SavedTracksProvider>(
        builder:
            (context, appThemeProvider, userModel, savedTracksProvider, _) {
          return MaterialApp(
            title: 'Easy Audio Player',
            theme: appThemeProvider.lightTheme,
            darkTheme: appThemeProvider.darkTheme,
            home: HomePage(
              accessToken: accessToken,
              prefs: prefs,
            ),
            routes: {
              '/settings': (context) => SettingsPage(
                    accessToken: accessToken,
                    setThemeMode: (themeMode) {
                      appThemeProvider.changeAndSaveTheme(
                          context, appThemeProvider, themeMode);
                    },
                  ),
              '/home_page': (context) => HomePage(
                    accessToken: accessToken,
                    prefs: prefs,
                  ),
              '/home': (context) => Home(accessToken: accessToken),
              '/playlist': (context) =>
                  PlaylistScreen(accessToken: accessToken),
              '/albums': (context) => AlbumsScreen(accessToken: accessToken),
              '/audiobooks': (context) =>
                  AudiobookScreen(accessToken: accessToken),
              '/genre': (context) => GenreScreen(accessToken: accessToken),
              '/registration': (context) => const RegistrationPage(),
              '/login': (context) => const LoginPage(),
              '/account': (context) => const AccountPage(),
              '/saved': (context) => SavedTracksScreen(
                    accessToken: accessToken,
                  ),
            },
            initialRoute: '/',
          );
        },
      ),
    );
  }
}
