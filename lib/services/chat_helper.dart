import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kkb/model/statistic.dart';
import 'package:kkb/model/budget.dart';
import 'package:kkb/model/spending_record.dart';

// 'gemini' or 'chatgpt'
const String provider = 'gemini';

const String geminiApiKey = 'AIzaSyAvr0Mb8N9u9LaLf__5hgjBrSkyk4Xhjjg';
const String openAiApiKey =
    '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';

class ChatHelper {
  static String generatePrompt(
      List<Budget> budgets, List<SpendingRecord> records) {
    String prompt =
        'You are an analyst who helps me analyze my monthly spendings and budgets and provides suggestions.\n';

    final List<Budget> filterdBudgets =
        budgets.where((budget) => budget.amount > 0).toList();

    if (filterdBudgets.isNotEmpty) {
      int totalBudget = filterdBudgets
          .firstWhere((budget) => budget.category.name == 'All')
          .amount;
      prompt += 'My total budget for this month is $totalBudget.\n';
      if (filterdBudgets.length > 1) {
        prompt += 'Here is a list of categorized budgets:\n';
        for (Budget budget in filterdBudgets) {
          if (budget.category.name != "All") {
            prompt += ' - ${budget.category.name}: ${budget.amount}\n';
          }
        }
      }
    } else {
      prompt += 'I didn\'t set any budgets for this month.\n';
    }

    if (records.isNotEmpty) {
      prompt += 'Here is a list of user\'s spendings of this month:\n';
      for (SpendingRecord record in records) {
        prompt +=
            ' - Category: ${record.category.name}, Date: ${record.dateStr('yyyy-MM-dd')}, Amount: ${record.amount}\n';
      }
    } else {
      prompt += 'I didn\'t have any spendings in this month.\n';
    }

    // The limitation of questions can be answered is set by the prompt:
    //     If the question I ask or sentence I say has nothing to do with spendings and budgets, reply \'Sorry, I\'m only able to provide service to improve your budgets and spendings. Please ask another question.\'
    // This prompt does not always work.
    prompt +=
        '**Note**: Regard None as a common category. Remember to answer every question based on the budget list and spending list I gave you. Be careful with mathematic computations. If the question I ask or sentence I say has nothing to do with spendings and budgets, reply \'Sorry, I\'m only able to provide service to improve your budgets and spendings. Please ask another question.\'';

    return prompt;
  }

  static String convertHistoryToJSONGemini(List<ChatHistoryData> history) {
    var contents = [];

    for (ChatHistoryData dataItem in history) {
      contents.add({
        'role': dataItem.fromUser ? 'user' : 'model',
        'parts': [
          {
            'text': dataItem.content,
          }
        ]
      });
    }

    var data = {'contents': contents};

    return jsonEncode(data);
  }

  static String convertHistoryToJSONChatgpt(List<ChatHistoryData> history) {
    var contents = [];

    for (ChatHistoryData dataItem in history) {
      contents.add({
        'role': dataItem.fromUser ? 'user' : 'system',
        'content': dataItem.content,
      });
    }

    var data = {'messages': contents, 'model': 'gpt-3.5-turbo'};

    return jsonEncode(data);
  }

  // TODO: add a new conversation descriptor into the database.
  // Return the id of new conversation, currently not implemented.
  // static Future<int> createNewChat() {

  // }

  // TODO: add newMsg into the database.
  // The history already contains the new message (added in frontend).
  static Future<String> chat(
    int chatId,
    String newMsg,
    List<ChatHistoryData> history,
    List<Budget> budgets,
    List<SpendingRecord> records,
  ) async {
    try {
      final String prompt = generatePrompt(budgets, records);
      final List<ChatHistoryData> chatHistory = [
        ChatHistoryData(
          chatId: chatId,
          content: prompt,
          fromUser: true,
          time: DateTime.now(),
        ),
        ChatHistoryData(
          chatId: chatId,
          content: '',
          fromUser: false,
          time: DateTime.now(),
        ),
        ...history
      ];

      if (provider == 'gemini') {
        // gemini
        final http.Response res = await http.post(
          Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$geminiApiKey'),
          headers: <String, String>{'Content-Type': 'application/json'},
          body: convertHistoryToJSONGemini(chatHistory),
        );

        final Map parsed = jsonDecode(res.body);

        return parsed['candidates'][0]['content']['parts'][0]['text'];
      } else {
        // chatgpt
        final http.Response res = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAiApiKey',
            'Api-Key': openAiApiKey,
          },
          body: convertHistoryToJSONChatgpt(chatHistory),
        );

        final Map parsed = jsonDecode(res.body);

        return parsed['choices'][0]['message']['content'];
      }
    } catch (e) {
      // There are some sensitive questions that the model can't give a response.
      return 'Sorry, I can\'t answer this question. Please ask another one or try again.';
    }
  }
}
