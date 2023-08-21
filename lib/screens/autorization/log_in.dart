// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/app_theme.dart';
import '../../logic/user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppThemeProvider, UserModel>(
      builder: (context, appThemeProvider, userModel, _) {
        return Scaffold(
          backgroundColor: appThemeProvider.themeData.scaffoldBackgroundColor,
          appBar: AppBar(
             title: const Center(child: Text('Log in')),
            backgroundColor: appThemeProvider.themeData.appBarTheme.backgroundColor,
            shadowColor: appThemeProvider.themeData.appBarTheme.shadowColor,
            foregroundColor: appThemeProvider.themeData.appBarTheme.foregroundColor,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  style: TextStyle(color: appThemeProvider.themeData.primaryColor),
                  cursorColor: appThemeProvider.themeData.colorScheme.primary,
                
                  controller: emailController,
                  decoration:  InputDecoration(
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

                    ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  style: TextStyle(color: appThemeProvider.themeData.primaryColor),
                  cursorColor: appThemeProvider.themeData.colorScheme.primary,
                  controller: passwordController,
                  decoration:  InputDecoration(
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

                    ),
                  obscureText: true,
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  style: appThemeProvider.themeData.elevatedButtonTheme.style,
                  onPressed: () async {
                    String email = emailController.text;
                    String password = passwordController.text;
                    if (email.isNotEmpty && password.isNotEmpty) {
                      // Перевірка формату email
                      bool isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
                      if (!isEmailValid) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid email format.')),
                        );
                        return;
                      }
                      // Перевірка формату пароля
                      bool isPasswordValid = password.length >= 5 &&
                          password.contains(RegExp(r'[A-Z]')) &&
                          password.contains(RegExp(r'\d'));
                      if (!isPasswordValid) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Password must be at least 5 characters with at least one uppercase letter and one digit.'),
                          ),
                        );
                        return;
                      }
                      // Перевірка наявності користувача перед перевіркою входу
                      bool isUserExists = await userModel.checkUserExists(email);
                      if (!isUserExists) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User not found. Please register.')),
                        );
                        return;
                      }
                      // Перевірка введених даних для входу
                      bool isLoggedIn = await userModel.logIn(email, password);
                      if (isLoggedIn) {
                        Navigator.pushNamed(context, '/account');
                        print('Log in successful!');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid email or password. Please try again.')),
                        );
                        print('Invalid email or password. Please try again.');
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter email and password.')),
                      );
                    }
                  },
                  child:  Text('Log in', 
                  style: TextStyle(
                  color: appThemeProvider.themeData.colorScheme.onPrimary,
                  ),
                  ),
                  ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  style: appThemeProvider.themeData.elevatedButtonTheme.style,
                  onPressed: () {
                    Navigator.pushNamed(context, '/registration');
                  },
                  child: Text('Sign in',
                  style: TextStyle(
                  color: appThemeProvider.themeData.colorScheme.onPrimary,
                  ),),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
