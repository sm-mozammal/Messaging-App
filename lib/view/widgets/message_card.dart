import 'dart:developer';
import 'package:blog_app/Utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:gallery_saver/gallery_saver.dart';
import '../../Services/api.dart';
import '../../helper/my_date_util.dart';
import '../../model/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({Key? key, required this.message}) : super(key: key);

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  late Size mq;

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    bool isMe = APIs.user.uid == widget.message.fromId;

    return InkWell(
      onLongPress: () {
        if (!mounted) return;

        // Close the keyboard
        FocusManager.instance.primaryFocus?.unfocus();

        if (mounted) {
          showBottomSheet(context, isMe, widget.message, mq);
        }
      },
      child: isMe ? _orangeMessage() : _blueMessage(),
    );
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 221, 245, 255),
              border: Border.all(color: Colors.lightBlue),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: widget.message.type == Type.text
                ? Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            )
                : FullScreenWidget(
              disposeLevel: DisposeLevel.High,
              child: Hero(
                tag: widget.message.read,
                child: InteractiveViewer(
                  maxScale: 5,
                  minScale: 0.1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.image, size: 70),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _orangeMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width * .04),
            if (widget.message.read.isNotEmpty)
              const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),
            const SizedBox(width: 2),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
              color: const Color(0xffFFDAB9),
              border: Border.all(color: const Color(0xffFFC68C)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: widget.message.type == Type.text
                ? Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            )

            // Full Image View
                : FullScreenWidget(
              disposeLevel: DisposeLevel.High,
              child: Hero(
                tag: widget.message.sent,
                child: InteractiveViewer(
                  maxScale: 5,
                  minScale: 0.1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.image, size: 70),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom option item widget for actions like copy, edit, delete, etc.
class OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  // Constructor for OptionItem
  const OptionItem({
    super.key,
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Getting the screen size
    final Size mq = MediaQuery.of(context).size;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: mq.width * 0.05,
          top: mq.height * 0.015,
          bottom: mq.height * 0.015,
        ),
        child: Row(
          children: [
            // Icon for the option
            icon,

            // Flexible container for text to allow wrapping
            Flexible(
              child: Text(
                '    $name', // Option name
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showMessageUpdateDialog(BuildContext context, Message message) {
  String updatedMsg = message.msg;

  // Ensure that the bottom sheet is closed before showing the dialog
  Navigator.pop(context);

  showDialog(
    context: context,
    builder: (context) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: AlertDialog(
          contentPadding:
          const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.message, color: Colors.blue, size: 28),
              Text(' Update Message'),
            ],
          ),
          content: TextFormField(
            initialValue: updatedMsg,
            maxLines: null,
            onChanged: (value) {
              updatedMsg = value.trim();
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                Navigator.pop(context);
                await APIs.updateMessage(message, updatedMsg);
              },
              child: const Text(
                'Update',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showBottomSheet(
    BuildContext context, bool isMe, Message message, Size mq) {
  // Hide/ collapse the keyboard
  FocusScope.of(context).unfocus();

  showModalBottomSheet(
    context: context,
    // context: widget.scaffoldState.currentState!.context!,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return ListView(
        shrinkWrap: true,
        children: [
          Container(
            height: 4,
            margin: EdgeInsets.symmetric(
                vertical: mq.height * .015, horizontal: mq.width * .4),
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(8)),
          ),
          message.type == Type.text
              ? OptionItem(
            icon: const Icon(Icons.copy_all_rounded,
                color: Colors.blue, size: 26),
            name: 'Copy Text',
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: message.msg))
                  .then((value) {
                Navigator.pop(context);
                Utils.showSnackbar(context, 'Text Copied!');
              });
            },
          )
              : OptionItem(
            icon: const Icon(Icons.download_rounded,
                color: Colors.blue, size: 26),
            name: 'Save Image',
            onTap: () async {
              try {
                await GallerySaver.saveImage(message.msg,
                    albumName: 'We Chat')
                    .then((success) {
                  Navigator.pop(context);
                  if (success != null && success) {
                    Utils.showSnackbar(
                        context, 'Image Successfully Saved!');
                  }
                });
              } catch (e) {
                log('ErrorWhileSavingImg: $e');
              }
            },
          ),
          if (isMe)
            Divider(
              color: Colors.black54,
              endIndent: mq.width * .04,
              indent: mq.width * .04,
            ),
          if (message.type == Type.text && isMe)
            OptionItem(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
              name: 'Edit Message',
              onTap: () {
                showMessageUpdateDialog(context, message);
              },
            ),
          if (isMe)
            OptionItem(
              icon:
              const Icon(Icons.delete_forever, color: Colors.red, size: 26),
              name: 'Delete Message',
              onTap: () async {
                await APIs.deleteMessage(message).then((value) {
                  Navigator.pop(context);
                });
              },
            ),
          Divider(
              color: Colors.black54,
              endIndent: mq.width * .04,
              indent: mq.width * .04),
          OptionItem(
            icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
            name:
            'Sent At: ${MyDateUtil.getMessageTime(context: context, time: message.sent)}',
            onTap: () {},
          ),
          OptionItem(
            icon: const Icon(Icons.remove_red_eye, color: Colors.green),
            name: message.read.isEmpty
                ? 'Read At: Not seen yet'
                : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: message.read)}',
            onTap: () {},
          ),
        ],
      );
    },
  );
}
