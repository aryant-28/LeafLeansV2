import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/app_localization.dart';
import '../services/plant_diagnosis_service.dart';
import '../models/diagnosis_result.dart';
import 'chat_screen.dart';

class DiagnosisScreen extends StatefulWidget {
  final File imageFile;
  
  const DiagnosisScreen({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> with SingleTickerProviderStateMixin {
  late Future<DiagnosisResult> _diagnosisFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _diagnosisFuture = PlantDiagnosisService().diagnoseLeaf(widget.imageFile);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localization?.translate('diagnosis_results') ?? 'Diagnosis Results'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: FutureBuilder<DiagnosisResult>(
        future: _diagnosisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading(localization);
          } else if (snapshot.hasError) {
            return _buildError(snapshot.error.toString(), localization);
          } else if (snapshot.hasData) {
            // Start animation when data is loaded
            _animationController.forward();
            return _buildResults(snapshot.data!, localization);
          } else {
            return _buildError(
              localization?.translate('unexpected_error') ?? 'Unexpected error occurred',
              localization,
            );
          }
        },
      ),
    );
  }
  
  Widget _buildLoading(AppLocalization? localization) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom animated loading indicator
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 2000),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              );
            },
            child: const Icon(Icons.eco, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            localization?.translate('analyzing_leaf') ?? 'Analyzing your leaf...',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localization?.translate('using_ai_models') ?? 
              'Using AI models to identify issues',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          // Pulse animation dots
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(
                        0.2 + ((index * 0.3 + value) % 1.0) * 0.8
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildError(String error, AppLocalization? localization) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red[300],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              localization?.translate('analysis_failed') ?? 'Analysis Failed',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                localization?.translate('try_again') ?? 'Try Again',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResults(DiagnosisResult result, AppLocalization? localization) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with hero animation
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: FileImage(widget.imageFile),
                fit: BoxFit.contain,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getConditionColor(result.condition),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getConditionText(result.condition, localization),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${(result.confidence * 100).toStringAsFixed(0)}% ${localization?.translate('confidence') ?? 'confidence'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Disease name
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Text(
                      result.diseaseName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Description
                _buildAnimatedInfoSection(
                  title: localization?.translate('about_condition') ?? 'About This Condition',
                  content: result.description,
                  delay: 0.1,
                ),
                
                const SizedBox(height: 16),
                
                // Remedies
                _buildAnimatedInfoSection(
                  title: localization?.translate('recommended_remedies') ?? 'Recommended Remedies',
                  content: result.remedies.join('\n\n'),
                  delay: 0.2,
                ),
                
                const SizedBox(height: 16),
                
                // Prevention
                _buildAnimatedInfoSection(
                  title: localization?.translate('prevention_tips') ?? 'Prevention Tips',
                  content: result.preventionTips.join('\n\n'),
                  delay: 0.3,
                ),
                
                const SizedBox(height: 32),
                
                // Buttons
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: Text(
                              localization?.translate('scan_again') ?? 'Scan Again',
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    initialQuestion: 'Tell me more about ${result.diseaseName}',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat),
                            label: Text(
                              localization?.translate('ask_expert') ?? 'Ask Expert',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
        ],
      ),
    );
  }
  
  Widget _buildAnimatedInfoSection({
    required String title, 
    required String content,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delayedAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay, delay + 0.6, curve: Curves.easeOut),
        );
        
        final fadeValue = Tween<double>(begin: 0.0, end: 1.0).evaluate(delayedAnimation);
        final slideValue = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).evaluate(delayedAnimation);
        
        return Opacity(
          opacity: fadeValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - fadeValue)),
            child: child,
          ),
        );
      },
      child: _buildInfoSection(title: title, content: content),
    );
  }
  
  Widget _buildInfoSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getConditionColor(PlantCondition condition) {
    switch (condition) {
      case PlantCondition.healthy:
        return const Color(0xFF4CAF50);
      case PlantCondition.mild:
        return const Color(0xFFFFA726);
      case PlantCondition.moderate:
        return const Color(0xFFF57C00);
      case PlantCondition.severe:
        return const Color(0xFFD32F2F);
    }
  }
  
  String _getConditionText(PlantCondition condition, AppLocalization? localization) {
    switch (condition) {
      case PlantCondition.healthy:
        return localization?.translate('healthy') ?? 'Healthy';
      case PlantCondition.mild:
        return localization?.translate('mild_issue') ?? 'Mild Issue';
      case PlantCondition.moderate:
        return localization?.translate('moderate_issue') ?? 'Moderate Issue';
      case PlantCondition.severe:
        return localization?.translate('severe_issue') ?? 'Severe Issue';
    }
  }
} 