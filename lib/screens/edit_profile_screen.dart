import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/get_started_primary_button.dart';

const Color _kRedAccent = Color(0xFFB71C1C);
const Color _kFieldFill = Color(0xFFF2F2F2);
const Color _kFieldBorder = Color(0xFFE0E0E0);

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _mobileController;
  late TextEditingController _whatsappController;
  late TextEditingController _addressController;
  late TextEditingController _noteController;
  late TextEditingController _dobController;

  String? _selectedGender;
  bool _isSubmitting = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _firstnameController = TextEditingController(text: widget.user.firstname);
    _lastnameController = TextEditingController(text: widget.user.lastname);
    _mobileController = TextEditingController(text: widget.user.mobileNo ?? '');
    _whatsappController = TextEditingController(text: widget.user.whatsappNo ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _noteController = TextEditingController(text: widget.user.note ?? '');
    _selectedGender = widget.user.gender;
    
    if (widget.user.dob != null && widget.user.dob!.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(widget.user.dob!);
        _dobController = TextEditingController(text: _formatDate(_selectedDate!));
      } catch (_) {
        _dobController = TextEditingController();
      }
    } else {
      _dobController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _mobileController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1998),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _kRedAccent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);

    try {
      final updatedUser = await _userService.updateUserProfile(
        firstname: _firstnameController.text.trim(),
        lastname: _lastnameController.text.trim(),
        gender: _selectedGender,
        dob: _selectedDate?.toIso8601String().split('T').first,
        mobileNo: _mobileController.text.trim().isEmpty 
            ? null 
            : _mobileController.text.trim(),
        whatsappNo: _whatsappController.text.trim().isEmpty 
            ? null 
            : _whatsappController.text.trim(),
        address: _addressController.text.trim().isEmpty 
            ? null 
            : _addressController.text.trim(),
        note: _noteController.text.trim().isEmpty 
            ? null 
            : _noteController.text.trim(),
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile updated successfully',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(updatedUser);
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isSubmitting = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update profile: ${e.toString()}',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          _EditProfileHeader(
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  _SectionCard(
                    title: 'Basic Information',
                    children: [
                      _EditField(
                        controller: _firstnameController,
                        label: 'First Name',
                        required: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'First name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _EditField(
                        controller: _lastnameController,
                        label: 'Last Name',
                        required: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Last name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _GenderDropdown(
                        value: _selectedGender,
                        onChanged: (value) {
                          setState(() => _selectedGender = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      _EditField(
                        controller: _dobController,
                        label: 'Date of Birth',
                        readOnly: true,
                        onTap: _selectDate,
                        suffixIcon: const Icon(Icons.calendar_today, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Contact Information',
                    children: [
                      _EditField(
                        controller: _mobileController,
                        label: 'Mobile Number',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _EditField(
                        controller: _whatsappController,
                        label: 'WhatsApp Number',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _EditField(
                        controller: _addressController,
                        label: 'Address',
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Additional Details',
                    children: [
                      _EditField(
                        controller: _noteController,
                        label: 'Note',
                        maxLines: 4,
                        hintText: 'Any specific details or preferences',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 0, 16),
        child: GetStartedPrimaryButton(
          width: double.infinity,
          height: 52,
          label: _isSubmitting ? 'Saving...' : 'Save Changes',
          enabled: !_isSubmitting,
          onPressed: _isSubmitting ? null : _submit,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _EditProfileHeader extends StatelessWidget {
  const _EditProfileHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF43001E),
                image: DecorationImage(
                  image: AssetImage('assets/images/registration_header_background.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topLeft,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Edit Profile',
                    style: GoogleFonts.dmSerifText(
                      color: Colors.white,
                      fontSize: 33,
                      fontWeight: FontWeight.w400,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Update your personal information',
                    style: GoogleFonts.dmSans(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF6C6C6C),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.label,
    this.required = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.hintText,
  });

  final TextEditingController controller;
  final String label;
  final bool required;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hintText,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 13,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 13,
          color: Colors.grey.shade400,
        ),
        floatingLabelStyle: GoogleFonts.dmSans(
          fontSize: 12,
          color: _kRedAccent,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: _kFieldFill,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kFieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kRedAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  const _GenderDropdown({
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: GoogleFonts.dmSans(
          fontSize: 13,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: GoogleFonts.dmSans(
          fontSize: 12,
          color: _kRedAccent,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: _kFieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kFieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kRedAccent, width: 1.5),
        ),
      ),
      style: GoogleFonts.dmSans(
        fontSize: 14,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      dropdownColor: Colors.white,
      items: ['male', 'female', 'other'].map((gender) {
        return DropdownMenuItem(
          value: gender,
          child: Text(
            gender[0].toUpperCase() + gender.substring(1),
            style: GoogleFonts.dmSans(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }
}
