import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_first_vehicle_screen.dart';
import '../widgets/get_started_primary_button.dart';

const Color _kRedAccent = Color(0xFFB71C1C);
const Color _kFieldFill = Color(0xFFF2F2F2);
const Color _kFieldBorder = Color(0xFFE0E0E0);

/// Personal details step after OTP — matches app registration layout.
class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key, this.phoneNumber = ''});

  final String phoneNumber;

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  static const double _designW = 390;
  static const double _designH = 844;
  static const double _formTop = 248;
  static const double _formLeft = 16;
  static const double _formContentW = 360;
  static const double _gapAboveContent = 24;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  bool _hasProfileImage = false;

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  static final _emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool get _canSubmit {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    return name.isNotEmpty && email.isNotEmpty && _emailOk.hasMatch(email);
  }

  void _onProfileImageTap() {
    // Hook image picker here; this toggles UI to the "added" state.
    setState(() => _hasProfileImage = true);
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
            label: 'Create My Account',
            enabled: _canSubmit,
            onPressed: _canSubmit
                ? () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const AddFirstVehicleScreen(),
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
            child: _PersonalDetailsHeader(textTheme: textTheme),
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
                    padding: EdgeInsets.only(bottom: 24 * sy),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: _gapAboveContent * sy),
                        _ProfileUploadRow(
                          sm: sm,
                          sx: sx,
                          hasProfileImage: _hasProfileImage,
                          onTap: _onProfileImageTap,
                        ),
                        SizedBox(height: 28 * sy),
                        _GreyField(
                          controller: _nameController,
                          label: 'Full Name',
                          required: true,
                          sm: sm,
                          sx: sx,
                          sy: sy,
                        ),
                        SizedBox(height: 20 * sy),
                        _GreyField(
                          controller: _emailController,
                          label: 'Email ID',
                          required: true,
                          keyboard: TextInputType.emailAddress,
                          sm: sm,
                          sx: sx,
                          sy: sy,
                        ),
                        SizedBox(height: 20 * sy),
                        _GreyField(
                          controller: _addressController,
                          label: 'Address',
                          maxLines: 4,
                          sm: sm,
                          sx: sx,
                          sy: sy,
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

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - strokeWidth;
    final path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    const dash = 3.0;
    const gap = 3.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final segment = metric.extractPath(
          distance,
          (distance + dash).clamp(0, metric.length),
        );
        canvas.drawPath(segment, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

class _PersonalDetailsHeader extends StatelessWidget {
  const _PersonalDetailsHeader({required this.textTheme});

  final TextTheme textTheme;

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
                      Text(
                        'Enter Your',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSerifText(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 22 * s,
                          height: 1.3,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Personal Details',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSerifText(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 22 * s,
                          height: 1.3,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: _titleGap * s),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Your details help our team provide personalized service.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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

class _GreyField extends StatelessWidget {
  const _GreyField({
    required this.controller,
    required this.label,
    required this.sm,
    required this.sx,
    required this.sy,
    this.keyboard = TextInputType.text,
    this.maxLines = 1,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final double sm;
  final double sx;
  final double sy;
  final TextInputType keyboard;
  final int maxLines;
  final bool required;

  static const BorderRadius _fieldBorderRadius = BorderRadius.zero;

  @override
  Widget build(BuildContext context) {
    final horizontalPad = 14 * sx;
    final labelBaseStyle = GoogleFonts.dmSans(
      fontSize: 13 * sm,
      color: Colors.grey.shade500,
      fontWeight: FontWeight.w400,
    );
    final floatingStyle = GoogleFonts.dmSans(
      fontSize: 12 * sm,
      color: Colors.grey.shade500,
      fontWeight: FontWeight.w400,
    );

    final labelWidget = required
        ? Text.rich(
            TextSpan(
              style: labelBaseStyle,
              children: [
                TextSpan(text: label),
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: _kRedAccent,
                    fontSize: 13 * sm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        : Text(label, style: labelBaseStyle);

    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: GoogleFonts.dmSans(
        fontSize: 15 * sm,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        label: labelWidget,
        floatingLabelStyle: floatingStyle,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: _kFieldFill,
        contentPadding: EdgeInsets.fromLTRB(
          horizontalPad,
          18 * sy,
          horizontalPad,
          10 * sy,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: _fieldBorderRadius,
          borderSide: BorderSide(color: _kFieldBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: _fieldBorderRadius,
          borderSide: BorderSide(color: Color(0xFF1A1A1A), width: 1.2),
        ),
        border: const OutlineInputBorder(
          borderRadius: _fieldBorderRadius,
          borderSide: BorderSide(color: _kFieldBorder),
        ),
      ),
    );
  }
}

class _ProfileUploadRow extends StatelessWidget {
  const _ProfileUploadRow({
    required this.sm,
    required this.sx,
    required this.hasProfileImage,
    required this.onTap,
  });

  final double sm;
  final double sx;
  final bool hasProfileImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatarRadius = 36.0 * sm;
    final uploadTextStyle = GoogleFonts.dmSans(
      color: Colors.grey.shade600,
      fontSize: 12 * sm,
      fontWeight: FontWeight.w400,
      height: 1.1,
    );
    final changeTextStyle = GoogleFonts.dmSans(
      fontSize: 13 * sm,
      color: Colors.grey.shade700,
      fontWeight: FontWeight.w500,
    );

    final avatar = hasProfileImage
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: const Color(0xFFBDBDBD),
                child: Icon(
                  Icons.person,
                  size: 32 * sm,
                  color: Colors.white,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 22 * sm,
                  height: 22 * sm,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 12 * sm,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          )
        : SizedBox(
            width: avatarRadius * 2,
            height: avatarRadius * 2,
            child: CustomPaint(
              painter: _DashedCirclePainter(
                color: const Color(0xFF949494),
                strokeWidth: 1,
              ),
              child: Center(
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 28 * sm,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          );

    final label = hasProfileImage
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_outlined,
                size: 14 * sm,
                color: Colors.grey.shade600,
              ),
              SizedBox(width: 4 * sx),
              Text('Change Image', style: changeTextStyle),
            ],
          )
        : Text(
            'Upload your\nprofile picture',
            style: uploadTextStyle,
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(onTap: onTap, child: avatar),
        SizedBox(width: 14 * sx),
        GestureDetector(onTap: onTap, child: label),
      ],
    );
  }
}

