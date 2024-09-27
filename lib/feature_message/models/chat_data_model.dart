import 'package:farmshield/feature_message/models/message_model.dart';
import 'package:farmshield/feature_message/models/user_data.dart';


class ChatDataModel {
  final MessageModel message;
  final List<UserData> users;

  ChatDataModel({required this.message, required this.users});
}
