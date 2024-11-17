import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  @override
  ChatScreenState createState() => ChatScreenState();
}

Future<void> fetchResponse(String query) async {
  final response = await http.post(
    Uri.parse('your_api_url'),
    body: {'query': query},
  );

  if (response.statusCode == 200) {
    print('Response: ${response.body}');
  } else {
    print('Error: ${response.statusCode}');
  }
}

class ChatScreenState extends State<ChatScreen> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');

  Future<String> fetchAIResponse(String query) async {
    const apiKey = '';
    final url = Uri.parse('https://api.openai.com/v1/completions');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': 'text-davinci-003',
        'prompt': query,
        'max_tokens': 100,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['text'].trim();
    } else {
      throw Exception('Failed to fetch response');
    }
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });

    try {
      final response = await fetchAIResponse(message.text);
      final botMessage = types.TextMessage(
        author: const types.User(id: 'bot'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: 'bot-${DateTime.now().millisecondsSinceEpoch}',
        text: response,
      );

      setState(() {
        _messages.insert(0, botMessage);
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
      ),
    );
  }
}
