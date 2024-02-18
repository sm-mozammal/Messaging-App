// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/api.dart';
import '../helper/dialogs.dart';
import '../model/chat_user.dart';
import 'login/login_screen.dart';

//profile screen -- to show signed in user info
class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Size mq = MediaQuery.of(context).size;

  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          //app bar
          appBar: AppBar(title: const Text('Profile Screen')),

          // //floating button to log out
          // floatingActionButton: Padding(
          //   padding: const EdgeInsets.only(bottom: 10),
          //   child: FloatingActionButton.extended(
          //       backgroundColor: Colors.redAccent,
          //       onPressed: () async {
          //         //for showing progress dialog
          //         Dialogs.showProgressBar(context);
          //
          //         await APIs.updateActiveStatus(false);
          //
          //         //sign out from app
          //         await APIs.auth.signOut().then((value) async {
          //           await GoogleSignIn().signOut().then((value) {
          //             //for hiding progress dialog
          //             Navigator.pop(context);
          //
          //             //for moving to home screen
          //             Navigator.pop(context);
          //
          //             APIs.auth = FirebaseAuth.instance;
          //
          //
          //             //replacing home screen with login screen
          //             Navigator.pushReplacement(
          //                 context,
          //                 MaterialPageRoute(
          //                     builder: (_) => const LoginScreen()));
          //             Dialogs.showSnackbar(context, """Sign Out Successfully""");
          //           });
          //         });
          //       },
          //       icon: const Icon(Icons.logout),
          //       label: const Text('Logout')),
          // ),

          //body
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // for adding some space
                    SizedBox(width: mq.width, height: mq.height * .03),

                    //user profile picture
                    _buildUserProfile(),

                    // for adding some space
                    SizedBox(height: mq.height * .04),

                    // user name label
                    Text(widget.user.name,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.w600)),

                    // for adding some space
                    SizedBox(height: mq.height * .01),

                    // user email label
                    Text(widget.user.email,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 18)),

                    // for adding some space
                    SizedBox(height: mq.height * .05),

                    // name input field
                    _nameTextFormField(),

                    // for adding some space
                    SizedBox(height: mq.height * .02),

                    // about input field
                    _aboutTextFormField(),

                    // for adding some space
                    SizedBox(height: mq.height * .05),

                    // update profile button
                    _updateProfileButton(context),

                    // for adding some space
                    SizedBox(height: mq.height * .02),

                    // Logout from profile button
                    _logoutButton(context),
                    SizedBox(height: mq.height * .05),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  ElevatedButton _logoutButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          shape: const StadiumBorder(),
          minimumSize: Size(mq.width * .5, mq.height * .06)),
      onPressed: () async {
        // Log Out Functionality with showing confirmation dialog
        _showLogOutDialog(context);
      },
      icon: const Icon(
        Icons.login,
        size: 28,
        color: Colors.white,
      ),
      label: const Text('Log Out',
          style: TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  ElevatedButton _updateProfileButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          // backgroundColor:Colors.deepOrange,
          shape: const StadiumBorder(),
          minimumSize: Size(mq.width * .5, mq.height * .06)),
      onPressed: () {
        _showUpdateDialog(context);
      },
      icon: const Icon(Icons.edit, size: 28),
      label: const Text('UPDATE', style: TextStyle(fontSize: 16)),
    );
  }

  TextFormField _aboutTextFormField() {
    return TextFormField(
      initialValue: widget.user.about,
      onSaved: (val) => APIs.me.about = val ?? '',
      validator: (val) =>
          val != null && val.isNotEmpty ? null : 'Required Field',
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.info_outline, color: Colors.deepOrange),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          hintText: 'eg. Feeling Happy',
          label: const Text('About')),
    );
  }

  TextFormField _nameTextFormField() {
    return TextFormField(
      initialValue: widget.user.name,
      onSaved: (val) => APIs.me.name = val ?? '',
      validator: (val) =>
          val != null && val.isNotEmpty ? null : 'Required Field',
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.person, color: Colors.deepOrange),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          hintText: 'Full Name',
          label: const Text('Name')),
    );
  }

  Stack _buildUserProfile() {
    return Stack(
      children: [
        //profile picture
        _image != null
            ?
            //local image
            ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .1),
                child: Image.file(File(_image!),
                    width: mq.height * .2,
                    height: mq.height * .2,
                    fit: BoxFit.cover))
            :

            //image from server
            ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .1),
                child: CachedNetworkImage(
                  width: mq.height * .2,
                  height: mq.height * .2,
                  fit: BoxFit.cover,
                  imageUrl: widget.user.image,
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(backgroundImage: AssetImage('images/profile.png')),
                ),
              ),

        //edit image button
        Positioned(
          bottom: mq.height * 0.00,
          right: -mq.height * 0.01,
          child: MaterialButton(
            elevation: 1,
            onPressed: () {
              _showBottomSheet();
            },
            shape: const CircleBorder(),
            color: Colors.white,
            child: const Icon(Icons.edit, color: Colors.deepOrange),
          ),
        )
      ],
    );
  }

  Future<dynamic> _showLogOutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to Log Out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                //for showing progress dialog
                Dialogs.showProgressBar(context);

                await APIs.updateActiveStatus(false);
                //sign out from app
                await APIs.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    //for hiding progress dialog
                    Navigator.pop(context);

                    //for moving to home screen
                    Navigator.pop(context);

                    APIs.auth = FirebaseAuth.instance;

                    //replacing home screen with login screen
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                    Dialogs.showSnackBar(context, """Logout Successfully""");
                  });
                });
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  // Widget _buildViewProfileButton(BuildContext context, VoidCallback? onPressed, String text) {
  //   return MaterialButton(
  //     onPressed: onPressed,
  //     color: Colors.deepOrange,
  //     textColor: Colors.white,
  //     shape:
  //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
  //     child: Text(text),
  //   );
  // }

  Future<dynamic> _showUpdateDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Update'),
          content: const Text('Are you sure you want to update your profile?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Profile Update functionality
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  APIs.updateUserInfo().then((value) {
                    Dialogs.showSnackBar(
                        context, 'Profile Updated Successfully!');
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              //pick profile picture label
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              //for adding some space
              SizedBox(height: mq.height * .02),

              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!)).then((value){
                            Dialogs.showSnackBar(context, 'Profile Update Successfully');
                          });
                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/add_image.png')),

                  //take picture from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!)).then((value){Dialogs.showSnackBar(context, 'Profile Update Successfully');
                          });

                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png')),
                ],
              )
            ],
          );
        });
  }
}
