import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/get_started_primary_button.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import 'personal_details_screen.dart';
import 'home_screen.dart';

/// Registration entry screen that uses system browser for Google OAuth
class ContinueWithGoogleScreen extends StatefulWidget {
  const ContinueWithGoogleScreen({super.key});

  @override
  State<ContinueWithGoogleScreen> createState() =>
      _ContinueWithGoogleScreenState();
}

class _ContinueWithGoogleScreenState extends State<ContinueWithGoogleScreen> {
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _checkInitialDeepLink();
    _startListeningForCallback();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  /// Check if app was opened via deep link
  Future<void> _checkInitialDeepLink() async {
    final initialLink = await _authService.getInitialDeepLink();
    debugPrint('OAUTH_DEBUG: initial deep link = $initialLink');
    if (initialLink != null && mounted) {
      await _handleCallback(initialLink.toString());
    }
  }

  /// Start listening for deep link callbacks
  void _startListeningForCallback() {
    _authService.startListeningForCallback((uri) async {
      debugPrint('OAUTH_DEBUG: stream callback uri = $uri');
      if (uri != null && mounted) {
        await _handleCallback(uri);
      }
    });
  }

  /// Handle OAuth callback
  Future<void> _handleCallback(String uri) async {
    if (!mounted) return;
    debugPrint('OAUTH_DEBUG: _handleCallback entered with uri = $uri');

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _authService.extractTokenFromCallback(uri);
      debugPrint(
        'OAUTH_DEBUG: token extracted = ${token != null && token.isNotEmpty}',
      );

      if (token != null && token.isNotEmpty) {
        // Debug aid: copy this value from Logcat using DEBUG_TOKEN filter.
        debugPrint('DEBUG_TOKEN: $token');
        // Save token first
        await _authService.saveToken(token);

        // Check if user has completed profile
        try {
          final userResponse = await _apiClient.getCurrentUser();
          
          if (!mounted) return;

          // Check if user data exists and has required fields
          final userData = userResponse['data'];
          final bool isProfileComplete = userData != null &&
              userData['firstname'] != null &&
              userData['lastname'] != null &&
              userData['email'] != null;

          setState(() {
            _isLoading = false;
          });

          if (isProfileComplete) {
            // User has completed profile, go to home
            Navigator.of(context).pushReplacement(
              PageRouteBuilder<void>(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomeScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          } else {
            // User needs to complete profile
            Navigator.of(context).pushReplacement(
              PageRouteBuilder<void>(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const PersonalDetailsScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          }
        } catch (apiError) {
          // If API call fails (401, network error, etc.), go to personal details
          if (mounted) {
            setState(() {
              _isLoading = false;
            });

            Navigator.of(context).pushReplacement(
              PageRouteBuilder<void>(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const PersonalDetailsScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          }
        }
      } else {
        debugPrint('OAUTH_DEBUG: token was null/empty');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showError('Failed to get authentication token');
        }
      }
    } catch (e) {
      debugPrint('OAUTH_DEBUG: callback exception = $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Authentication failed: ${e.toString()}');
      }
    }
  }

  /// Handle Google sign-in button press
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final launched = await _authService.openGoogleAuthInBrowser();
      debugPrint('OAUTH_DEBUG: browser launched = $launched');

      if (!launched) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showError('Failed to open browser for authentication');
        }
      } else {
        // Keep loading state while waiting for callback
        // The callback will handle state changes
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complete sign-in in your browser'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Error: ${e.toString()}');
      }
    }
  }

  /// Show error message
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _GoogleHeader(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'By continuing, Login using Google',
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFF2E2E2E),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You will be redirected to your browser to complete sign-in',
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFF888888),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 34),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GetStartedPrimaryButton(
                            width: double.infinity,
                            height: 52,
                            label: _isLoading 
                                ? 'Signing in...' 
                                : 'Continue with Google',
                            enabled: !_isLoading,
                            onPressed: _handleGoogleSignIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Complete sign-in in your browser',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GoogleHeader extends StatelessWidget {
  const _GoogleHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/registration_header_background.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topLeft,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                left: 190,
                top: 18,
                width: 200,
                height: 140,
                child: Image.asset(
                  'assets/images/registration_hero_car.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                ),
              ),
              Positioned(
                left: 16,
                top: 120,
                child: Text(
                  'Continue With\nGoogle',
                  style: GoogleFonts.dmSerifText(
                    color: Colors.white,
                    fontSize: 32,
                    height: 1.05,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
