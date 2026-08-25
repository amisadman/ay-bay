import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/models/transaction_model.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String text;
  final bool isUser;
  final Uint8List? imageBytes;
  ChatMessage({required this.text, required this.isUser, this.imageBytes});
}

class AIProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isThinking = false;

  // Keep track of OpenAI message history
  final List<Map<String, dynamic>> _chatHistory = [];

  List<ChatMessage> get messages => _messages;
  bool get isThinking => _isThinking;

  final String _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';

  void initializeModel() {
    _chatHistory.clear();
    _chatHistory.add({
      'role': 'system',
      'content': 'You are Walleo, an advanced, highly intelligent Agentic AI financial assistant embedded in the AyBay app. '
          'You speak to the user in a friendly, concise tone. You can understand Bengali and English natively. '
          'If a user tells you they spent money or got income, you MUST call the add_transaction tool to save it. '
          'If the user provides an image of a receipt, bill, or ticket, gently remind them that your vision capabilities are temporarily offline, but they can type the amount manually.'
          'If a user asks about their spending, how to save money, what their month/year looks like, or any analytics question, you MUST call the analyze_spending tool to get their raw transaction data. '
          'When you receive the data from analyze_spending, you MUST look at the dates and categories, filter them according to the user\'s question, and provide a final text response with a personalized, detailed summary. '
          'Never hallucinate data. Only rely on the tool responses.'
    });
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> sendMessage(String text, FinanceProvider financeProvider,
      {Uint8List? imageBytes}) async {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      addMessage(ChatMessage(
          text: 'Error: GROQ_API_KEY is missing in .env', isUser: false));
      return;
    }

    if (_chatHistory.isEmpty) {
      initializeModel();
    }

    addMessage(ChatMessage(text: text, isUser: true, imageBytes: imageBytes));
    _isThinking = true;
    notifyListeners();

    _chatHistory.add({
      'role': 'user',
      'content': text.isNotEmpty
          ? text
          : 'Please analyze this receipt and log the expense.',
    });

    if (imageBytes != null) {
      // Add a system prompt injecting the limitation gracefully for the LLM
      _chatHistory.add({
        'role': 'system',
        'content':
            'System note: The user has attached an image. Remember that you currently cannot see images. Politely ask them to type the amount/details.',
      });
    }

    await _callGroqApi(apiKey, financeProvider);
  }

  Future<void> _callGroqApi(
      String apiKey, FinanceProvider financeProvider) async {
    try {
      final response = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'openai/gpt-oss-120b',
          'messages': _chatHistory,
          'tools': _getTools(),
          'tool_choice': 'auto',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choice = data['choices'][0]['message'];

        _chatHistory.add(
            choice); // Append assistant's raw message containing tool_calls

        if (choice['tool_calls'] != null) {
          // Handle tool calls
          for (final toolCall in choice['tool_calls']) {
            final functionCall = toolCall['function'];
            final name = functionCall['name'];
            final args = jsonDecode(functionCall['arguments']);

            String toolResult = '';

            if (name == 'add_transaction') {
              final amount = (args['amount'] as num).toDouble();
              final type = args['type'] as String;
              final category = args['category'] as String;
              final note = args['note'] as String;

              final tx = TransactionModel(
                title: note,
                amount: amount,
                type: type,
                category: category,
                date: DateTime.now().toIso8601String().split('T')[0],
                createdAt: DateTime.now().toIso8601String(),
              );

              await financeProvider.addTransaction(tx);


              toolResult = jsonEncode({
                'status': 'Success',
                'message': 'Transaction added: $note ($amount)'
              });
            } else if (name == 'analyze_spending') {
              final allTx = financeProvider.transactions;
              final recentTx = allTx
                  .take(500)
                  .map((t) =>
                      '${t.date}: ${t.type} - ${t.amount} (${t.category}) - ${t.title}')
                  .toList();

              toolResult = jsonEncode({
                'status': 'Success',
                'summary_data': {
                  'total_income': financeProvider.totalIncome,
                  'total_expense': financeProvider.totalExpense,
                  'current_balance': financeProvider.netBalance,
                  'recent_transactions': recentTx,
                }
              });
            }

            // Append tool response
            _chatHistory.add({
              'role': 'tool',
              'tool_call_id': toolCall['id'],
              'name': name,
              'content': toolResult,
            });
          }

          // Follow up call to get final response
          await _callGroqApi(apiKey, financeProvider);
        } else if (choice['content'] != null) {
          addMessage(ChatMessage(text: choice['content'], isUser: false));
          _isThinking = false;
          notifyListeners();
        }
      } else {
        _handleApiError(response.body);
      }
    } catch (e) {
      _handleApiError(e.toString());
    }
  }

  void _handleApiError(String error) {
    debugPrint('Groq API Error: $error');
    String errorMessage = 'Error: $error';
    if (error.contains('503') || error.contains('UNAVAILABLE')) {
      errorMessage =
          'Walleo is currently experiencing high demand. Please try again in a few moments.';
    }
    addMessage(ChatMessage(text: errorMessage, isUser: false));
    _isThinking = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> _getTools() {
    return [
      {
        'type': 'function',
        'function': {
          'name': 'add_transaction',
          'description':
              'Add a new financial transaction (income or expense) based on user input.',
          'parameters': {
            'type': 'object',
            'properties': {
              'amount': {
                'type': 'number',
                'description': 'The transaction amount.'
              },
              'type': {
                'type': 'string',
                'description': 'Either "income" or "expense"'
              },
              'category': {
                'type': 'string',
                'description':
                    'Category of the transaction e.g., Food, Salary, Vacation'
              },
              'note': {
                'type': 'string',
                'description': 'A brief note or reason for the transaction.'
              },
            },
            'required': ['amount', 'type', 'category', 'note'],
          },
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'analyze_spending',
          'description':
              'Analyzes user spending patterns, identifies unnecessary expenses, and gives a financial summary for a specific period.',
          'parameters': {
            'type': 'object',
            'properties': {
              'period': {
                'type': 'string',
                'description':
                    'The time period to analyze, e.g., "month", "year", "today"'
              },
            },
            'required': ['period'],
          },
        }
      }
    ];
  }
}
