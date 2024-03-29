import 'dart:developer';
import 'dart:io';
import 'package:blog_app/view/widgets/message_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/api.dart';
import '../Utils/utils.dart';
import '../helper/my_date_util.dart';
import '../model/chat_user.dart';
import '../model/message.dart';
import 'view_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Size mq = MediaQuery.of(context).size;

  //for storing all messages
  List<Message> _list = [];

  //for handling message text changes
  final _textController = TextEditingController();

  //showEmoji -- for storing value of showing or hiding emoji
  //isUploading -- for checking if image is uploading or not?
  bool _showEmoji = false, _isUploading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //if emojis are shown & back button is pressed then hide emojis
          //or else simple close current screen on back button click
          onWillPop: () {
            if (_showEmoji) {
              setState(() => _showEmoji = !_showEmoji);
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            //app bar
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),

            backgroundColor: const Color.fromARGB(255, 234, 248, 255),

            body: Column(
              children: [
                Expanded(child: _buildMessagesStreamBuilder()),
                if (_isUploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                _buildChatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // app bar widget
  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              return Row(
                children: [
                  //back button
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                          const Icon(Icons.arrow_back, color: Colors.black54)),

                  //user profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      width: mq.height * .05,
                      height: mq.height * .05,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          backgroundImage: AssetImage('images/profile.png')),
                    ),
                  ),

                  //for adding some space
                  const SizedBox(width: 10),

                  //user name & last seen time
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //user name
                      Row(
                        children: [
                          Text(
                              list.isNotEmpty ? list[0].name : widget.user.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500)),

                          SizedBox(width: mq.width * .03),
                          //user online status
                          widget.user.isOnline
                              ? Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                      color: Colors.greenAccent.shade400,
                                      borderRadius: BorderRadius.circular(10)),
                                )
                              : SizedBox(),
                        ],
                      ),

                      //for adding some space
                      const SizedBox(height: 2),

                      //last seen time of user
                      Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                                  ? 'Online'
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive)
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: widget.user.lastActive),
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54)),
                    ],
                  )
                ],
              );
            }));
  }


  Future<bool> _handleBackButton() async {
    if (_showEmoji) {
      setState(() => _showEmoji = !_showEmoji);
      return false;
    } else {
      return true;
    }
  }

  Widget _buildAppBar() {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ViewProfileScreen(user: widget.user))),
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return Row(
            children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black54)),

              // Profile Picture
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .03),
                child: CachedNetworkImage(
                  width: mq.height * .05,
                  height: mq.height * .05,
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                  errorWidget: (context, url, error) => CircleAvatar(
                      child: Image.asset("images/default_male_avatar.png")),
                ),
              ),
              const SizedBox(width: 10),

              // Name & Status Column
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),

                  // Active/ In-Active Status
                  Text(
                    list.isNotEmpty
                        ? (list[0].isOnline
                        ? 'Online'
                        : MyDateUtil.getLastActiveTime(
                        context: context,
                        lastActive: list[0].lastActive))
                        : MyDateUtil.getLastActiveTime(
                        context: context,
                        lastActive: widget.user.lastActive),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessagesStreamBuilder() {
    return StreamBuilder(
      stream: APIs.getAllMessages(widget.user),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const SizedBox();
          case ConnectionState.active:
          case ConnectionState.done:
            final data = snapshot.data?.docs;
            _list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

            if (_list.isNotEmpty) {
              return ListView.builder(
                reverse: true,
                itemCount: _list.length,
                padding: EdgeInsets.only(top: mq.height * .01),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return MessageCard(message: _list[index]);
                },
              );
            } else {
              return const Center(
                child: Text('Say Hii! 👋', style: TextStyle(fontSize: 20)),
              );
            }
        }
      },
    );
  }

  Widget _buildChatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(Icons.emoji_emotions,
                        color: Colors.deepOrangeAccent, size: 25),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji) {
                          setState(() => _showEmoji = !_showEmoji);
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: Colors.deepOrangeAccent),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _pickImagesFromGallery,
                    icon: Icon(Icons.image,
                        color: Colors.deepOrangeAccent, size: mq.height * .035),
                  ),
                  IconButton(
                    onPressed: _takeImageFromCamera,
                    icon: Icon(Icons.camera_alt_rounded,
                        color: Colors.deepOrangeAccent, size: mq.height * .035),
                  ),
                  SizedBox(width: mq.width * .02),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: _sendMessage,
            minWidth: 0,
            padding:
            const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.deepOrangeAccent,
            child:
            Icon(Icons.send, color: Colors.white, size: mq.height * .035),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImagesFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 30);

    for (var i in images) {
      log('Image Path: ${i.path}');
      setState(() => _isUploading = true);
      await APIs.sendChatImage(widget.user, File(i.path));
      setState(() => _isUploading = false);
    }
  }

  Future<void> _takeImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
    await picker.pickImage(source: ImageSource.camera, imageQuality: 70);

    if (image != null) {
      log('Image Path: ${image.path}');
      setState(() => _isUploading = true);
      await APIs.sendChatImage(widget.user, File(image.path));
      setState(() => _isUploading = false);
    }
  }

  void _sendMessage() {
    final trimmedMessage = _textController.text.trim();
    if (trimmedMessage.isNotEmpty) {
      if (_list.isEmpty) {
        APIs.sendFirstMessage(widget.user, trimmedMessage, Type.text);
      } else {
        APIs.sendMessage(widget.user, trimmedMessage, Type.text);
      }
      _textController.text = '';
    } else {
      Utils.showSnackbar(context, "Oops, Cannot send an empty message!");
    }
  }
}