import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/get_started_primary_button.dart';
import 'home_screen.dart';

class AddNewVehicleScreen extends StatefulWidget {
  const AddNewVehicleScreen({super.key});

  @override
  State<AddNewVehicleScreen> createState() => _AddNewVehicleScreenState();
}

class _AddNewVehicleScreenState extends State<AddNewVehicleScreen> {
  final _vehicleNumberController = TextEditingController();
  final _odometerController = TextEditingController();

  String? _selectedMake;
  String? _selectedModel;
  String? _selectedYear;
  int? _selectedColorIndex;

  static const List<String> _makes = [
    'BMW',
    'MERCEDES-BENZ',
    'AUDI',
    'LEXUS',
    'PORSCHE',
    'JAGUAR',
    'LAND ROVER',
    'VOLVO',
    'TOYOTA',
    'NISSAN',
  ];
  static const List<String> _models = ['X5', 'X7', 'Cayenne', 'A6'];
  static const List<String> _years = ['2026', '2025', '2024', '2023', '2022'];
  static const List<Color> _colors = [
    Color(0xFFF1ECE8),
    Color(0xFF1F223E),
    Color(0xFF6C6C6C),
    Color(0xFFCA3C2D),
    Color(0xFF2D588B),
    Color(0xFF355E2E),
  ];
  static const List<String> _colorNames = [
    'Pearl White',
    'Navy Blue',
    'Grey',
    'Red',
    'Blue',
    'Green',
  ];

  bool get _canSubmit =>
      _vehicleNumberController.text.trim().isNotEmpty &&
      _selectedMake != null &&
      _selectedModel != null &&
      _selectedYear != null &&
      _selectedColorIndex != null;

  @override
  void initState() {
    super.initState();
    _vehicleNumberController.addListener(_refresh);
  }

