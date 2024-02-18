// import 'package:blog_app/view/login/login_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// import '../db_helper/db_helper.dart';
//
// class HomeScreen extends StatefulWidget {
//   static const String routeName = '/home';
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final DbHelper dbHelper = DbHelper();
//   @override
//   void initState() {
//     dbHelper.initNotification();
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold(
//       appBar: AppBar(title: const Text('Sign Up'),),
//       body: ListView(
//         children: [
//           const Text("Welcome Admin"),
//           Center(
//             child: ElevatedButton(onPressed: () async{
//                FirebaseAuth.instance.signOut();
//                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
//             }, child: const Text('SignOut'))
//           )
//         ],
//       ),
//     );
//   }
// }
