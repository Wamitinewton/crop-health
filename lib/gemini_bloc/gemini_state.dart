part of 'gemini_bloc.dart';

@immutable
sealed class GeminiState {}

final class GeminiInitial extends GeminiState {}

final class OnLoading extends GeminiState {}

final class OnDataReceived extends GeminiState {
  final Chat chat;

  OnDataReceived({required this.chat});
}

final class OnError extends GeminiState {
  final String message;
  final String lastText;

  OnError({required this.message, required this.lastText});
}
