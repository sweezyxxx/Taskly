import 'package:taskly/data/services/auth_service.dart';
import 'package:taskly/presentation/widgets/my_button.dart';
import 'package:taskly/presentation/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {

  final void Function()? onTap;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginPage({super.key, required this.onTap});

  void login(BuildContext context) async {
    final auth = AuthService();

    try {
      await auth.signInWithEmailPassword(_emailController.text, _passwordController.text);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        )
      );
    }
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
              Text('Welcome back, you\'ve been missed', style: TextStyle(
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
                height: 30,
              ),
              MyButton(
                text: 'Login',
                onTap: () => login(context),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Not a member?'),
                  SizedBox(width: 4,),
                  GestureDetector(
                    onTap: onTap,
                    child: Text('Register now', style: TextStyle(
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