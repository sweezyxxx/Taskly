import 'package:taskly/data/services/auth_service.dart';
import 'package:taskly/presentation/widgets/my_button.dart';
import 'package:taskly/presentation/widgets/my_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {

  final void Function()? onTap;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  RegisterPage({super.key, required this.onTap});

  void register(BuildContext context) async {
    final auth = AuthService();
    if(_passwordController.text == _confirmPasswordController.text) {
      try {
        await auth.signUpWithEmailPassword(_emailController.text, _passwordController.text);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          showErrorDialog('The password provided is too weak', context);
        } else if (e.code == 'email-already-in-use') {
          showErrorDialog('The account already exists for that email', context);
        }
      } catch (e) {
        showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(e.toString()),
        )
      );
      }
    } else {
      showErrorDialog('Passwords dont match', context);
    }
  }

  void showErrorDialog(String text, BuildContext context) {
    showDialog(context: context, builder: (context) => AlertDialog(
        content: Text(text),
      ),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.adobe_sharp,
                size: 128,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              SizedBox(
                height: 20,
              ),
              Text('Welcome to our app', style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 16,
              ),),
              SizedBox(
                height: 40,
              ),
              MyTextField(
                horizontalPadding: 20,
                hint: 'Email',
                obscureText: false,
                controller: _emailController,
              ),
              SizedBox(
                height: 10,
              ),
              MyTextField(
                horizontalPadding: 20,
                hint: 'Password',
                obscureText: true,
                controller: _passwordController,
              ),
              SizedBox(
                height: 10,
              ),
              MyTextField(
                horizontalPadding: 20,
                hint: 'Confirm Password',
                obscureText: true,
                controller: _confirmPasswordController,
              ),
              SizedBox(
                height: 20,
              ),
              MyButton(
                text: 'Register',
                onTap: () => register(context),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?'),
                  SizedBox(width: 4,),
                  GestureDetector(
                    onTap: onTap,
                    child: Text('Login here', style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}