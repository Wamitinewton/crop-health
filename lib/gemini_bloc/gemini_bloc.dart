import 'package:farmshield/models/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

part 'gemini_event.dart';
part 'gemini_state.dart';

class GeminiBloc extends Bloc<GeminiEvent, GeminiState> {
  final gemini = Gemini.instance;
  final chats = <Chat>[];
  final scrollCtr = ScrollController();

  GeminiBloc() : super(GeminiInitial()) {
    on<GeminiSubmit>((event, emit) async {
      final userChat = Chat(role: 'user', output: event.text);
      chats.add(userChat);

      emit(OnDataReceived(chat: userChat));

      try {
        final response = await gemini.text(event.text);
        if (response == null) throw Exception('cannot fetch data');

        final content = response.content;
        final chat = Chat(role: content?.role, output: response.output);
        chats.add(chat);

        emit(OnDataReceived(chat: chat));
      } catch (e) {
        emit(OnError(message: e.toString(), lastText: event.text));
      }
    });
  }
}
