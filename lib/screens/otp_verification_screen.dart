import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:google_fonts/google_fonts.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../utils/auth_navigation.dart';
import '../widgets/get_started_primary_button.dart';

const Color _kOtpRed = Color(0xFFB71C1C);

/// OTP verification — verifies with Firebase and exchanges for a backend JWT.
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
    this.autoCredential,
  });

  final String phoneNumber;
  final String verificationId;
  final int? resendToken;

  /// Non-null on Android when Firebase auto-retrieves the OTP.
  final PhoneAuthCredential? autoCredential;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 6;
  static const int _resendSeconds = 60;

  static const double _designW = 390;
  static const double _designH = 844;
  static const double _formTop = 248;
  static const double _formLeft = 16;
  static const double _formContentW = 360;
  static const double _gapAboveContent = 40;
  static const double _otpBoxW = 46;
  static const double _otpBoxH = 52;
  static const double _otpGap = 6;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  late int _secondsLeft;
  Timer? _timer;
  bool _isVerifying = false;
  String _currentVerificationId = '';
  int? _resendToken;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _resendToken = widget.resendToken;
    _secondsLeft = _resendSeconds;
    _startTimer();
    for (final c in _controllers) {
      c.addListener(_onOtpTextChanged);
    }

    // If Android auto-resolved the credential, verify immediately.
    if (widget.autoCredential != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verifyWithCredential(widget.autoCredential!);
      });
    }
  }

  void _onOtpTextChanged() {
    if (mounted) setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.removeListener(_onOtpTextChanged);
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  bool get _otpComplete => _controllers.every(
        (c) => RegExp(r'^\d$').hasMatch(c.text.trim()),
      );

  String get _enteredOtp =>
      _controllers.map((c) => c.text.trim()).join();

  String get _timerLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _resendOtp() async {
    _startTimer();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      forceResendingToken: _resendToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _verifyWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) _showError(_friendlyError(e));
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() {
            _currentVerificationId = verificationId;
            _resendToken = resendToken;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP resent successfully.')),
          );
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> _verifyOtp() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: _currentVerificationId,
      smsCode: _enteredOtp,
    );
    await _verifyWithCredential(credential);
  }

  Future<void> _verifyWithCredential(PhoneAuthCredential credential) async {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);

    try {
      // 1. Sign in with Firebase.
      final userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // 2. Get the Firebase ID token.
      final idToken = await userCred.user?.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Could not retrieve Firebase ID token.');
      }

      // 3. Exchange the Firebase ID token for a backend JWT.
      final apiClient = ApiClient();
      final backendJwt = await apiClient.authenticateWithPhoneToken(idToken);

      // 4. Persist the backend JWT.
      final authService = AuthService();
      await authService.saveToken(backendJwt);

      if (!mounted) return;
      setState(() => _isVerifying = false);

      // 5. Route using JWT claims (is_profile_completed, is_vehicle_added).
      _navigateAfterAuth(backendJwt);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        _showError(_friendlyError(e));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        _showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _navigateAfterAuth(String backendJwt) {
    if (!mounted) return;
    _pushReplacement(
      authDestinationForToken(backendJwt, phoneNumber: widget.phoneNumber),
    );
  }

  void _pushReplacement(Widget screen) {
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
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-verification-code':
        return 'Wrong OTP. Please check the code and try again.';
      case 'session-expired':
        return 'OTP expired. Please request a new one.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Verification failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenSize = MediaQuery.sizeOf(context);
    final sx = screenSize.width / _designW;
    final sy = screenSize.height / _designH;
    final sm = sx < sy ? sx : sy;
    final headerH = _formTop * sy;
    final buttonW = _formContentW * sx;
    final buttonH = 52 * sy;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            _formLeft * sx,
            8 * sy,
            _formLeft * sx,
            16 * sy,
          ),
          child: GetStartedPrimaryButton(
            width: buttonW,
            height: buttonH,
            label: _isVerifying ? 'Verifying…' : 'Verify OTP',
            enabled: _otpComplete && !_isVerifying,
            onPressed: (_otpComplete && !_isVerifying) ? _verifyOtp : null,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: headerH,
                child: _OtpHeader(
                  textTheme: textTheme,
                  phoneNumber: widget.phoneNumber,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: _formLeft * sx),
                    child: SizedBox(
                      width: _formContentW * sx,
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: _gapAboveContent * sy),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var i = 0; i < _otpLength; i++) ...[
                                  if (i > 0) SizedBox(width: _otpGap * sx),
                                  _OtpBox(
                                    controller: _controllers[i],
                                    focusNode: _focusNodes[i],
                                    width: _otpBoxW * sm,
                                    height: _otpBoxH * sm,
                                    scaleMin: sm,
                                    cornerRadius: 14 * sm,
                                    onChanged: (v) => _onDigitChanged(i, v),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 20 * sy),
                            Row(
                              children: [
                                Text(
                                  "Didn't receive it?",
                                  style: GoogleFonts.dmSans(
                                    color: const Color(0xFF767676),
                                    fontSize: 12 * sm,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(width: 50 * sx),
                                if (_secondsLeft > 0)
                                  Text(
                                    'Resend in ',
                                    style: GoogleFonts.dmSans(
                                      color: const Color(0xFF767676),
                                      fontSize: 12 * sm,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                if (_secondsLeft > 0)
                                  Text(
                                    _timerLabel,
                                    style: GoogleFonts.dmSans(
                                      color: _kOtpRed,
                                      fontSize: 12 * sm,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (_secondsLeft == 0)
                                  GestureDetector(
                                    onTap: _resendOtp,
                                    child: Text(
                                      'Resend',
                                      style: GoogleFonts.dmSans(
                                        color: _kOtpRed,
                                        fontSize: 12 * sm,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Full-screen loading overlay while verifying.
          if (_isVerifying)
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

/// Same header structure as the phone registration screen.
class _OtpHeader extends StatelessWidget {
  const _OtpHeader({
    required this.textTheme,
    required this.phoneNumber,
  });

  final TextTheme textTheme;
  final String phoneNumber;

  static const double _designW = 390;
  static const double _carLeft = 197;
  static const double _carTop = 18;
  static const double _carW = 353.6059875488281;
  static const double _carH = 145.97207641601562;
  static const double _titleLeft = 16;
  static const double _titleTop = 120;
  static const double _titleW = 299;
  static const double _titleBlockH = 113;
  static const double _titleGap = 12;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/registration_header_background.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topLeft,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final s = constraints.maxWidth / _designW;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: _carLeft * s,
                  top: _carTop * s,
                  width: _carW * s,
                  height: _carH * s,
                  child: Image.asset(
                    'assets/images/registration_hero_car.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Positioned(
                  left: _titleLeft * s,
                  top: _titleTop * s,
                  width: _titleW * s,
                  height: _titleBlockH * s,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          'Please Check Your\nMessages',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSerifText(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 22 * s,
                            height: 1.3,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: _titleGap * s),
                      Flexible(
                        child: Text.rich(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          TextSpan(
                            style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  height: 1.3,
                                  fontSize: 11 * s,
                                ) ??
                                TextStyle(
                                  color: Colors.white,
                                  fontSize: 11 * s,
                                  height: 1.3,
                                ),
                            children: [
                              const TextSpan(
                                text: 'Enter the 6-digit code sent to ',
                              ),
                              TextSpan(
                                text: phoneNumber,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11 * s,
                                  height: 1.3,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8 * s,
                  left: 12 * s,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20 * s,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.width,
    required this.height,
    required this.scaleMin,
    required this.cornerRadius,
    required this.onChanged,
  });

  static const double _innerPaddingH = 8;
  static const double _fontSizeDesign = 14;

  final TextEditingController controller;
  final FocusNode focusNode;
  final double width;
  final double height;
  final double scaleMin;
  final double cornerRadius;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final fontSize = _fontSizeDesign * scaleMin;
    final vPad = ((height - fontSize) / 2).clamp(0.0, height / 2);

    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: '',
          isDense: true,
          hintText: '-',
          hintStyle: GoogleFonts.dmSans(
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            height: 1.0,
            letterSpacing: 0,
            color: const Color(0xFFBDBDBD),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: _innerPaddingH * scaleMin,
            vertical: vPad,
          ),
          filled: true,
          fillColor: const Color(0xFFF2F2F2),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
            borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1.2),
          ),
        ),
        style: GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          height: 1.0,
          letterSpacing: 0,
          color: Colors.black,
        ),
      ),
    );
  }
}
