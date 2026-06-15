import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/get_started_primary_button.dart';
import 'otp_verification_screen.dart';

const Color _kRedAccent = Color(0xFFB71C1C);
/// Secondary promo line (DM Sans) — ash gray on white.
const Color _kAshFont = Color(0xFF8A8A8A);
/// Terms row body copy (Figma fill #767676).
const Color _kTermsBodyColor = Color(0xFF767676);

class _CountryInfo {
  const _CountryInfo({
    required this.flag,
    required this.name,
    required this.dialCode,
    required this.minDigits,
    required this.maxDigits,
  });

  final String flag;
  final String name;
  final String dialCode;
  final int minDigits;
  final int maxDigits;
}

const List<_CountryInfo> _kCountries = [
  _CountryInfo(flag: '🇸🇦', name: 'Saudi Arabia', dialCode: '+966', minDigits: 9, maxDigits: 9),
  _CountryInfo(flag: '🇮🇳', name: 'India',        dialCode: '+91',  minDigits: 10, maxDigits: 10),
  _CountryInfo(flag: '🇶🇦', name: 'Qatar',        dialCode: '+974', minDigits: 8, maxDigits: 8),
];

/// First step of signup: mobile number + terms, matching registration mockup.
class PhoneRegistrationScreen extends StatefulWidget {
  const PhoneRegistrationScreen({super.key});

  @override
  State<PhoneRegistrationScreen> createState() =>
      _PhoneRegistrationScreenState();
}

class _PhoneRegistrationScreenState extends State<PhoneRegistrationScreen> {
  bool _termsAccepted = false;
  bool _isLoading = false;
  _CountryInfo _selectedCountry = _kCountries.first;
  late final TextEditingController _phoneController;

  static const double _designW = 390;
  /// Figma frame height (used so header + form fit on short viewports).
  static const double _designH = 844;
  /// Dark header height as fraction of design frame (smaller = less black band).
  static const double _formTop = 248;
  static const double _formLeft = 16;
  static const double _formContentW = 360;
  /// Space below header before the phone row.
  static const double _gapAbovePhone = 40;
  /// Space under the phone field before the WhatsApp line.
  static const double _phoneToPromoGap = 12;
  /// Space between promotional line and terms/checkbox (design: 24px).
  static const double _promoToTermsGap = 24;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _canSubmitOtp {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final normalized =
        digits.startsWith('0') ? digits.substring(1) : digits;
    return _termsAccepted &&
        normalized.length >= _selectedCountry.minDigits;
  }

  Future<void> _sendOtp() async {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    // Strip leading 0 if user typed it (common in India/Saudi).
    final normalized = digits.startsWith('0') ? digits.substring(1) : digits;
    final phoneNumber = '${_selectedCountry.dialCode}$normalized';

    setState(() => _isLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      // Auto-retrieval on Android (SMS auto-read).
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Android only: sign in automatically without OTP entry.
        try {
          final userCred =
              await FirebaseAuth.instance.signInWithCredential(credential);
          final idToken = await userCred.user?.getIdToken();
          if (idToken != null && mounted) {
            _navigateToOtp(
              phoneNumber: phoneNumber,
              verificationId: '',
              autoCredential: credential,
            );
          }
        } catch (_) {
          // Fall through — user will enter OTP manually.
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError(_friendlyError(e));
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() => _isLoading = false);
          _navigateToOtp(
            phoneNumber: phoneNumber,
            verificationId: verificationId,
            resendToken: resendToken,
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Timeout reached; OTP entry is still possible.
      },
    );
  }

