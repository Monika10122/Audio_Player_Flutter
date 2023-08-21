// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../logic/app_theme.dart';
import '../widgets/autorization.dart';

class SettingsPage extends StatefulWidget {
  final double initialVolume;
  final Function(String)? onAuthorizationCodeReceived;
  final String accessToken;
  final Function(String) setThemeMode;

  const SettingsPage({
    Key? key,
    this.initialVolume = 0.5,
    this.onAuthorizationCodeReceived,
    required this.accessToken,
    required this.setThemeMode,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    _loadVolume();
  }

  void launchSpotifyAuth() async {
    const clientId = '1f62a44857224938b018e2020f07905e';
    const redirectUri = 'http://localhost:8080/';
    const url =
        'https://accounts.spotify.com/authorize?client_id=$clientId&response_type=code&redirect_uri=$redirectUri&scope=user-read-private%20user-read-email';
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _loadVolume() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _volume = prefs.getDouble('volume') ?? widget.initialVolume;
    });
  }

  Future<void> _saveVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', volume);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeProvider>(
      builder: (context, appThemeProvider, _) {
        return Scaffold(
          backgroundColor: appThemeProvider.themeData.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: appThemeProvider.themeData.colorScheme.background,
            title: const Center(child: Text('Settings')),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Volume',
                      style: appThemeProvider.themeData.textTheme.titleMedium!
                         .copyWith(
                       color: appThemeProvider
                           .themeData.textTheme.titleMedium!.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Slider(
                 thumbColor: appThemeProvider.themeData.sliderTheme.thumbColor,
                  activeColor:
                     appThemeProvider.themeData.sliderTheme.activeTrackColor,
                  inactiveColor:
                      appThemeProvider.themeData.sliderTheme.inactiveTrackColor,
                  value: _volume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: (newValue) {
                    setState(() {
                      _volume = newValue;
                    });
                  },
                  onChangeEnd: (newValue) {
                    _saveVolume(newValue);
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: InkWell(
                    onTap: () {
                      appThemeProvider.toggleTheme();

                      final themeMode =
                          appThemeProvider.isDarkTheme ? 'dark' : 'light';
                      final prefs = SharedPreferences.getInstance();
                      prefs.then((prefs) {
                        prefs.setString('themeMode', themeMode.toString());
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          appThemeProvider.isDarkTheme
                              ? 'Dark Theme'
                              : 'Light Theme',
                          style: TextStyle(
                            color: appThemeProvider
                                .themeData.textTheme.titleMedium!.color,
                            fontSize: 19,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CupertinoSwitch(
                          value: appThemeProvider.isDarkTheme,
                          onChanged: (newValue) {
                            appThemeProvider.toggleTheme();
                            final themeMode = newValue ? 'dark' : 'light';
                            widget.setThemeMode(themeMode);
                            final prefs = SharedPreferences.getInstance();
                            prefs.then((prefs) {
                              prefs.setString('themeMode', themeMode);
                            });
                          },
                          activeColor: Colors.deepPurple,
                          thumbColor: Colors.grey,
                          trackColor: const Color(0xffFFB0CB),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: launchSpotifyAuth,
                     style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                appThemeProvider.themeData.elevatedButtonTheme.style
                                    ?.backgroundColor
                                    ?.resolve({})),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                    child: const Text('Authorize with Spotify'),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Autorization(accessToken: widget.accessToken),
              ],
            ),
          ),
        );
      },
    );
  }
}
