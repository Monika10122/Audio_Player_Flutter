// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel with ChangeNotifier {
  String _name = '';
  String _email = '';
  String _password = '';
  bool _isLoggedIn = false;
  int _currentIndexChanged = 0;
  File? _image;

  bool get isLoggedIn => _isLoggedIn; //Метод перевірки чи увійшов користувач
  String get name => _name;
  String get email => _email;
  String get password => _password;
  int get currentIndexChanged => _currentIndexChanged;
  File? get image => _image;

  // Метод для входу в обліковий запис
  Future<bool> logIn(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedEmail = prefs.getString('email') ?? '';
    String savedPassword = prefs.getString('password') ?? '';

    if (email == savedEmail && password.toLowerCase() == savedPassword.toLowerCase()) {
      _isLoggedIn = true;
      _currentIndexChanged = 2; 
      notifyListeners();
      return true;
    } else {
      _isLoggedIn = false;
      _currentIndexChanged = 0; 
      notifyListeners();
      return false;
    }
  }
   
    Future<bool> checkUserExists(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? registeredUsers = prefs.getStringList('registered_users');
    bool isUserExists = registeredUsers?.contains(email) ?? false;
    return isUserExists;
  }

  // Метод для виходу з облікового запису
  Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    _name = '';
    _email = '';
    _password = '';
   _currentIndexChanged = 2;
    await prefs.remove('email'); 
    await prefs.remove('password'); 
    notifyListeners();
  }
   
    Future<void> loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String name = prefs.getString('name') ?? '';
      String email = prefs.getString('email') ?? '';
      String password = prefs.getString('password') ?? '';

      _name = name;
      _email = email;
      _password = password.toLowerCase();
      notifyListeners();
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

    Future<bool> registerUser(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> registeredUsers = prefs.getStringList('registered_users') ?? [];
    if (registeredUsers.contains(email)) {
      return false; 
    } else {
      registeredUsers.add(email);
      await prefs.setStringList('registered_users', registeredUsers);
      await prefs.setString('email', email);
      await prefs.setString('password', password.toLowerCase());
      print('User registered: $email, $password');
      return true; 
    }
  }

   Future<void> saveUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', _name);
      await prefs.setString('email', _email);
      await prefs.setString('password', _password);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }
  Future<void> saveImage(String imagePath) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('image_path', imagePath);
    } catch (e) {
      print('Error saving image path: $e');
    }
  }

  // Метод для завантаження зображення користувача з локальних налаштувань
  Future<void> loadImage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String imagePath = prefs.getString('image_path') ?? '';

      if (imagePath.isNotEmpty) {
        _image = File(imagePath);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading image: $e');
    }
  }
  // Метод для оновлення даних користувача
  void updateUserData(String name, String email, String password) {
    _name = name;
    _email = email;
    _password = password.toLowerCase();
    notifyListeners();
  }
  

  // Метод для встановлення статусу авторизації
  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  // Метод для оновлення значення currentIndexChanged
  void updateCurrentIndexChanged(int index) {
    _currentIndexChanged = index;
    notifyListeners();
  }
}
