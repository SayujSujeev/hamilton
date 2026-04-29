import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:google_fonts/google_fonts.dart';

import '../widgets/get_started_primary_button.dart';
import 'personal_details_screen.dart';

const Color _kOtpRed = Color(0xFFB71C1C);
const Color _kOtpButtonGrey = Color(0xFF9E9E9E);

/// OTP verification — layout matches [PhoneRegistrationScreen].
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 4;
  static const int _resendSeconds = 42;

  /// Same as phone registration.
  static const double _designW = 390;
  static const double _designH = 844;
  static const double _formTop = 248;
  static const double _formLeft = 16;
  static const double _formContentW = 360;
  static const double _gapAboveContent = 40;
  /// OTP row: total 232 design px = 4×52 + 3×8 gap.
  static const double _otpBoxW = 52;
  static const double _otpBoxH = 52;
  static const double _otpGap = 8;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  late int _secondsLeft;
  Timer? _timer;

  void _onOtpTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _secondsLeft = _resendSeconds;
    _startTimer();
    for (final c in _controllers) {
      c.addListener(_onOtpTextChanged);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
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

  String get _timerLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
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
            label: 'Verify OTP',
            enabled: _otpComplete,
            onPressed: _otpComplete
                ? () {
                    Navigator.of(context).push(
                      PageRouteBuilder<void>(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                PersonalDetailsScreen(
                                  phoneNumber: widget.phoneNumber,
                                ),
                        transitionsBuilder: (context, animation,
                            secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
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
                                onTap: _startTimer,
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
    );
  }
}

/// Same header structure as [_RegistrationHeader] + back + OTP copy.
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
                                text: 'Enter the 4-digit code sent to ',
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

  /// Inner horizontal inset (Figma).
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
