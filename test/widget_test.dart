
import 'package:audioplayer1/logic/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audioplayer1/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences implements SharedPreferences {
  final Map<String, String> _prefs = {};

  @override
  Future<bool> setString(String key, String value) {
    _prefs[key] = value;
    return Future.value(true);
  }

  @override
  String? getString(String key) => _prefs[key];

  @override
  Future<bool> remove(String key) {
    _prefs.remove(key);
    return Future.value(true);
  }

  // Implement other SharedPreferences methods as needed for testing
  // Here, we provide default implementations for methods that are not used in this test.
  @override
  Future<bool> clear() {
    _prefs.clear();
    return Future.value(true);
  }

  @override
  Future<bool> commit() {
    // Since we are using in-memory Map, no actual commit is needed.
    return Future.value(true);
  }

  @override
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  @override
  Set<String> getKeys() {
    return _prefs.keys.toSet();
  }

  @override
  bool? getBool(String key) {
    String? stringValue = _prefs[key];
    return stringValue == null ? null : stringValue.toLowerCase() == 'true';
  }

  @override
  double? getDouble(String key) {
    String? stringValue = _prefs[key];
    return stringValue == null ? null : double.tryParse(stringValue);
  }

  @override
  int? getInt(String key) {
    String? stringValue = _prefs[key];
    return stringValue == null ? null : int.tryParse(stringValue);
  }

  @override
  List<String>? getStringList(String key) {
    String? stringValue = _prefs[key];
    return stringValue?.split(',');
  }

  @override
  Future<bool> setBool(String key, bool value) {
    _prefs[key] = value.toString();
    return Future.value(true);
  }

  @override
  Future<bool> setDouble(String key, double value) {
    _prefs[key] = value.toString();
    return Future.value(true);
  }

  @override
  Future<bool> setInt(String key, int value) {
    _prefs[key] = value.toString();
    return Future.value(true);
  }

  @override
  Future<bool> setStringList(String key, List<String> value) {
    _prefs[key] = value.join(',');
    return Future.value(true);
  }

  @override
  Future<void> reload() async {}

  @override
  Future<bool> get(String key) {
    return Future.value(_prefs.containsKey(key));
  }
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create a mock SharedPreferences instance
    final SharedPreferences mockSharedPreferences = MockSharedPreferences();

    // Initialize the mock SharedPreferences with initial values
    await mockSharedPreferences.setString('email', 'test@example.com');
    await mockSharedPreferences.setString('password', 'test123');

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(
        accessToken: 'your_access_token_here',
        prefs: mockSharedPreferences,
        userModel: UserModel(), 
      //  appThemeProvider: AppThemeProvider(),
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
