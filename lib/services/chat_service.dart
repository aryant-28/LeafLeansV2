import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  static const String _defaultApiKey = 'AIzaSyD3_9MBenYVYrEXziYcwforj5xzuXYHpI8';
  static const String _apiKeyPrefKey = 'gemini_api_key';
  
  // Rate limiting
  static const int _maxRequestsPerMinute = 60;
  final List<DateTime> _requestTimestamps = [];
  
  // Store conversation history
  final List<Map<String, String>> _conversationHistory = [];
  
  // Store disease context
  Map<String, dynamic>? _diseaseContext;
  
  // System prompt to guide the AI's responses
  static const String _systemPrompt = '''
You are an expert plant doctor and horticulturalist with extensive knowledge in plant care, diseases, and gardening. 
Your role is to provide accurate, helpful, and practical advice about plants. Follow these guidelines:
1. Be concise but informative
2. Use simple language that's easy to understand
3. Provide specific, actionable advice
4. Include relevant scientific information when appropriate
5. Be encouraging and supportive
6. If unsure about something, acknowledge the uncertainty
7. Focus on organic and sustainable solutions when possible
8. When diagnosing plant issues, consider common problems first
9. Always consider the plant's specific needs based on species
10. Suggest preventive measures to avoid future problems
''';

  // Fallback responses for when API fails
  final List<String> _plantCareResponses = [
    'To keep your plants healthy, ensure they get adequate sunlight, water, and nutrients. Different plants have different requirements, so it\'s important to research specific needs for each species.',
    'Overwatering is a common mistake in plant care. Make sure your pots have drainage holes and wait until the top inch of soil is dry before watering again.',
    'Regular pruning helps promote plant growth and removes diseased or damaged parts. Always use clean, sharp tools when pruning to prevent spreading infections.',
    'Fertilize your plants during the growing season (spring and summer) but reduce or stop fertilizing during dormant periods (fall and winter) to avoid nutrient burn.',
    'Proper soil is essential for plant health. Most houseplants prefer well-draining potting mix, while outdoor plants may require soil amendments based on your local conditions.',
  ];

  final List<String> _diseaseResponses = [
    'Common plant diseases include powdery mildew, leaf spot, root rot, and various blights. Early detection is key to preventing their spread.',
    'Yellow leaves can indicate several issues: overwatering, underwatering, nutrient deficiencies, or pest problems. Check the soil moisture and look for signs of pests to narrow down the cause.',
    'Fungal diseases often thrive in humid conditions. Improve air circulation around your plants and avoid wetting the foliage when watering to prevent fungal problems.',
    'For organic disease control, neem oil, horticultural soap, and copper-based fungicides can be effective against many common plant pathogens.',
    'If your plant shows signs of viral infection (mosaic patterns, stunted growth), it\'s often best to remove the plant to prevent spread, as most plant viruses don\'t have cures.',
  ];

  final List<String> _fertilizerResponses = [
    'Plants need three main nutrients: nitrogen (N) for leaf growth, phosphorus (P) for roots and flowers, and potassium (K) for overall health. Most commercial fertilizers list these as "N-P-K" ratios on the packaging.',
    'Organic fertilizers like compost, manure, and bone meal release nutrients slowly and improve soil structure, while synthetic fertilizers provide immediate nutrients but don\'t improve soil health long-term.',
    'For flowering plants, choose fertilizers with higher phosphorus content (the middle number in the N-P-K ratio). For leafy plants, nitrogen-rich fertilizers work best.',
    'Slow-release fertilizers are convenient as they provide nutrients gradually over time, reducing the risk of fertilizer burn and requiring less frequent application.',
    'Always follow package instructions for fertilizer application rates. Over-fertilizing can damage plants by causing nutrient burn to the roots and foliage.',
  ];
  
  final List<String> _pestResponses = [
    'Common plant pests include aphids, spider mites, mealybugs, and scale insects. Regular inspection of your plants can help catch infestations early.',
    'For mild pest infestations, try removing pests by hand or using a strong spray of water. For more serious issues, consider using insecticidal soap or neem oil.',
    'Beneficial insects like ladybugs and lacewings can help control pest populations naturally. Consider attracting these to your garden.',
    'Yellow sticky traps can help monitor and reduce flying pest populations like fungus gnats and whiteflies.',
    'Isolate new plants for a few weeks before adding them to your collection to prevent introducing pests to your existing plants.',
  ];
  
  final List<String> _propagationResponses = [
    'Many plants can be propagated through stem cuttings, leaf cuttings, or division. Choose the method that works best for your plant species.',
    'For stem cuttings, use a clean, sharp knife to cut a 4-6 inch section of stem, remove lower leaves, and place in water or moist soil.',
    'Rooting hormone can increase the success rate of cuttings, though it\'s not always necessary.',
    'Keep cuttings in a warm, humid environment with indirect light until they develop roots.',
    'Some plants, like succulents, can be propagated from individual leaves. Simply place the leaf on moist soil and wait for roots to form.',
  ];

  // Singleton pattern
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  // Get API key from preferences or use default
  Future<String> _getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_apiKeyPrefKey) ?? _defaultApiKey;
    } catch (e) {
      print('Error getting API key: $e');
      return _defaultApiKey;
    }
  }
  
  // Set custom API key
  Future<bool> setApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeyPrefKey, apiKey);
      return true;
    } catch (e) {
      print('Error setting API key: $e');
      return false;
    }
  }
  
  // Check if we're within rate limits
  bool _isWithinRateLimit() {
    final now = DateTime.now();
    // Remove timestamps older than 1 minute
    _requestTimestamps.removeWhere((timestamp) => 
      now.difference(timestamp).inMinutes >= 1);
    
    // Check if we're under the limit
    if (_requestTimestamps.length >= _maxRequestsPerMinute) {
      return false;
    }
    
    // Add current timestamp
    _requestTimestamps.add(now);
    return true;
  }

  // Set disease context from image analysis
  void setDiseaseContext(Map<String, dynamic> context) {
    _diseaseContext = context;
    // Add initial context message to history
    if (_diseaseContext != null) {
      final contextMessage = '''
I've analyzed your plant and detected the following:
- Condition: ${_diseaseContext!['condition']}
- Confidence: ${_diseaseContext!['confidence']}%
- Severity: ${_diseaseContext!['severity']}

How can I help you with this specific plant issue?
''';
      _conversationHistory.add({'role': 'model', 'content': contextMessage});
    }
  }

  // Clear disease context
  void clearDiseaseContext() {
    _diseaseContext = null;
  }

  Future<String> sendMessage(String message) async {
    try {
      // Check rate limiting
      if (!_isWithinRateLimit()) {
        return 'I\'m receiving too many requests right now. Please try again in a moment.';
      }
      
      // Add user message to history
      _conversationHistory.add({'role': 'user', 'content': message});

      // Get API key
      final apiKey = await _getApiKey();

      // Prepare the conversation context
      final List<Map<String, dynamic>> contents = [
        {
          'parts': [
            {'text': _systemPrompt}
          ]
        }
      ];

      // Add disease context if available
      if (_diseaseContext != null) {
        contents.add({
          'parts': [
            {
              'text': '''
Current plant condition context:
- Condition: ${_diseaseContext!['condition']}
- Confidence: ${_diseaseContext!['confidence']}%
- Severity: ${_diseaseContext!['severity']}
- Description: ${_diseaseContext!['description'] ?? 'No description available'}
- Recommended remedies: ${_diseaseContext!['remedies']?.join(', ') ?? 'No remedies available'}
- Prevention tips: ${_diseaseContext!['prevention']?.join(', ') ?? 'No prevention tips available'}

Please keep your responses focused on this specific plant condition and provide relevant advice.
'''
            }
          ]
        });
      }

      // Add conversation history (last 5 messages for context)
      final historyContext = _conversationHistory
          .take(5)
          .map((msg) => {
                'role': msg['role'],
                'parts': [{'text': msg['content']}]
              })
          .toList();

      contents.addAll(historyContext);

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Add AI response to history
        _conversationHistory.add({'role': 'model', 'content': aiResponse});
        
        return aiResponse;
      } else if (response.statusCode == 403) {
        // API key issue
        return 'There seems to be an issue with the API key. Please check your configuration.';
      } else if (response.statusCode == 429) {
        // Rate limiting from API
        return 'The service is currently busy. Please try again in a moment.';
      } else {
        throw Exception('Failed to generate response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in chat service: $e');
      // Return a fallback response based on the message content
      return _getFallbackResponse(message);
    }
  }

  String _getFallbackResponse(String message) {
    final messageLower = message.toLowerCase();
    
    if (_containsKeywords(messageLower, ['care', 'water', 'sunlight', 'soil', 'grow', 'planting'])) {
      return _getRandomResponse(_plantCareResponses);
    } else if (_containsKeywords(messageLower, ['disease', 'sick', 'yellow', 'brown', 'spots', 'rot', 'mildew'])) {
      return _getRandomResponse(_diseaseResponses);
    } else if (_containsKeywords(messageLower, ['fertilizer', 'nutrient', 'food', 'npk', 'fertilize'])) {
      return _getRandomResponse(_fertilizerResponses);
    } else if (_containsKeywords(messageLower, ['pest', 'bug', 'insect', 'aphid', 'mite', 'scale'])) {
      return _getRandomResponse(_pestResponses);
    } else if (_containsKeywords(messageLower, ['propagate', 'cutting', 'root', 'grow from', 'new plant'])) {
      return _getRandomResponse(_propagationResponses);
    } else {
      return 'I apologize, but I\'m having trouble connecting to my knowledge base right now. Please try asking your question again in a moment.';
    }
  }

  bool _containsKeywords(String message, List<String> keywords) {
    return keywords.any((keyword) => message.toLowerCase().contains(keyword.toLowerCase()));
  }

  String _getRandomResponse(List<String> responses) {
    final random = math.Random();
    return responses[random.nextInt(responses.length)];
  }

  // Clear conversation history
  void clearHistory() {
    _conversationHistory.clear();
  }
  
  // Get conversation history
  List<Map<String, String>> getHistory() {
    return List.from(_conversationHistory);
  }
  
  // Save conversation history to persistent storage
  Future<bool> saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('chat_history', jsonEncode(_conversationHistory));
      return true;
    } catch (e) {
      print('Error saving chat history: $e');
      return false;
    }
  }
  
  // Load conversation history from persistent storage
  Future<bool> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('chat_history');
      if (historyJson != null) {
        final List<dynamic> history = jsonDecode(historyJson);
        _conversationHistory.clear();
        _conversationHistory.addAll(
          history.map((item) => Map<String, String>.from(item)).toList()
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error loading chat history: $e');
      return false;
    }
  }
}
