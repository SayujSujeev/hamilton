import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/get_started_primary_button.dart';
import 'otp_verification_screen.dart';

const Color _kRedAccent = Color(0xFFB71C1C);
const Color _kOtpButtonGrey = Color(0xFF9E9E9E);
/// Secondary promo line (DM Sans) — ash gray on white.
const Color _kAshFont = Color(0xFF8A8A8A);
/// Terms row body copy (Figma fill #767676).
const Color _kTermsBodyColor = Color(0xFF767676);

/// First step of signup: mobile number + terms, matching registration mockup.
class PhoneRegistrationScreen extends StatefulWidget {
  const PhoneRegistrationScreen({super.key});

  @override
  State<PhoneRegistrationScreen> createState() =>
      _PhoneRegistrationScreenState();
}

class _PhoneRegistrationScreenState extends State<PhoneRegistrationScreen> {
  bool _termsAccepted = false;
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
    return _termsAccepted && digits.length >= 9;
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
            label: 'Get OTP',
            enabled: _canSubmitOtp,
            onPressed: _canSubmitOtp
                ? () {
                    final digits = _phoneController.text
                        .replaceAll(RegExp(r'\D'), '');
                    final formatted = '+966 $digits';
                    Navigator.of(context).push(
                      PageRouteBuilder<void>(
                        pageBuilder: (context, animation,
                                secondaryAnimation) =>
                            OtpVerificationScreen(
                                phoneNumber: formatted),
                        transitionsBuilder: (context, animation,
                            secondaryAnimation, child) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                        transitionDuration:
                            const Duration(milliseconds: 300),
                      ),
                    );
                  }
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
                    onTap: () {},
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
                            '🇸🇦',
                            style: TextStyle(fontSize: 20 * scaleMin),
                          ),
                          // SizedBox(width: 8 * scaleX),
                          // Text(
                          //   '+966',
                          //   style: textTheme.bodyLarge?.copyWith(
                          //         fontWeight: FontWeight.w600,
                          //         fontSize: 15 * scaleMin,
                          //       ) ??
                          //       TextStyle(
                          //         fontSize: 15 * scaleMin,
                          //         fontWeight: FontWeight.w600,
                          //       ),
                          // ),
                          // SizedBox(width: 4 * scaleX),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey.shade700,
                            size: 22 * scaleMin,
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
                      hintText: 'Mobile Number',
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