  void _navigateToOtp({
    required String phoneNumber,
    required String verificationId,
    int? resendToken,
    PhoneAuthCredential? autoCredential,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OtpVerificationScreen(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
              resendToken: resendToken,
              autoCredential: autoCredential,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
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

  void _showCountryPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Country',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              for (final country in _kCountries)
                ListTile(
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 26),
                  ),
                  title: Text(
                    country.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  trailing: Text(
                    country.dialCode,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF767676),
                    ),
                  ),
                  selected: country.dialCode == _selectedCountry.dialCode,
                  selectedColor: _kRedAccent,
                  selectedTileColor: _kRedAccent.withValues(alpha: 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCountry = country;
                      _phoneController.clear();
                    });
                    Navigator.of(ctx).pop();
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number. Please check and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Use the physical screen size so the layout doesn't collapse when the
    // keyboard opens (Scaffold below has resizeToAvoidBottomInset: false).
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
      // Button pinned at the bottom, outside the scroll area.
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
            label: _isLoading ? 'Sending OTP…' : 'Get OTP',
            enabled: _canSubmitOtp && !_isLoading,
            onPressed: (_canSubmitOtp && !_isLoading)
                ? _sendOtp
                : null,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: headerH,
            child: _RegistrationHeader(textTheme: textTheme),
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
                    child: _RegistrationForm(
                      scaleX: sx,
                      scaleY: sy,
                      scaleMin: sm,
                      phoneController: _phoneController,
                      gapAbovePhone: _gapAbovePhone * sy,
                      phoneToPromoGap: _phoneToPromoGap * sy,
                      promoToTermsGap: _promoToTermsGap * sy,
                      termsAccepted: _termsAccepted,
                      onTermsChanged: (v) =>
                          setState(() => _termsAccepted = v),
                      textTheme: textTheme,
                      selectedCountry: _selectedCountry,
                      onCountryTap: _showCountryPicker,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistrationHeader extends StatelessWidget {
  const _RegistrationHeader({required this.textTheme});

  final TextTheme textTheme;

  /// Figma frame width these coordinates are defined against.
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
  /// Headline text box (Figma): DM Serif Text 22 / 130% / 0.5 tracking.
  static const double _headlineW = 190;
  static const double _headlineH = 58;

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
                        child: SizedBox(
                          width: _headlineW * s,
                          height: _headlineH * s,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'What Is Your Mobile Number?',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.dmSerifText(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 22 * s,
                                height: 1.3,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: _titleGap * s),
                      Flexible(
                        child: Text(
                          "We'll send a verification code to confirm your number.",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                height: 1.3,
                                fontSize: 11  * s,
                              ) ??
                              TextStyle(
                                color: Colors.white,
                                fontSize: 14 * s,
                                height: 1.3,
                              ),
                        ),
                      ),
                    ],
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

class _RegistrationForm extends StatelessWidget {
  const _RegistrationForm({
    required this.scaleX,
    required this.scaleY,
    required this.scaleMin,
    required this.phoneController,
    required this.gapAbovePhone,
    required this.phoneToPromoGap,
    required this.promoToTermsGap,
    required this.termsAccepted,
    required this.onTermsChanged,
    required this.textTheme,
    required this.selectedCountry,
    required this.onCountryTap,
  });

  final double scaleX;
  final double scaleY;
  final double scaleMin;
  final TextEditingController phoneController;
  final double gapAbovePhone;
  final double phoneToPromoGap;
  final double promoToTermsGap;
  final bool termsAccepted;
  final ValueChanged<bool> onTermsChanged;
  final TextTheme textTheme;
  final _CountryInfo selectedCountry;
  final VoidCallback onCountryTap;

  @override
  Widget build(BuildContext context) {
    final hPad = 12 * scaleX;
    final vPad = 11 * scaleY;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(top: gapAbovePhone),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(14 * scaleMin),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onCountryTap,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(13 * scaleMin),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: hPad,
                        vertical: vPad,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedCountry.flag,
                            style: TextStyle(fontSize: 20 * scaleMin),
                          ),
                          SizedBox(width: 6 * scaleX),
                          Text(
                            selectedCountry.dialCode,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 14 * scaleMin,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(width: 2 * scaleX),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey.shade700,
                            size: 20 * scaleMin,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 22 * scaleMin,
                  color: const Color(0xFFCCCCCC),
                ),
                Expanded(
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(fontSize: 15 * scaleMin),
                    decoration: InputDecoration(
                      hintText: 'Enter ${selectedCountry.maxDigits}-digit number',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15 * scaleMin,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14 * scaleX,
                        vertical: vPad,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: phoneToPromoGap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '*',
                      style: GoogleFonts.dmSans(
                        color: _kRedAccent,
                        fontSize: 10 * scaleMin,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        letterSpacing: 0,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Add WhatsApp number to get promotional updates.',
                      style: GoogleFonts.dmSans(
                        color: _kAshFont,
                        fontSize: 10 * scaleMin,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: promoToTermsGap),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24 * scaleMin,
                    height: 24 * scaleMin,
                    child: Checkbox(
                      value: termsAccepted,
                      onChanged: (v) => onTermsChanged(v ?? false),
                      activeColor: _kRedAccent,
                      side: BorderSide(
                        color: Colors.grey.shade600,
                        width: 1.5 * scaleMin,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4 * scaleMin),
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * scaleX),
                  Expanded(
                    child: _TermsAgreementRichText(
                      textStyle: GoogleFonts.dmSans(
                        color: _kTermsBodyColor,
                        fontSize: 12 * scaleMin,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _TermsAgreementRichText extends StatefulWidget {
  const _TermsAgreementRichText({required this.textStyle});

  final TextStyle textStyle;

  @override
  State<_TermsAgreementRichText> createState() =>
      _TermsAgreementRichTextState();
}

class _TermsAgreementRichTextState extends State<_TermsAgreementRichText> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = () {};
    _privacyTap = TapGestureRecognizer()..onTap = () {};
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = widget.textStyle.copyWith(
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.solid,
      decorationColor: _kTermsBodyColor,
    );

    return RichText(
      text: TextSpan(
        style: widget.textStyle,
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            style: linkStyle,
            text: 'Terms of Service',
            recognizer: _termsTap,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            style: linkStyle,
            text: 'Privacy Policy',
            recognizer: _privacyTap,
          ),
        ],
      ),
    );
  }
}
