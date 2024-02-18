import 'dart:developer';
import 'dart:io';
import 'package:blog_app/helper/validation.dart';
import 'package:blog_app/view/register/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../Services/api.dart';
import '../../helper/dialogs.dart';
import '../home_screen2.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Size mq = MediaQuery.of(context).size;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isObscure = true;

// handles google login button click
  _handleGoogleBtnClick() {
    //for showing progress bar
    Dialogs.showProgressBar(context);

    // SignInWithGoogle account function
    _signInWithGoogle().then((user) async {
      //for hiding progress bar
      Navigator.pop(context);

      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen2()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const HomeScreen2()));
          });
        }
      }
    });
  }

  // SignInWithGoogle account function
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      Dialogs.showSnackBar(
          context, """Something Went Wrong (Check Internet!)""");
      return null;
    }
  }

  //sign out function
  // _signOut() async {
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn().signOut();
  // }

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
            const Text('Log In',
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
            const SizedBox(height: 44),

            // Input Your Email
            const Text('EMAIL',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xff1E1F20))),
            const SizedBox(height: 8),
            buildEmailSection(),
            const SizedBox(height: 24),

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
            buildPasswordSection(),
            const SizedBox(height: 26),

            // Login button for login with email and password
            _buildLoginButton(context),
            const SizedBox(height: 26),

            // Go to register page to create account
            buildCreateAccountSection(),
            const SizedBox(height: 26),

            // Login   button for login with Google account
            _loginWIthGoogleButton()
          ],
        ),
      ),
    );
  }

  ElevatedButton _loginWIthGoogleButton() {
    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 223, 255, 187),
            shape: const StadiumBorder(),
            elevation: 1),
        onPressed: () {
          _handleGoogleBtnClick();
        },

        //google icon
        icon: Image.asset('images/google.png', height: mq.height * .03),

        //login with google label
        label: RichText(
          text: const TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 16),
              children: [
                TextSpan(text: 'Login with '),
                TextSpan(
                    text: 'Google',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ]),
        ));
  }

  ElevatedButton _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState?.validate() ?? false) {
          _formKey.currentState!.save();
          String email = _emailController.text;
          String password = _passwordController.text;
          User? user = await APIs.signInWhtEmailAndPass(email, password);
          if (user != null) {
            Dialogs.showProgressBar(context);
            if ((await APIs.userExists())) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const HomeScreen2()));
              Dialogs.showSnackBar(context, """Log In Successfully""");
            } else {
              Dialogs.showSnackBar(context, """This email not a valid user""");
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  "Email or Password Incorrect",
                )));
          }
        }else{
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Enter Email and Password",
              )));
        }
      },
      child: const Text('Log In'),
    );
  }

  Row buildCreateAccountSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff8E8F8F)),
        ),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, RegistrationScreen.routeName);
            },
            style: TextButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero),
            child: const Text('Register',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff212223))))
      ],
    );
  }

  TextFormField buildEmailSection() {
    return TextFormField(
        controller: _emailController,
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

  TextFormField buildPasswordSection() {
    return TextFormField(
        controller: _passwordController,
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
            return 'Password must be at least 6 characters long.';
          }
          // You can add more password validation criteria as needed
          return null;
        });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
