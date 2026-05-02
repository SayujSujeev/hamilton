import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/get_started_primary_button.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import 'personal_details_screen.dart';
import 'home_screen_wrapper.dart';

/// Registration entry screen — uses native Google Sign-In SDK.
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

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      // 1. Trigger native Google account picker and get id_token.
      final idToken = await _authService.getGoogleIdToken();

      if (idToken == null) {
        // User cancelled the picker.
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // 2. Exchange id_token for a backend JWT.
      final jwtToken = await _apiClient.authenticateWithGoogleToken(idToken);

      if (jwtToken == null || jwtToken.isEmpty) {
        _showError('Authentication failed. Please try again.');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // 3. Persist the JWT.
      await _authService.saveToken(jwtToken);

      // 4. Decide where to navigate based on profile completeness.
      if (!mounted) return;

      try {
        final userResponse = await _apiClient.getCurrentUser();
        final userData = userResponse['data'];
        final bool isProfileComplete = userData != null &&
            userData['firstname'] != null &&
            userData['lastname'] != null &&
            userData['email'] != null;

        if (!mounted) return;
        setState(() => _isLoading = false);

        _navigateTo(
          isProfileComplete
              ? const HomeScreenWrapper()
              : const PersonalDetailsScreen(),
        );
      } catch (_) {
        // If the profile check fails treat the user as new.
        if (mounted) {
          setState(() => _isLoading = false);
          _navigateTo(const PersonalDetailsScreen());
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Sign-in error: ${e.toString()}');
      }
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
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
                        'Sign in with your Google account to get started',
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFF888888),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GetStartedPrimaryButton(
                            width: double.infinity,
                            height: 52,
                            label: _isLoading
                                ? 'Signing in…'
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
              color: Colors.black.withValues(alpha: 0.35),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
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
            image: AssetImage(
              'assets/images/registration_header_background.png',
            ),
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
