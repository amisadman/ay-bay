import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/transaction_model.dart';
import '../models/loan_model.dart';

class AIServiceResponse {
  final String textResponse;
  final bool isActionExecuted;
  final String? actionType;
  final Map<String, dynamic>? actionData;

  AIServiceResponse({
    required this.textResponse,
    this.isActionExecuted = false,
    this.actionType,
    this.actionData,
  });
}

class AIService {
  static Future<AIServiceResponse> queryWalleo({
    required String userPrompt,
    required double totalIncome,
    required double totalExpense,
    required double netBalance,
    required double totalLoan,
    required double totalOwe,
    required List<TransactionModel> recentTransactions,
    required List<LoanModel> activeLoans,
    required String langCode,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    final promptLower = userPrompt.toLowerCase().trim();

    final parseResult = _parseQuickAction(promptLower, userPrompt);
    if (parseResult != null) {
      return parseResult;
    }

    if (apiKey.isEmpty) {
      return AIServiceResponse(
        textResponse: langCode == 'bn'
            ? 'Gemini API Key সেট করা হয়নি। দয়া করে সেটিংস থেকে API Key যুক্ত করুন।'
            : 'Gemini API Key is not configured. Please add your key in Settings.',
      );
    }

    try {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=' + apiKey);

      final systemContext = '''
You are Walleo, an intelligent AI financial assistant for the app AyBay.
Language preference: ${langCode == 'bn' ? 'Bengali' : 'English'}.
Current User Financial Summary:
- Total Income: $totalIncome
- Total Expense: $totalExpense
- Net Balance: $netBalance
- Total Loans Given: $totalLoan
- Total Owes Borrowed: $totalOwe

Instructions:
1. Provide concise, friendly financial advice or answers.
2. If user speaks Bengali, answer in Bengali. If English, answer in English.
3. Keep responses helpful and readable under 100 words.
''';

      final requestBody = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': systemContext + '\n\nUser Question: ' + userPrompt}
            ]
          }
        ]
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final replyText = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            (langCode == 'bn' ? 'দুঃখিত, কোনো উত্তর পাওয়া যায়নি।' : 'Sorry, no response generated.');

        return AIServiceResponse(textResponse: replyText);
      } else {
        return AIServiceResponse(
          textResponse: langCode == 'bn'
              ? 'এআই সংযোগে সমস্যা হয়েছে (Error ${response.statusCode})'
              : 'AI service request failed (Error ${response.statusCode})',
        );
      }
    } catch (e) {
      return AIServiceResponse(
        textResponse: langCode == 'bn'
            ? 'ত্রুটি: $e'
            : 'Error connecting to Walleo AI: $e',
      );
    }
  }

  static AIServiceResponse? _parseQuickAction(String promptLower, String rawPrompt) {
    final nowStr = DateTime.now().toIso8601String().split('T')[0];

    final numMatch = RegExp(r'(\d+(\.\d+)?)').firstMatch(promptLower);
    final amount = numMatch != null ? double.parse(numMatch.group(1)!) : 0.0;

    if ((promptLower.contains('expense') || promptLower.contains('খরচ')) && amount > 0) {
      String title = rawPrompt.replaceAll(RegExp(r'\d+'), '').replaceAll(RegExp(r'(add|expense|taka|bdt|খরচ|যোগ|করো|টাকা)'), '').trim();
      if (title.isEmpty) title = 'Quick Expense';

      return AIServiceResponse(
        textResponse: 'Expense of ৳' + amount.toString() + ' (' + title + ') recorded successfully!',
        isActionExecuted: true,
        actionType: 'add_expense',
        actionData: {
          'title': title,
          'amount': amount,
          'type': 'expense',
          'category': 'cat_other',
          'date': nowStr,
          'note': 'Added via Walleo AI Chat',
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
    }

    if ((promptLower.contains('income') || promptLower.contains('আয়') || promptLower.contains('insert') || promptLower.contains('আয়')) && amount > 0) {
      String title = rawPrompt.replaceAll(RegExp(r'\d+'), '').replaceAll(RegExp(r'(add|income|taka|bdt|আয়|আয়|যোগ|করো|টাকা)'), '').trim();
      if (title.isEmpty) title = 'Quick Income';

      return AIServiceResponse(
        textResponse: 'Income of ৳' + amount.toString() + ' (' + title + ') recorded successfully!',
        isActionExecuted: true,
        actionType: 'add_income',
        actionData: {
          'title': title,
          'amount': amount,
          'type': 'income',
          'category': 'cat_other',
          'date': nowStr,
          'note': 'Added via Walleo AI Chat',
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
    }

    return null;
  }
}
