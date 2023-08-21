// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../logic/app_theme.dart';
import '../../logic/user_model.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    Provider.of<UserModel>(context, listen: false).loadUserData();
    Provider.of<UserModel>(context, listen: false).loadImage();
    _getUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _getUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String name = prefs.getString('name') ?? '';
      String email = prefs.getString('email') ?? '';
      String password = prefs.getString('password') ?? '';

      setState(() {
        nameController.text = name;
        emailController.text = email;
        passwordController.text = password;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _saveUserData() async {
    try {
      UserModel userModel = Provider.of<UserModel>(context, listen: false);
      String name = nameController.text;
      String email = emailController.text;
      String password = passwordController.text;

      userModel.updateUserData(name, email, password);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', name);
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await userModel.saveUserData();
      userModel.setLoggedIn(true);
      userModel.updateCurrentIndexChanged(2);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      UserModel userModel = Provider.of<UserModel>(context, listen: false);
      userModel.saveImage(_image!.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeProvider>(
      builder: (context, appThemeProvider, _) {
        return WillPopScope(
          onWillPop: () async {
            _saveUserData();
            Navigator.pop(context);
            return false; 
          },
          child: Scaffold(
            backgroundColor: appThemeProvider.themeData.scaffoldBackgroundColor,
            appBar: AppBar(
            backgroundColor: appThemeProvider.themeData.appBarTheme.backgroundColor,
            shadowColor: appThemeProvider.themeData.appBarTheme.shadowColor,
            foregroundColor: appThemeProvider.themeData.appBarTheme.foregroundColor,
              title: const Center(child: Text('User Account')),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _pickImage();
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              _image != null ? FileImage(_image!) : null,
                          child: _image == null
                              ? (nameController.text.isNotEmpty
                                  ? Text(
                                      nameController.text[0],
                                      style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : null)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          style: TextStyle(
                              color: appThemeProvider.themeData.primaryColor),
                              cursorColor: appThemeProvider.themeData.colorScheme.primary,
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(color: appThemeProvider.themeData.colorScheme.onPrimary),
                    fillColor: appThemeProvider.themeData.colorScheme.background,
                    filled: true,
                    hintStyle: TextStyle(color: appThemeProvider.themeData.primaryColor),
                     border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: appThemeProvider.themeData.colorScheme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: appThemeProvider.themeData.colorScheme.primary),
                    ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                _saveUserData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Name saved successfully'),
                                  ),
                                );
                              },
                              icon: Icon(Icons.change_circle_rounded,
                                  color: appThemeProvider.themeData.primaryColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10, height: 10),
                  TextField(
                    style: TextStyle(
                        color: appThemeProvider.themeData.primaryColor),
                        cursorColor: appThemeProvider.themeData.colorScheme.primary,
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: appThemeProvider.themeData.colorScheme.onPrimary),
                    fillColor: appThemeProvider.themeData.colorScheme.background,
                    filled: true,
                    hintStyle: TextStyle(color: appThemeProvider.themeData.primaryColor),
                     border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: appThemeProvider.themeData.colorScheme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: appThemeProvider.themeData.colorScheme.primary),
                    ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _saveUserData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Email saved successfully'),
                            ),
                          );
                        },
                        icon: Icon(Icons.change_circle_rounded,
                            color: appThemeProvider.themeData.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20, width: 10),
                  TextField(
                    style: TextStyle(
                        color: appThemeProvider.themeData.primaryColor),
                        cursorColor: appThemeProvider.themeData.colorScheme.primary,
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: appThemeProvider.themeData.colorScheme.onPrimary),
                    fillColor: appThemeProvider.themeData.colorScheme.background,
                    filled: true,
                    hintStyle: TextStyle(color: appThemeProvider.themeData.primaryColor),
                     border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: appThemeProvider.themeData.colorScheme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: appThemeProvider.themeData.colorScheme.primary),
                    ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _saveUserData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password saved successfully'),
                            ),
                          );
                        },
                        icon: Icon(Icons.change_circle_rounded,
                            color: appThemeProvider.themeData.primaryColor),
                      ),
                    ),
                    obscureText: true,
                  ),
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(width: 10, height: 16),
                        ElevatedButton(

                          onPressed: () {
                            _saveUserData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Data saved successfully'),
                              ),
                            );
                          },
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
                          child: const Text('Save Data'),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            _pickImage();
                          },
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
                          child: const Text('Change Photo'),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () async {
                            Provider.of<UserModel>(context, listen: false)
                                .setLoggedIn(false);
                            Provider.of<UserModel>(context, listen: false)
                                .updateCurrentIndexChanged(2);
                            await Future.delayed(const Duration(milliseconds: 100));
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home_page',
                              (route) => false,
                            );
                          },
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
                          child: const Text('Log out'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}