  @override
  void dispose() {
    _vehicleNumberController.removeListener(_refresh);
    _vehicleNumberController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  String get _selectedColorName =>
      _selectedColorIndex == null ? '-' : _colorNames[_selectedColorIndex!];

  String get _formattedVehicleNumber {
    final raw = _vehicleNumberController.text.trim();
    if (raw.isEmpty) return '-';
    return raw.replaceAll(' ', '').toUpperCase();
  }

  Future<void> _submitVehicle() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 300),
        reverseDuration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeInOut,
      ),
      builder: (sheetContext) {
        final screenWidth = MediaQuery.sizeOf(sheetContext).width;
        final sheetWidth = screenWidth < 390 ? screenWidth : 390.0;
        return SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 390 > sheetWidth ? sheetWidth : 390,
              height: 600,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 224,
                        height: 14,
                        child: Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFF9A9A9A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Image.asset(
                        'assets/images/success_badge_icon.png',
                        width: 79.99992370605469,
                        height: 79.71501922607422,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Vehicle Added\nSuccessfully!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSerifText(
                          fontSize: 22,
                          height: 1.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF191919),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Image.asset(
                        'assets/images/home_bmw_x5.png',
                        width: 180,
                        height: 132,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      _SummaryRow(
                        label: 'Vehicle Number:',
                                value: _formattedVehicleNumber,
                      ),
                              const SizedBox(height: 15),
                      _SummaryRow(label: 'Make:', value: _selectedMake!),const SizedBox(height: 15),
                      _SummaryRow(label: 'Model:', value: _selectedModel!),const SizedBox(height: 15),
                      _SummaryRow(label: 'Year:', value: _selectedYear!),const SizedBox(height: 15),
                      _SummaryRow(
                        label: 'Current Odometer:',
                        value: _odometerController.text.trim().isEmpty
                            ? '-'
                            : _odometerController.text.trim(),
                      ),const SizedBox(height: 15),
                      _SummaryRow(
                        label: 'Selected Colour:',
                        value: _selectedColorName,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(46),
                                side: const BorderSide(color: Color(0xFFBBBBBB)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                foregroundColor: const Color(0xFF2F2F2F),
                              ),
                              child: Text(
                                'Edit Vehicle',
                                style: GoogleFonts.dmSans(
                                  fontSize: 22 / 2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GetStartedPrimaryButton(
                              width: double.infinity,
                              height: 46,
                              label: 'Go to Home  >',
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const HomeScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: Column(
          children: [
            const _Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TextFieldBox(
                      controller: _vehicleNumberController,
                      hint: 'Vehicle Number',
                      requiredField: true,
                    ),
                    const SizedBox(height: 54),
                    _DropdownFieldBox(
                      hint: 'Make',
                      value: _selectedMake,
                      items: _makes,
                      requiredField: true,
                      onChanged: (value) => setState(() => _selectedMake = value),
                      useBottomSheetPicker: true,
                    ),
                    const SizedBox(height: 14),
                    _DropdownFieldBox(
                      hint: 'Model',
                      value: _selectedModel,
                      items: _models,
                      requiredField: true,
                      onChanged: (value) => setState(() => _selectedModel = value),
                      useBottomSheetPicker: true,
                    ),
                    const SizedBox(height: 14),
                    _DropdownFieldBox(
                      hint: 'Year',
                      value: _selectedYear,
                      items: _years,
                      requiredField: true,
                      onChanged: (value) => setState(() => _selectedYear = value),
                      useBottomSheetPicker: true,
                    ),
                    const SizedBox(height: 14),
                    _TextFieldBox(
                      controller: _odometerController,
                      hint: 'Current Odometer (in KM)',
                    ),
                    const SizedBox(height: 12),
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.dmSans(
                          color: const Color(0xFF8A8A8A),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                        children: const [
                          TextSpan(text: 'Colour'),
                          TextSpan(
                            text: '*',
                            style: TextStyle(color: Color(0xFFD74A41)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(_colors.length, (index) {
                        final selected = _selectedColorIndex == index;
                        return Padding(
                          padding: EdgeInsets.only(right: index == _colors.length - 1 ? 0 : 10),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedColorIndex = index),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _colors[index],
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.transparent,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: GetStartedPrimaryButton(
              width: double.infinity,
              height: 48,
              label: 'Add to My Garage  >',
              enabled: _canSubmit,
              onPressed: _canSubmit ? _submitVehicle : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: 108 + topInset,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/add_new_vehicle_header_bg.png'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: topInset + 10,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          Positioned(
            left: 44,
            right: 16,
            top: topInset + 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Vehicle',
                  style: GoogleFonts.dmSerifText(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter your Qatar plate number and vehicle details.',
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextFieldBox extends StatelessWidget {
  const _TextFieldBox({
    required this.controller,
    required this.hint,
    this.requiredField = false,
  });

  final TextEditingController controller;
  final String hint;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    final baseHintStyle = GoogleFonts.dmSans(
      color: const Color(0xFF666364),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.0,
      letterSpacing: 0,
    );

    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF202020),
          height: 1.0,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hint: requiredField
              ? Text.rich(
                  TextSpan(
                    style: baseHintStyle,
                    children: [
                      TextSpan(text: hint),
                      const TextSpan(
                        text: '*',
                        style: TextStyle(color: Color(0xFFD74A41)),
                      ),
                    ],
                  ),
                )
              : null,
          hintText: requiredField ? null : hint,
          hintStyle: baseHintStyle,
          filled: true,
          fillColor: const Color(0xFFF4F4F4),
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFCFCFCF), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFF9D9D9D), width: 1.2),
          ),
        ),
      ),
    );
  }
}

class _DropdownFieldBox extends StatelessWidget {
  const _DropdownFieldBox({
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
    this.requiredField = false,
    this.useBottomSheetPicker = false,
  });

  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool requiredField;
  final bool useBottomSheetPicker;

  @override
  Widget build(BuildContext context) {
    final baseHintStyle = GoogleFonts.dmSans(
      color: const Color(0xFF666364),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.0,
      letterSpacing: 0,
    );

    if (useBottomSheetPicker) {
      final labelWidget = Text.rich(
        TextSpan(
          style: baseHintStyle,
          children: [
            TextSpan(text: hint),
            if (requiredField)
              const TextSpan(
                text: '*',
                style: TextStyle(color: Color(0xFFD74A41)),
              ),
          ],
        ),
      );

      return GestureDetector(
        onTap: () async {
          final popupTitle = hint == 'Make' ? 'Car make - Popup' : '$hint - Popup';
          final popupPrompt =
              hint == 'Make' ? 'Select Your Car Make' : 'Select Your $hint';

          final selected = await showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            sheetAnimationStyle: const AnimationStyle(
              duration: Duration(milliseconds: 300),
              reverseDuration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              reverseCurve: Curves.easeInOut,
            ),
            builder: (sheetContext) {
              return SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCECECE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        popupTitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          popupPrompt,
                          style: GoogleFonts.dmSerifText(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 310),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: Color(0xFFEAEAEA)),
                          itemBuilder: (_, index) {
                            final item = items[index];
                            final isSelected = item == value;
                            return InkWell(
                              onTap: () => Navigator.of(sheetContext).pop(item),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF2E2E2E),
                                          letterSpacing: 0,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFB71C1C)
                                              : const Color(0xFFBDBDBD),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Center(
                                              child: CircleAvatar(
                                                radius: 3.5,
                                                backgroundColor: Color(0xFFB71C1C),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          if (selected != null) {
            onChanged(selected);
          }
        },
        child: Container(
          width: double.infinity,
          height: 52,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCFCFCF), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: value == null
                      ? labelWidget
                      : Text(
                          value!,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF303030),
                            height: 1.0,
                            letterSpacing: 0,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF333333)),
            ],
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
      decoration: InputDecoration(
        hint: requiredField
            ? Text.rich(
                TextSpan(
                  style: baseHintStyle,
                  children: [
                    TextSpan(text: hint),
                    const TextSpan(
                      text: '*',
                      style: TextStyle(color: Color(0xFFD74A41)),
                    ),
                  ],
                ),
              )
            : null,
        hintText: requiredField ? null : hint,
        hintStyle: baseHintStyle,
        filled: true,
        fillColor: const Color(0xFFF4F4F4),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFCFCFCF), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF9D9D9D), width: 1.2),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.dmSans(
                  color: const Color(0xFF303030),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 298,
      height: 14,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF666364),
                height: 1.0,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2E2E2E),
                height: 1.0,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
