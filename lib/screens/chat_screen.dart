import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';
import '../services/chat_service.dart';
import '../utils/app_localization.dart';

class ChatScreen extends StatefulWidget {
  final String? initialQuestion;

  const ChatScreen({
    Key? key,
    this.initialQuestion,
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

    // Add welcome message with animation
    Future.delayed(const Duration(milliseconds: 300), () {
      _addBotMessage(
          'Welcome to LeafLens Plant Doctor! I can help you with plant care, disease identification, and gardening tips. How can I assist you today?');

      _animationController.forward();
    });

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

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization?.translate('chat_with_plant_doctor') ??
            'Chat with Plant Doctor'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
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
                          child: const Text(
                            'Plant Doctor',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
                            'AI Plant Care Expert',
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
                        localization?.translate('chat_tip') ??
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
