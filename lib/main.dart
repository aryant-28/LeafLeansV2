import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';

// Only import Firebase packages if supported
// (Do not import firebase_core, firebase_auth, etc. at the top level)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Starting app initialization...');
  bool isFirebaseSupported = kIsWeb || Platform.isAndroid || Platform.isIOS;
  if (isFirebaseSupported) {
    print('Initializing Firebase...');
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized!');
    } catch (e, stack) {
      print('Firebase initialization failed: $e');
      print('Stack trace: $stack');
    }
  }
  runApp(MyApp(isFirebaseSupported: isFirebaseSupported));
}

class MyApp extends StatelessWidget {
  final bool isFirebaseSupported;
  const MyApp({Key? key, required this.isFirebaseSupported}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isFirebaseSupported
          ? const AuthGate()
          : const LinuxUnsupportedScreen(),
    );
  }
}

class LinuxUnsupportedScreen extends StatelessWidget {
  const LinuxUnsupportedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LeafLens')),
      body: const Center(
        child: Text(
          'Firebase is not supported on Linux.\nPlease run this app on Android, iOS, or Web.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// --- Firebase Auth Logic for Supported Platforms ---
// Only included on Android/iOS/Web
// (If you get errors on Linux, comment out this section)

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Building AuthGate...');
    return StreamBuilder<User?> (
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('AuthGate snapshot: \\${snapshot.connectionState}, hasData: \\${snapshot.hasData}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  // Demo credentials
  final String _demoEmail = 'demo@example.com';
  final String _demoPassword = 'password123';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _demoLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Try to sign in with demo credentials
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _demoEmail,
        password: _demoPassword,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // If demo user doesn't exist, try to sign up
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _demoEmail,
            password: _demoPassword,
          );
          // After sign up, try to log in again
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _demoEmail,
            password: _demoPassword,
          );
        } catch (signupError) {
          setState(() {
            _error = 'Demo login failed: \\${signupError.toString()}';
          });
        }
      } else {
        setState(() {
          _error = 'Demo login failed: \\${e.message}';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToSignUp() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
    if (result == 'success' && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please log in.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _login,
                            child: const Text('Login'),
                          ),
                          ElevatedButton(
                            onPressed: _navigateToSignUp,
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _demoLogin,
                        child: const Text('Demo Login'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    // Phone number validation: must be exactly 10 digits, numeric only
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      setState(() {
        _isLoading = false;
        _error = 'Please enter a valid 10-digit phone number.';
      });
      return;
    }
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Update display name
      await userCredential.user?.updateDisplayName(_nameController.text.trim());
      print('Sign-up successful, now signing out...');
      await FirebaseAuth.instance.signOut();
      print('Signed out after sign-up. Returning to login screen.');
      try {
        Navigator.of(context).pop('success');
        print('Navigator.pop called with success.');
      } catch (e) {
        print('Navigator.pop failed: $e. Trying popUntil.');
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    child: const Text('Sign Up'),
                  ),
          ],
        ),
      ),
    );
  }
}
