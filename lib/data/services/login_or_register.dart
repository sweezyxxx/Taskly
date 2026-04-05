import 'package:taskly/presentation/screens/login_screen.dart';
import 'package:taskly/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {

  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
     if (showLoginPage) {
      return LoginScreen(onTap: togglePages,);
     } else {
      return RegisterScreen(onTap: togglePages,);
     }
  }
}