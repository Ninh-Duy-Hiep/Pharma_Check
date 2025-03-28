import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final chatProvider = StateNotifierProvider<ChatNotifier, List<Message>>(
    (ref) => ChatNotifier());

class ChatNotifier extends StateNotifier<List<Message>> {
  ChatNotifier() : super([]);

  void resetChatHistory() {
    state = [];
    print("🔄 Lịch sử chat đã được reset khi mở màn hình.");
  }

  Future<void> sendMessage(String text) async {
    state = [...state, Message(text: text, isUser: true)];

    final response = await http.get(Uri.parse(
        'http://192.168.10.152:8000/chatbot/?question=${Uri.encodeComponent(text)}'));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      state = [...state, Message(text: data['answer'], isUser: false)];
    } else {
      state = [...state, Message(text: 'Lỗi khi nhận phản hồi!', isUser: false)];
    }
  }
}


class Message {
  final String text;
  final bool isUser;
  Message({required this.text, required this.isUser});
}
