import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helper/my_date_util.dart';
import '../model/chat_user.dart';

//view profile screen -- to view profile of user
class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  late Size mq = MediaQuery.of(context).size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          //app bar
          appBar: AppBar(title: Text(widget.user.name)),
          floatingActionButton: //user about
              _floatingActionButton(context),

          //body
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // for adding some space
                  SizedBox(width: mq.width, height: mq.height * .03),

                  //user profile picture
                  _userProfileImage(),

                  SizedBox(height: mq.height * .02),

                  //User online status or showing last see time
                  _onlineStatus(context),

                  SizedBox(height: mq.height * .02),

                  //User Name

                  Text(widget.user.name,
                      style: const TextStyle(
                          color: Colors.black, fontSize: 24)),

                  // for adding some space
                  SizedBox(height: mq.height * .01),

                  // user email label
                  Text(widget.user.email,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 18)),


                  // for adding some space
                  SizedBox(height: mq.height * .03),

                  // user about
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'About: ',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                      Text(widget.user.about,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Row _onlineStatus(BuildContext context) {
    return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.user.isOnline ? Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                          color:   Colors.greenAccent.shade400 ,
                          borderRadius: BorderRadius.circular(10)),
                    ) : SizedBox(),

                    SizedBox(width: mq.width * .03),
                    Text(
                        widget.user.isOnline
                            ? 'Online'
                            : MyDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive),
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                  ],
                );
  }

  ClipRRect _userProfileImage() {
    return ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
                  child: CachedNetworkImage(
                    width: mq.height * .2,
                    height: mq.height * .2,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(
                        backgroundImage: AssetImage('images/profile.png')),
                  ),
                );
  }

  Row _floatingActionButton(BuildContext context) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Joined On: ',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
            Text(
                MyDateUtil.getLastMessageTime(
                    context: context,
                    time: widget.user.createdAt,
                    showYear: true),
                style: const TextStyle(color: Colors.black54, fontSize: 15)),
          ],
        );
  }
}
