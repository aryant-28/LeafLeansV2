import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../main.dart'; // For AppColors

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _vBarController;
  late AnimationController _hBarController;
  late AnimationController _leafController;

  // Animation Tweens
  Animation<Offset>? _vBarPathAnimation;
  Animation<Offset>? _hBarPathAnimation;
  Animation<Offset>? _leafPathAnimation;
  late Animation<double> _leafRotationAnimation;
  Animation<double>? _leafScaleAnimation; // Optional: for leaf grow/shrink

  // --- Sizes (Adjusted) ---
  final double logoBaseSize =
      300.0; // Width of H bar, Height of V bar (Increased more)
  final double barThickness =
      55.0; // Height of H bar, Width of V bar (Increased more)
  final double leafSize =
      80.0; // Width/Height of the leaf image square (Reverted to smaller size)

  bool _animationsInitialized = false;

  @override
  void initState() {
    super.initState();

    // Durations for the new sequence
    const vBarAnimDuration = Duration(milliseconds: 1500);
    const hBarAnimDuration = Duration(milliseconds: 1500);
    const leafAnimDuration =
        Duration(milliseconds: 2000); // More time for dramatic whirl
    const holdDuration = Duration(seconds: 1); // Shorter hold
    final totalDurationBeforeNav =
        vBarAnimDuration + hBarAnimDuration + leafAnimDuration + holdDuration;

    // Initialize controllers with new durations
    _vBarController =
        AnimationController(vsync: this, duration: vBarAnimDuration);
    _hBarController =
        AnimationController(vsync: this, duration: hBarAnimDuration);
    _leafController =
        AnimationController(vsync: this, duration: leafAnimDuration);

    // Increase rotation, keep easeOut curve
    _leafRotationAnimation =
        Tween<double>(begin: 0.0, end: 2 * math.pi * 5).animate(
      CurvedAnimation(
        parent: _leafController,
        curve: Curves.easeOut, // Rotation slows down
      ),
    );

    // Optional: Add scale animation to leaf
    _leafScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 0.5),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 0.5),
    ]).animate(
        CurvedAnimation(parent: _leafController, curve: Curves.easeInOut));

    // Setup navigation timer for the total duration
    Timer(totalDurationBeforeNav, _navigateToHome);
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_animationsInitialized) {
      final screenSize = MediaQuery.of(context).size;

      // --- Define Offsets relative to screen center (0,0) ---
      // V Bar Start/End
      final vBarStartOffset = Offset(0.0, -screenSize.height * 0.75);
      const vBarEndOffset = Offset(0.0, 0.0);
      // H Bar Start/End
      final hBarStartOffset = Offset(-screenSize.width * 0.75, 0.0);
      const hBarEndOffset = Offset(0.0, 0.0);

      // Leaf Start/End
      final leafStartOffset =
          Offset(screenSize.width * 0.75, screenSize.height * 0.75);
      // *** Adjust End position X to move leaf closer ***
      final double leafEndX =
          -(barThickness / 2 + leafSize / 2) + 10.0; // Shift right slightly
      final leafEndOffset = Offset(leafEndX, 0.0);

      // --- Initialize Path Animations (Adjust curves slightly) ---
      _vBarPathAnimation =
          Tween<Offset>(begin: vBarStartOffset, end: vBarEndOffset).animate(
              CurvedAnimation(
                  parent: _vBarController,
                  curve: Curves.easeOutCubic)); // Smoother than elastic

      _hBarPathAnimation =
          Tween<Offset>(begin: hBarStartOffset, end: hBarEndOffset).animate(
              CurvedAnimation(
                  parent: _hBarController,
                  curve: Curves.easeOutCubic)); // Smoother than elastic

      _leafPathAnimation =
          Tween<Offset>(begin: leafStartOffset, end: leafEndOffset).animate(
              CurvedAnimation(
                  parent: _leafController, curve: Curves.fastOutSlowIn));

      // --- Chain Animations Sequentially ---
      _vBarController.forward().whenComplete(() {
        if (mounted) {
          _hBarController.forward().whenComplete(() {
            if (mounted) {
              _leafController.forward();
            }
          });
        }
      }).catchError((error) {
        // Handle V bar animation error/cancellation
        print("V Bar animation failed: $error");
      });

      _animationsInitialized = true;
    }
  }

  @override
  void dispose() {
    _vBarController.dispose();
    _hBarController.dispose();
    _leafController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_animationsInitialized ||
        _vBarPathAnimation == null ||
        _hBarPathAnimation == null ||
        _leafPathAnimation == null ||
        _leafScaleAnimation == null) {
      // Show loading indicator until animations are ready
      return const Scaffold(
        backgroundColor: AppColors.primaryGreen,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: AnimatedBuilder(
        // Listen to all controllers
        animation: Listenable.merge(
            [_vBarController, _hBarController, _leafController]),
        builder: (context, child) {
          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // --- Vertical Bar --- (Uses updated sizes)
                Transform.translate(
                  offset: _vBarPathAnimation!.value,
                  child: Image.asset(
                    'assets/images/plus_v.png',
                    width: barThickness,
                    height: logoBaseSize,
                    fit: BoxFit.contain,
                  ),
                ),

                // --- Horizontal Bar --- (Uses updated sizes)
                Transform.translate(
                  offset: _hBarPathAnimation!.value,
                  child: Image.asset(
                    'assets/images/plus_h.png',
                    width: logoBaseSize,
                    height: barThickness,
                    fit: BoxFit.contain,
                  ),
                ),

                // --- Leaf --- (Uses reverted size)
                Transform.translate(
                  offset: _leafPathAnimation!.value,
                  child: Transform.rotate(
                    angle: _leafRotationAnimation.value,
                    child: Transform.scale(
                      scale:
                          _leafScaleAnimation!.value, // Apply scale animation
                      child: Image.asset(
                        'assets/images/leaf.png',
                        width: leafSize,
                        height: leafSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
