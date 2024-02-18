import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../model/chat_user.dart';
import '../../view_profile_screen.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({Key? key, required this.user}) : super(key: key);

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        width: mq.width * 0.6,
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUserProfile(user, mq),
            SizedBox(height: mq.height * .015),
            _buildUserInfo(user),
            SizedBox(height: mq.height * .015),
            _buildViewProfileButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(ChatUser user, Size mq) {
    return Stack(
      children: [
        _buildProfilePicture(user),
        if (user.isOnline) _buildOnlineIndicator(mq),
      ],
    );
  }

  Widget _buildProfilePicture(ChatUser user) {
    return CircleAvatar(
      radius: 60.0,
      backgroundColor: Colors.grey, // Add a background color if needed
      backgroundImage: _getUserImage(user),
    );
  }

  ImageProvider<Object> _getUserImage(ChatUser user) {
    if (user.image != "null") {
      return CachedNetworkImageProvider(user.image);
    } else {
      return const AssetImage("images/default_male_avatar.png");
    }
  }

  Widget _buildOnlineIndicator(Size mq) {
    return Positioned(
      bottom: mq.height * .01,
      right: mq.height * .01,
      child: Container(
        width: 18.0,
        height: 18.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
          border: Border.all(color: Colors.white, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildUserInfo(ChatUser user) {
    return Column(
      children: [
        Text(
          user.name,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4.0),
        Text(
          user.email,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _buildViewProfileButton(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        // Close the dialog
        Navigator.pop(context);

        // Navigate to view profile screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ViewProfileScreen(user: user)),
        );
      },
      color: Colors.deepOrange,
      textColor: Colors.white,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: const Text('View Profile'),
    );
  }
}
