import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';
import '../services/chat_service.dart';
import '../utils/app_localization.dart';

class ChatScreen extends StatefulWidget {
  final String? initialQuestion;
  final Map<String, dynamic>? diseaseContext;

  const ChatScreen({
    Key? key,
    this.initialQuestion,
    this.diseaseContext,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');
  final _bot = const types.User(id: 'bot', firstName: 'Plant Doctor');
  late final ChatService _chatService;
  bool _isTyping = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    // Set disease context if available
    if (widget.diseaseContext != null) {
      _chatService.setDiseaseContext(widget.diseaseContext!);
    }

    // Load chat history
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final success = await _chatService.loadHistory();
      if (success) {
        final history = _chatService.getHistory();
        if (history.isNotEmpty) {
          // Convert history to chat messages
          for (var i = history.length - 1; i >= 0; i--) {
            final message = history[i];
            if (message['role'] == 'user') {
              _addUserMessage(message['content']!);
            } else if (message['role'] == 'model') {
              _addBotMessage(message['content']!);
            }
          }
        } else {
          // Add welcome message if no history
          _addBotMessage(
              'Welcome to LeafLens Plant Doctor! I can help you with plant care, disease identification, and gardening tips. How can I assist you today?');
        }
      } else {
        // Add welcome message if no history
        _addBotMessage(
            'Welcome to LeafLens Plant Doctor! I can help you with plant care, disease identification, and gardening tips. How can I assist you today?');
      }
    } catch (e) {
      print('Error loading chat history: $e');
      // Add welcome message on error
      _addBotMessage(
          'Welcome to LeafLens Plant Doctor! I can help you with plant care, disease identification, and gardening tips. How can I assist you today?');
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
      _animationController.forward();
    }

    // If there's an initial question, send it after a delay
    if (widget.initialQuestion != null) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _handleSendPressed(types.PartialText(
          text: widget.initialQuestion!,
        ));
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Save chat history when leaving the screen
    _chatService.saveHistory();
    super.dispose();
  }

  void _addBotMessage(String text) {
    final botMessage = types.TextMessage(
      author: _bot,
      id: const Uuid().v4(),
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _messages.insert(0, botMessage);
    });
  }

  void _addUserMessage(String text) {
    final userMessage = types.TextMessage(
      author: _user,
      id: const Uuid().v4(),
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _messages.insert(0, userMessage);
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    _addUserMessage(message.text);

    setState(() {
      _isTyping = true;
    });

    try {
      final response = await _chatService.sendMessage(message.text);

      setState(() {
        _isTyping = false;
      });

      _addBotMessage(response);
    } catch (e) {
      setState(() {
        _isTyping = false;
      });

      _addBotMessage(
          'Sorry, I encountered an error while processing your request. Please try again later.');
    }
  }

  void _showApiKeyDialog() {
    final TextEditingController apiKeyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalization.of(context)?.translate('api_key') ?? 'API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalization.of(context)?.translate('api_key_description') ?? 
              'Enter your Gemini API key to use the chat service.'),
            const SizedBox(height: 16),
            TextField(
              controller: apiKeyController,
              decoration: InputDecoration(
                labelText: AppLocalization.of(context)?.translate('api_key') ?? 'API Key',
                hintText: 'AIzaSy...',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalization.of(context)?.translate('cancel') ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final apiKey = apiKeyController.text.trim();
              if (apiKey.isNotEmpty) {
                final success = await _chatService.setApiKey(apiKey);
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalization.of(context)?.translate('api_key_saved') ?? 'API key saved successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalization.of(context)?.translate('api_key_error') ?? 'Failed to save API key')),
                  );
                }
              }
            },
            child: Text(AppLocalization.of(context)?.translate('save') ?? 'Save'),
          ),
        ],
      ),
    );
  }

  void _clearChatHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalization.of(context)?.translate('clear_history') ?? 'Clear History'),
        content: Text(AppLocalization.of(context)?.translate('clear_history_confirm') ?? 
          'Are you sure you want to clear the chat history? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalization.of(context)?.translate('cancel') ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _chatService.clearHistory();
              _chatService.clearDiseaseContext(); // Clear disease context as well
              setState(() {
                _messages.clear();
              });
              _addBotMessage(
                  'Chat history cleared. How can I help you with your plants today?');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(AppLocalization.of(context)?.translate('clear') ?? 'Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseContextBanner() {
    if (widget.diseaseContext == null) return const SizedBox.shrink();

    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Plant Condition',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Condition: ${widget.diseaseContext!['condition']}',
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            'Severity: ${widget.diseaseContext!['severity']}',
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            'Confidence: ${widget.diseaseContext!['confidence']}%',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization?.translate('chat_with_plant_doctor') ??
            'Chat with Plant Doctor'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showApiKeyDialog,
            tooltip: localization?.translate('api_key') ?? 'API Key',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearChatHistory,
            tooltip: localization?.translate('clear_history') ?? 'Clear History',
          ),
        ],
      ),
      body: _isLoadingHistory
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localization?.translate('loading_chat') ?? 'Loading chat history...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Disease context banner
                  _buildDiseaseContextBanner(),

                  // Animated header/avatar
                  Container(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'plant_doctor_avatar',
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.eco,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plant Doctor',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 10 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  widget.diseaseContext != null
                                      ? 'Focusing on ${widget.diseaseContext!['condition']}'
                                      : 'AI Plant Care Expert',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.verified,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Chat(
                      messages: _messages,
                      onSendPressed: _handleSendPressed,
                      user: _user,
                      showUserAvatars: true,
                      showUserNames: true,
                      typingIndicatorOptions: TypingIndicatorOptions(
                        typingUsers: _isTyping ? [_bot] : [],
                      ),
                      theme: DefaultChatTheme(
                        primaryColor: Theme.of(context).primaryColor,
                        secondaryColor: Colors.grey[200]!,
                        backgroundColor: Colors.white,
                        inputBackgroundColor: Colors.grey[200]!,
                        inputTextColor: Colors.black,
                        inputTextCursorColor: Theme.of(context).primaryColor,
                        sentMessageBodyTextStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        receivedMessageBodyTextStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          height: 1.5,
                        ),
                      ),
                      inputOptions: InputOptions(
                        sendButtonVisibilityMode: SendButtonVisibilityMode.always,
                        keyboardType: TextInputType.multiline,
                        autocorrect: true,
                        autofocus: false,
                        enableSuggestions: true,
                        enabled: true,
                        usesSafeArea: true,
                      ),
                    ),
                  ),

                  // Tips banner
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                    )),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.grey[100],
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.diseaseContext != null
                                  ? 'Ask about treatment options, prevention tips, or care instructions for this condition'
                                  : localization?.translate('chat_tip') ??
                                      'Tip: You can ask specific questions about plant diseases, care routines, or fertilizers.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
