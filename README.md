# audioplayer1

A Flutter application that interacts with the Spotify API to allow users to search and play songs.

## Introduction

This project demonstrates how to build a Flutter application that utilizes the Spotify API to enable users to search for and play songs. Before using the app, you need to create a Spotify application and set up the necessary credentials. The app provides features such as user authentication, theme customization, and saving favorite tracks.

## Prerequisites

To successfully run this app, you need to follow these steps:

1. **Spotify Application Setup**:
   - Create an application on the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard/applications).
   - Set the correct Redirect URIs in the application settings. For this app, you can use `http://localhost:8080/callback` during development.
   - Note down the Client ID and Client Secret from the application settings.

2. **Authorization**:
   - In the `lib/widgets/authorization.dart` file, replace `YOUR_CLIENT_ID` and `YOUR_REDIRECT_URI` with your actual Spotify application credentials.
   - After logging in to Spotify in the app, the authorization code will be displayed in the terminal. Copy this code and replace `YOUR_AUTHORIZATION_CODE` in the same file.

3. **Getting Access Token**:
   - Run the app and log in using your Spotify account.
   - After obtaining the authorization code and replacing it, perform a Hot Reload.
   - The access token will be printed in the terminal. Copy this token.

4. **Main Dart File**:
   - In the `lib/main.dart` file, replace `YOUR_ACCESS_TOKEN` with the access token obtained in the previous step.

## Features

- User Authentication: Log in with your Spotify account or sign up if you don't have one.
- Theme Customization: Choose from different themes to personalize the app's appearance.
- Search and Play Songs: Search for songs and play them using the integrated Spotify player.
- Save Favorite Tracks: Mark tracks as favorites to access them later.

## Getting Started

To get started with Flutter development:

1. Install Flutter by following the [official installation guide](https://flutter.dev/docs/get-started/install).
2. Clone this repository using `git clone https://github.com/your-username/audioplayer1.git`.
3. Navigate to the project folder using the terminal.
4. Run `flutter pub get` to install the project dependencies.
5. Connect a device or start an emulator, then run `flutter run` to launch the app.

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Spotify Web API Documentation](https://developer.spotify.com/documentation/web-api/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

