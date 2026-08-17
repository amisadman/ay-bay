import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/providers/ai_provider.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class WalleoAIChatScreen extends StatefulWidget {
  const WalleoAIChatScreen({super.key});

  @override
  State<WalleoAIChatScreen> createState() => _WalleoAIChatScreenState();
}

class _WalleoAIChatScreenState extends State<WalleoAIChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    // Initialize provider in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AIProvider>(context, listen: false).initializeModel();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('onStatus: $val'),
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            _textController.text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              // Wait until user stops speaking to send
            }
          },
          localeId:
              'bn_BD', // Try to support Bengali explicitly if available, or default
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_textController.text.isNotEmpty) {
        _sendMessage();
      }
    }
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty && _selectedImageBytes == null) return;

    final text = _textController.text.trim();
    _textController.clear();
    final imageBytes = _selectedImageBytes;
    
    setState(() {
      _selectedImageBytes = null;
    });

    final financeProvider =
        Provider.of<FinanceProvider>(context, listen: false);
    Provider.of<AIProvider>(context, listen: false)
        .sendMessage(text, financeProvider, imageBytes: imageBytes);

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AIProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Lottie.asset('assets/animations/mr_wallet.json',
                width: 40, height: 40, repeat: true),
            const SizedBox(width: 8),
            Text(
              'Walleo AI',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Thinking animation header
          if (aiProvider.isThinking)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/animations/balance.json',
                      width: 60, height: 60),
                  const SizedBox(width: 10),
                  AnimatedTextKit(
                    animatedTexts: [
                      WavyAnimatedText('Thinking...',
                          textStyle: const TextStyle(
                              color: Colors.grey, fontSize: 16)),
                    ],
                    isRepeatingAnimation: true,
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: aiProvider.messages.length,
              itemBuilder: (context, index) {
                final msg = aiProvider.messages[index];
                final isUser = msg.isUser;

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomRight: isUser
                            ? const Radius.circular(0)
                            : const Radius.circular(20),
                        bottomLeft: isUser
                            ? const Radius.circular(20)
                            : const Radius.circular(0),
                      ),
                      border: isUser
                          ? null
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: isUser
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (msg.imageBytes != null) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(msg.imageBytes!, width: 200, fit: BoxFit.cover),
                                ),
                                const SizedBox(height: 8),
                              ],
                              Text(
                                msg.text,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ],
                          )
                        : AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                msg.text,
                                textStyle: TextStyle(
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color ??
                                        AppColors.black,
                                    fontSize: 15),
                                speed: const Duration(milliseconds: 30),
                              ),
                            ],
                            isRepeatingAnimation: false,
                            displayFullTextOnTap: true,
                          ),
                  ),
                );
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedImageBytes != null)
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: MemoryImage(_selectedImageBytes!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -10,
                        top: -10,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.black54),
                          onPressed: () {
                            setState(() {
                              _selectedImageBytes = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showAttachmentOptions,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: Icon(Icons.attach_file, color: Theme.of(context).iconTheme.color),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _listen,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isListening ? AppColors.red : Theme.of(context).scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _isListening
                                  ? AppColors.red
                                  : Colors.grey.withOpacity(0.3)),
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening
                              ? Colors.white
                              : Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: _isListening
                              ? 'Listening...'
                              : 'Type or speak your request...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).textTheme.bodyLarge?.color ??
                              AppColors.black,
                          shape: BoxShape.circle,
                        ),
                        child:
                            const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
