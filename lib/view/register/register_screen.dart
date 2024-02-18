import 'package:blog_app/Services/api.dart';
import 'package:blog_app/view/login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../db_helper/db_helper.dart';
import '../../helper/dialogs.dart';
import '../../helper/validation.dart';
import '../home_screen2.dart';

class RegistrationScreen extends StatefulWidget {
  static const String routeName = '/registration';

  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _userNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 40),

            // Header Section
            const Text('Registration',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 38,
                    color: Color(0xff1E1F20))),
            const SizedBox(height: 9),
            const Text('Welcome back!',
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xff1E1F20))),
            const SizedBox(height: 24),

            // User Name Text Filed
            const Text('User Name',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xff1E1F20))),
            const SizedBox(height: 8),
            _nameTextFiled(_userNameController),
            const SizedBox(height: 16),

            // Input Your Email
            const Text('Email',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xff1E1F20))),
            const SizedBox(height: 8),
            _emailTextFiled(_emailController),
            const SizedBox(height: 16),

            // Input Your Password
            Row(
              children: [
                const Text(
                  'PASSWORD',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff1E1F20)),
                ),
                const Spacer(),
                TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff1E1F20),
                          decoration: TextDecoration.underline),
                    ))
              ],
            ),
            _passwordTextFiled(_passwordController),
            const SizedBox(height: 16),

            const Text('Confirm Password',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xff1E1F20))),
            const SizedBox(height: 8),
            _confirmPassordFiled(_confirmPassController),
            const SizedBox(height: 16),

            // Registration button to login with email and password
            _buildRegisterButton(context),

            const SizedBox(height: 26),
            buildGoToLoginSection()
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildRegisterButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            String email = _emailController.text;
            String password = _passwordController.text;
            User? user = await APIs.signUpWhtEmailAndPass(email, password);
            if (user != null) {
              Dialogs.showProgressBar(context);
              if ((await APIs.userExists())) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: Colors.red,
                    content:
                        Text('You Have Already a account with this email')));
              } else {
                await APIs.createUser().then((value) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const HomeScreen2()));
                  Dialogs.showSnackBar(context, """Register Successfully""");
                });
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('You Have Already a account with this email')));
            }
          }
          // if(user != null){
          //   Navigator.pushReplacementNamed(context, HomeScreen.routeName);
          //   ScaffoldMessenger.of( context).showSnackBar(SnackBar(content: Text("Register Successfully")));
          //   print('signup ');
          // }else{
          //   print(' not signup ');
          // }
        },
        child: const Text('Register'));
  }

  Row buildGoToLoginSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "If have an account?",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff8E8F8F)),
        ),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, LoginScreen.routeName);
            },
            style: TextButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero),
            child: const Text('Login',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff212223))))
      ],
    );
  }

  TextFormField _nameTextFiled(TextEditingController controller) {
    return TextFormField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(borderSide: BorderSide(width: 5)),
            hintText: 'User Name',
            hintStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xff1E1F20))),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your user name.';
          } else {
            return null;
          }
        });
  }

  TextFormField _emailTextFiled(TextEditingController controller) {
    return TextFormField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(borderSide: BorderSide(width: 5)),
            hintText: 'Email',
            hintStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xff1E1F20))),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email address.';
          } else if (!Validation.isValidEmail(value)) {
            return 'Please enter a valid email address.';
          }
          return null;
        });
  }

  TextFormField _passwordTextFiled(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      obscureText: isObscure,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: const OutlineInputBorder(borderSide: BorderSide(width: 5)),
          hintText: 'Password',
          hintStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xff1E1F20)),
          suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  isObscure = !isObscure;
                });
              },
              icon: Icon(
                  isObscure
                      ? Icons.visibility_off_outlined
                      : Icons.remove_red_eye_outlined,
                  color: const Color(0xff1E1F20),
                  size: 24))),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password.';
        } else if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
    );
  }

  TextFormField _confirmPassordFiled(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      obscureText: isObscure,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: const OutlineInputBorder(borderSide: BorderSide(width: 5)),
          hintText: 'Password',
          hintStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xff1E1F20)),
          suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  isObscure = !isObscure;
                });
              },
              icon: Icon(
                  isObscure
                      ? Icons.visibility_off_outlined
                      : Icons.remove_red_eye_outlined,
                  color: const Color(0xff1E1F20),
                  size: 24))),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password.';
        } else if (value != _passwordController.text) {
          return 'Password doesn\'t match';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _userNameController.dispose();
    super.dispose();
  }
}
