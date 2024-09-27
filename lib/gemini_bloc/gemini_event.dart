part of 'gemini_bloc.dart';

@immutable

sealed class GeminiEvent {}

final class GeminiSubmit extends GeminiEvent{
  final String text;

  GeminiSubmit({required this.text});
}