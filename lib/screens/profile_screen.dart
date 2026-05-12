import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/get_started_primary_button.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  UserModel? _user;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser({bool isRefresh = false}) async {
    if (mounted) {
      setState(() {
        if (isRefresh) {
          _isRefreshing = true;
        } else {
          _isLoading = true;
        }
        _error = null;
      });
    }

    try {
      final user = await _userService.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _user = user;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  String _dateLabel(DateTime value) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]} ${value.year}';
  }

  String _profileName(UserModel user) {
    final full = '${user.firstname} ${user.lastname}'.trim();
    if (full.isNotEmpty) return full;
    if (user.username.trim().isNotEmpty) return user.username.trim();
    return 'User';
  }

  String _valueOrDash(String? value) {
    final t = value?.trim();
    if (t == null || t.isEmpty) return '-';
    return t;
  }

  Future<void> _navigateToEditProfile() async {
    if (_user == null) return;
    
    final updatedUser = await Navigator.of(context).push<UserModel>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: _user!),
      ),
    );

    if (updatedUser != null && mounted) {
      setState(() {
        _user = updatedUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          _ProfileHeader(
            user: _user,
            isRefreshing: _isRefreshing,
            onBack: () => Navigator.of(context).pop(),
            onRefresh: () => _loadUser(isRefresh: true),
            onEdit: _navigateToEditProfile,
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 56),
              const SizedBox(height: 12),
              Text(
                'Unable to load profile',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  height: 1.35,
                  color: const Color(0xFF6B6B6B),
                ),
              ),
              const SizedBox(height: 18),
              GetStartedPrimaryButton(
                width: 180,
                height: 46,
                label: 'Retry',
                onPressed: _loadUser,
              ),
            ],
          ),
        ),
      );
    }

    final user = _user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      color: const Color(0xFFB71C1C),
      onRefresh: () => _loadUser(isRefresh: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          _ProfileSectionCard(
            title: 'Basic Information',
            children: [
              _ProfileInfoRow(label: 'Name', value: _profileName(user)),
              _ProfileInfoRow(label: 'Username', value: _valueOrDash(user.username)),
              _ProfileInfoRow(label: 'Email', value: _valueOrDash(user.email)),
              _ProfileInfoRow(label: 'Gender', value: _valueOrDash(user.gender)),
              _ProfileInfoRow(
                label: 'Status',
                value: user.isActive ? 'Active' : 'Inactive',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProfileSectionCard(
            title: 'Contact Information',
            children: [
              _ProfileInfoRow(label: 'Mobile', value: _valueOrDash(user.mobileNo)),
              _ProfileInfoRow(
                label: 'WhatsApp',
                value: _valueOrDash(user.whatsappNo),
              ),
              _ProfileInfoRow(label: 'Address', value: _valueOrDash(user.address)),
            ],
          ),
          const SizedBox(height: 12),
          _ProfileSectionCard(
            title: 'Account Metadata',
            children: [
              _ProfileInfoRow(label: 'Role ID', value: user.roleId.toString()),
              _ProfileInfoRow(
                label: 'Created On',
                value: _dateLabel(user.createdAt),
              ),
              _ProfileInfoRow(
                label: 'Last Updated',
                value: _dateLabel(user.updatedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.isRefreshing,
    required this.onBack,
    required this.onRefresh,
    required this.onEdit,
  });

  final UserModel? user;
  final bool isRefreshing;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final VoidCallback onEdit;

  String _initials(UserModel? user) {
    if (user == null) return 'U';
    final first = user.firstname.trim();
    final last = user.lastname.trim();
    final combined = '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'.toUpperCase();
    if (combined.isNotEmpty) return combined;
    if (user.username.trim().isNotEmpty) return user.username.trim()[0].toUpperCase();
    return 'U';
  }

  String _name(UserModel? user) {
    if (user == null) return 'My Profile';
    final full = '${user.firstname} ${user.lastname}'.trim();
    if (full.isNotEmpty) return full;
    return user.username;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 246,
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onBack,
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onEdit,
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: isRefreshing ? null : onRefresh,
                        child: Icon(
                          Icons.refresh,
                          color: isRefreshing ? Colors.white54 : Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Your Profile',
                    style: GoogleFonts.dmSerifText(
                      color: Colors.white,
                      fontSize: 33,
                      fontWeight: FontWeight.w400,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        child: Text(
                          _initials(user),
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _name(user),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
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
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color(0xFF8A8A8A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF1B1B1B),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
