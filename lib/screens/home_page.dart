
import 'package:audioplayer1/screens/saved.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logic/app_theme.dart';
import '../logic/user_model.dart';
import 'autorization/account_page.dart';
import 'autorization/log_in.dart';
import 'home.dart';
import 'settings.dart';

class HomePage extends StatefulWidget {
  final String accessToken;
  final SharedPreferences prefs; 
  const HomePage({Key? key, required this.accessToken, required this.prefs})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _checkLoginStatus() {
    String? email = widget.prefs.getString('email');
    String? password = widget.prefs.getString('password');


    Future.delayed(Duration.zero, () {
      setState(() {
        Provider.of<UserModel>(context, listen: false)
            .setLoggedIn(email != null && password != null);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppThemeProvider>(
          create: (_) => AppThemeProvider(),
        ),
        ChangeNotifierProvider<UserModel>(
          create: (_) => UserModel(),
        ),
        Provider<SharedPreferences>(
          create: (_) => widget.prefs,
        ),
      ],
      child: Consumer3<AppThemeProvider, UserModel, SharedPreferences>(
        builder: (context, appThemeProvider, userModel, prefs, _) {
          return Scaffold(
            backgroundColor: appThemeProvider
                .themeData.scaffoldBackgroundColor, 
            body: Center(
              child: _buildPageContent(
                _selectedIndex,
                appThemeProvider.themeData.primaryColor,
                userModel,
              ),
            ),
            bottomNavigationBar: Theme(
              data: appThemeProvider.themeData.copyWith(
                canvasColor: appThemeProvider.themeData.colorScheme.background,
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark),
                    label: 'Saved',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Account',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPageContent(int index, Color primaryColor, UserModel userModel) {
    if (userModel.isLoggedIn) {
      switch (index) {
        case 0:
          return Builder(
            builder: (context) => Home(
              accessToken: widget.accessToken,
            ),
          );
        case 1:
          return  SavedTracksScreen(accessToken: widget.accessToken,);
        case 2:
          return const AccountPage();
        case 3:
          return SettingsPage(
            accessToken: widget.accessToken,
            setThemeMode: (themeMode) {
              final prefs = SharedPreferences.getInstance();
              prefs.then((prefs) {
                prefs.setString('themeMode', themeMode);
                context.read<AppThemeProvider>().toggleTheme();
              });
            },
          );
        default:
          return Home(accessToken: widget.accessToken);
      }
    } else {
      switch (index) {
        case 0:
          return Builder(
            builder: (context) => Home(
              accessToken: widget.accessToken,
            ),
          );
        case 1:
          return  SavedTracksScreen(accessToken: widget.accessToken,);
        case 2:
          return const LoginPage(); 
        case 3:
          return SettingsPage(
            accessToken: widget.accessToken,
            setThemeMode: (themeMode) {
              final prefs = SharedPreferences.getInstance();
              prefs.then((prefs) {
                prefs.setString('themeMode', themeMode);
                context.read<AppThemeProvider>().toggleTheme();
              });
            },
          );
        default:
          return Home(
              accessToken:
                  widget.accessToken); 
      }
    }
  }
}
