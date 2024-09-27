import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:farmshield/feature_message/constants/chat_message.dart';
import 'package:farmshield/feature_message/constants/colors.dart';
import 'package:farmshield/feature_message/controllers/appwrite_controllers.dart';
import 'package:farmshield/feature_message/models/message_model.dart';
import 'package:farmshield/feature_message/models/user_data.dart';
import 'package:farmshield/feature_message/providers/chat_provider.dart';
import 'package:farmshield/feature_message/providers/user_data_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  TextEditingController editmessageController = TextEditingController();

  late String currentUserId;
  late String currentUserName;

  FilePickerResult? _filePickerResult;

 

  @override
  void initState() {
    currentUserId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    currentUserName =
        Provider.of<UserDataProvider>(context, listen: false).getUserName;

    Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserId);
    super.initState();
  }

  // to open file picker
  void _openFilePicker(UserData receiver) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    setState(() {
      _filePickerResult = result;
      uploadAllImage(receiver);
    });
  }

  // to upload files to our storage bucket and our database
  void uploadAllImage(UserData receiver) async {
    if (_filePickerResult != null) {
      _filePickerResult!.paths.forEach((path) {
        if (path != null) {
          var file = File(path);
          final fileBytes = file.readAsBytesSync();
          final inputfile = InputFile.fromBytes(
              bytes: fileBytes, filename: file.path.split("/").last);

          // saving image to our storage bucket
          saveImageToBucket(image: inputfile).then((imageId) {
            if (imageId != null) {
              createNewChat(
                message: imageId,
                senderId: currentUserId,
                receiverId: receiver.userId,
                isImage: true,
              ).then((value) {
                if (value) {
                  Provider.of<ChatProvider>(context, listen: false).addMessage(
                      MessageModel(
                        message: imageId,
                        sender: currentUserId,
                        receiver: receiver.userId,
                        timestamp: DateTime.now(),
                        isSeenByReceiver: false,
                        isImage: true,
                      ),
                      currentUserId,
                      [UserData(phone: "", userId: currentUserId), receiver]);
                  sendNotificationtoOtherUser(
                      notificationTitle: '$currentUserName sent you an image',
                      notificationBody: "check it out.",
                      deviceToken: receiver.deviceToken!);
                }
              });
            }
          });
        }
      });
    } else {
      print("file pick cancelled by user");
    }
  }

// to send simple text message
  void _sendMessage({required UserData receiver}) {
    if (messageController.text.isNotEmpty) {
      setState(() {
        createNewChat(
                message: messageController.text,
                senderId: currentUserId,
                receiverId: receiver.userId,
                isImage: false)
            .then((value) {
          if (value) {
            Provider.of<ChatProvider>(context, listen: false).addMessage(
                MessageModel(
                    message: messageController.text,
                    sender: currentUserId,
                    receiver: receiver.userId,
                    timestamp: DateTime.now(),
                    isSeenByReceiver: false),
                currentUserId,
                [UserData(phone: "", userId: currentUserId), receiver]);
            sendNotificationtoOtherUser(
                notificationTitle: '$currentUserName sent you a message',
                notificationBody: messageController.text,
                deviceToken: receiver.deviceToken!);
            messageController.clear();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    UserData receiver = ModalRoute.of(context)!.settings.arguments as UserData;
    return Consumer<ChatProvider>(
      builder: (context, value, child) {
        final userAndOtherChats = value.getAllChats[receiver.userId] ?? [];

        bool? otherUserOnline = userAndOtherChats.isNotEmpty
            ? userAndOtherChats[0].users[0].userId == receiver.userId
                ? userAndOtherChats[0].users[0].isOnline
                : userAndOtherChats[0].users[1].isOnline
            : false;

        List<String> receiverMsgList = [];

        for (var chat in userAndOtherChats) {
          if (chat.message.receiver == currentUserId) {
            if (chat.message.isSeenByReceiver == false) {
              receiverMsgList.add(chat.message.messageId!);
            }
          }
        }
        updateIsSeen(chatsIds: receiverMsgList);
        return Scaffold(
          backgroundColor: kBackgroundColor,
          appBar: AppBar(
            backgroundColor: kBackgroundColor,
            leadingWidth: 40,
            scrolledUnderElevation: 0,
            elevation: 0,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: receiver.profilePic == "" ||
                          receiver.profilePic == null
                      ? const Image(
                          image: AssetImage("assets/user.png"),
                        ).image
                      : CachedNetworkImageProvider(
                          "https://cloud.appwrite.io/v1/storage/buckets/66ed4154003a4065ef76/files/${receiver.profilePic}/view?project=66ed2752001a89f99303&mode=admin"),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiver.name!,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      otherUserOnline == true ? "Online" : "Offline",
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: ListView.builder(
                      reverse: true,
                      itemCount: userAndOtherChats.length,
                      itemBuilder: (context, index) {
                        final msg = userAndOtherChats[
                                userAndOtherChats.length - 1 - index]
                            .message;
                        print("user chats : ${userAndOtherChats.length}");
                        return GestureDetector(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: msg.isImage == true
                                    ? Text(msg.sender == currentUserId
                                        ? "Chosse what you want to do with this image."
                                        : "This image cant be modified")
                                    : Text(
                                        "${msg.message.length > 20 ? msg.message.substring(0, 20) : msg.message} ..."),
                                content: msg.isImage == true
                                    ? Text(msg.sender == currentUserId
                                        ? 'Delete this image'
                                        : 'This image cant be delted')
                                    : Text(msg.sender == currentUserId
                                        ? 'Chosse what you want to do with this message.'
                                        : 'This message cant be modified'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Cancel")),
                                  msg.sender == currentUserId
                                      ? TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            editmessageController.text =
                                                msg.message;

                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: const Text(
                                                          "Edit this message"),
                                                      content: TextFormField(
                                                        controller:
                                                            editmessageController,
                                                        maxLines: 10,
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              editChat(
                                                                chatId: msg
                                                                    .messageId!,
                                                                message:
                                                                    editmessageController
                                                                        .text,
                                                              );
                                                              Navigator.pop(
                                                                  context);
                                                              editmessageController
                                                                  .text = "";
                                                            },
                                                            child: const Text("Ok")),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child:
                                                                const Text("Cancel")),
                                                      ],
                                                    ));
                                          },
                                          child: const Text("Edit"))
                                      : const SizedBox(),
                                  msg.sender == currentUserId
                                      ? TextButton(
                                          onPressed: () {
                                            Provider.of<ChatProvider>(context,
                                                    listen: false)
                                                .deleteMessage(
                                                    msg, currentUserId);

                                            Navigator.pop(context);
                                          },
                                          child: const Text("Delete"))
                                      : const SizedBox(),
                                ],
                              ),
                            );
                          },
                          child: ChatMessage(
                            isImage: msg.isImage ?? false,
                            msg: msg,
                            currentUser: currentUserId,
                          ),
                        );
                      }),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: kSecondaryColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      onSubmitted: (value) {
                        _sendMessage(receiver: receiver);
                      },
                      controller: messageController,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message ..."),
                    )),
                    IconButton(
                        onPressed: () {
                          _openFilePicker(receiver);
                        },
                        icon: const Icon(Icons.image)),
                    IconButton(
                        onPressed: () {
                          _sendMessage(receiver: receiver);
                        },
                        icon: const Icon(Icons.send)),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
