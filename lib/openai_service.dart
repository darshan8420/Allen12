import 'dart:convert';
import 'package:allen12/secrets.dart';
import 'package:http/http.dart' as http;


enum MessageRole { user, content, assistant }

class OpenAIService {
  final List<Map<String, String>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAPIServiceKey'
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              'role': MessageRole.user.toString(),
              'content':
              'Does this message want to generate an AI picture, image, art or anything similar? $prompt . Simply answer with a yes or no.',
            }
          ],
        }),
      );

      if (res.statusCode == 200) {
        String content =
        jsonDecode(res.body)['choices'][0]['message']['content'].trim();
        return content.toLowerCase() == 'yes' ? await dallEAPI(prompt) : await chatGPTAPI(prompt);
      }
      return 'AI';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({'role': MessageRole.content.toString(), 'content': prompt});

    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAPIServiceKey'
        },
        body: jsonEncode({"model": "gpt-3.5-turbo", "messages": messages}),
      );

      if (res.statusCode == 200) {
        String content = jsonDecode(res.body)['choices'][0]['message']['content'].trim();
        messages.add({'role': MessageRole.assistant.toString(), 'content': content});
        return content;
      }
      return 'AI';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({'role': MessageRole.content.toString(), 'content': prompt});

    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAPIServiceKey'
        },
        body: jsonEncode({"prompt": prompt, 'n': 1}),
      );

      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'].trim();
        messages.add({'role': MessageRole.assistant.toString(), 'content': imageUrl});
        return imageUrl;
      }
      return 'AI';
    } catch (e) {
      return e.toString();
    }
  }
}
