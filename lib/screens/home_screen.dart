import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/language_model.dart';
import '../utils/app_localization.dart';
import 'camera_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';
import 'reminder_screen.dart';
import 'login_screen.dart';  // Import the login screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _screens = [
      HomeContent(
        onScanLeafPressed: () => setTab(1),
        onChatPressed: () => setTab(2),
        onReminderPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReminderScreen()),
        ),
        animationController: _animationController,
        fadeAnimation: _fadeAnimation,
      ),
      const CameraScreen(),
      const ChatScreen(),
      const SettingsScreen(),
    ];

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization?.translate('home') ?? 'Home'),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
            ),
        ],
      ),
      body: user == null
          ? const LoginScreen() // If no user is logged in, show LoginScreen
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _screens[_currentIndex],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            onTap: setTab,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: localization?.translate('home') ?? 'Home',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.camera_alt),
                label: localization?.translate('scan_leaf') ?? 'Scan Leaf',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.chat),
                label: localization?.translate('chat') ?? 'Chat',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: localization?.translate('settings') ?? 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final VoidCallback onScanLeafPressed;
  final VoidCallback onChatPressed;
  final VoidCallback onReminderPressed;
  final AnimationController animationController;
  final Animation<double> fadeAnimation;

  const HomeContent({
    Key? key,
    required this.onScanLeafPressed,
    required this.onChatPressed,
    required this.onReminderPressed,
    required this.animationController,
    required this.fadeAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final userName = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName
        : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 600),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                FadeTransition(
                  opacity: fadeAnimation,
                  child: Text(
                    userName != null && userName.isNotEmpty
                        ? 'Welcome, $userName'
                        : 'Welcome!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  localization?.translate('plant_doctor_description') ?? 'Your AI assistant for plant health diagnosis and care',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 40),
                _buildAnimatedFeatureCard(
                  context,
                  delay: 300,
                  icon: Icons.camera_alt,
                  title: localization?.translate('scan_leaf') ?? 'Scan Leaf',
                  description: localization?.translate('scan_leaf_description') ?? 'Take a photo of your plant leaf to diagnose problems',
                  onTap: onScanLeafPressed,
                ),
                const SizedBox(height: 16),
                _buildAnimatedFeatureCard(
                  context,
                  delay: 500,
                  icon: Icons.chat,
                  title: localization?.translate('chat_with_ai') ?? 'Chat with AI',
                  description: localization?.translate('chat_description') ?? 'Ask questions and get advice about plant care',
                  onTap: onChatPressed,
                ),
                const SizedBox(height: 16),
                _buildAnimatedFeatureCard(
                  context,
                  delay: 700,
                  icon: Icons.alarm,
                  title: localization?.translate('reminders') ?? 'Reminders',
                  description: localization?.translate('reminder_description') ?? 'Set reminders to check your plants regularly',
                  onTap: onReminderPressed,
                ),
                const Spacer(),
                Center(
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 1000),
                    child: Text(
                      localization?.translate('get_started') ?? 'Get started by selecting an option above',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFeatureCard(
    BuildContext context, {
    required int delay,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: _buildFeatureCard(
        context,
        icon: icon,
        title: title,
        description: description,
        onTap: onTap,
      ),
    );
  }
  
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
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
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
