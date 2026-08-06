import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/models/transaction_model.dart';
import 'package:intl/intl.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class AIProvider extends ChangeNotifier {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  final List<ChatMessage> _messages = [];
  bool _isThinking = false;

  List<ChatMessage> get messages => _messages;
  bool get isThinking => _isThinking;

  Future<void> initializeModel() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('Gemini API Key is missing');
      return;
    }

    final addTransactionTool = Tool(
      functionDeclarations: [
        FunctionDeclaration(
          'add_transaction',
          'Add a new financial transaction (income or expense) based on user input.',
          Schema(
            SchemaType.object,
            properties: {
              'amount': Schema(SchemaType.number,
                  description: 'The transaction amount.'),
              'type': Schema(SchemaType.string,
                  description: 'Either "income" or "expense"'),
              'category': Schema(SchemaType.string,
                  description:
                      'Category of the transaction e.g., Food, Salary, Vacation'),
              'note': Schema(SchemaType.string,
                  description: 'A brief note or reason for the transaction.'),
            },
            requiredProperties: ['amount', 'type', 'category', 'note'],
          ),
        ),
        FunctionDeclaration(
          'analyze_spending',
          'Analyzes user spending patterns, identifies unnecessary expenses, and gives a financial summary for a specific period.',
          Schema(
            SchemaType.object,
            properties: {
              'period': Schema(SchemaType.string,
                  description:
                      'The time period to analyze, e.g., "month", "year", "today"'),
            },
            requiredProperties: ['period'],
          ),
        ),
      ],
    );

    _model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
      tools: [addTransactionTool],
      systemInstruction: Content.system(
          'You are Walleo, an advanced, highly intelligent Agentic AI financial assistant embedded in the AyBay app. '
          'You speak to the user in a friendly, concise tone. You can understand Bengali and English natively. '
          'If a user tells you they spent money or got income, you MUST call the add_transaction tool to save it. '
          'If a user asks about their spending, how to save money, or what their month looks like, you MUST call the analyze_spending tool to get their raw data, then give them a personalized summary and point out unnecessary spending. '
          'Never hallucinate data. Only rely on the tool responses.'),
    );

    _chatSession = _model!.startChat();
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> sendMessage(String text, FinanceProvider financeProvider) async {
    if (_chatSession == null) {
      await initializeModel();
      if (_chatSession == null) {
        addMessage(ChatMessage(
            text: 'Error: Gemini API Key not configured properly.',
            isUser: false));
        return;
      }
    }

    addMessage(ChatMessage(text: text, isUser: true));
    _isThinking = true;
    notifyListeners();

    try {
      final response = await _chatSession!.sendMessage(Content.text(text));
      await _handleResponse(response, financeProvider);
    } catch (e) {
      debugPrint('Error communicating with Gemini: $e');
      addMessage(ChatMessage(text: 'Error: $e', isUser: false));
      _isThinking = false;
      notifyListeners();
    }
  }

  Future<void> _handleResponse(
      GenerateContentResponse response, FinanceProvider financeProvider) async {
    if (response.functionCalls.isNotEmpty) {
      final functionResponses = <FunctionResponse>[];

      for (final functionCall in response.functionCalls) {
        if (functionCall.name == 'add_transaction') {
          final args = functionCall.args;
          final amount = (args['amount'] as num).toDouble();
          final type = args['type'] as String;
          final category = args['category'] as String;
          final note = args['note'] as String;

          // Execute action via FinanceProvider
          final tx = TransactionModel(
            title: note,
            amount: amount,
            type: type,
            category: category,
            date: DateTime.now().toIso8601String().split('T')[0],
            createdAt: DateTime.now().toIso8601String(),
          );

          await financeProvider.addTransaction(tx);

          functionResponses.add(FunctionResponse(functionCall.name, {
            'status': 'Success',
            'message': 'Transaction added: $note ($amount)'
          }));
        } else if (functionCall.name == 'analyze_spending') {
          final period = functionCall.args['period'] as String;

          // Get data from FinanceProvider
          final allTx = financeProvider.transactions;
          // Simple dump of recent transactions for the AI to analyze
          // In a real scenario, filter by the requested period
          final recentTx = allTx
              .take(50)
              .map((t) =>
                  '${t.date}: ${t.type} - ${t.amount} (${t.category}) - ${t.title}')
              .toList();
          final totalIncome = financeProvider.totalIncome;
          final totalExpense = financeProvider.totalExpense;
          final currentBalance = financeProvider.netBalance;

          functionResponses.add(FunctionResponse(functionCall.name, {
            'status': 'Success',
            'summary_data': {
              'total_income': totalIncome,
              'total_expense': totalExpense,
              'current_balance': currentBalance,
              'recent_transactions': recentTx,
            }
          }));
        }
      }

      // Send the tool response back to Gemini
      try {
        final followUpResponse = await _chatSession!
            .sendMessage(Content.functionResponses(functionResponses));
        await _handleResponse(followUpResponse, financeProvider);
      } catch (e) {
        debugPrint('Error sending function response to Gemini: $e');
        _isThinking = false;
        notifyListeners();
      }
    } else if (response.text != null && response.text!.isNotEmpty) {
      addMessage(ChatMessage(text: response.text!, isUser: false));
      _isThinking = false;
      notifyListeners();
    } else {
      _isThinking = false;
      notifyListeners();
    }
  }
}
