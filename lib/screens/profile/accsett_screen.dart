import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/userprofile.dart';
import '../../services/profile_service.dart';

class AccountSettingsScreen extends StatefulWidget {
  final UserProfile profile;
  const AccountSettingsScreen({super.key, required this.profile});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late bool _privateCnum;
  late bool _privateGender;
  late bool _privateBday;
  late bool _privateEmail;
  bool _saving = false;

  // Change password controllers
  final _currentPass = TextEditingController();
  final _newPass     = TextEditingController();
  final _confirmPass = TextEditingController();
  bool _changingPass = false;
  bool _showCurrent  = false;
  bool _showNew      = false;
  bool _showConfirm  = false;

  static const kPink     = Color(0xFFF9B2D7);
  static const kPinkDeep = Color(0xFFF075B0);
  static const kPinkDark = Color(0xFFD63384);
  static const kCream    = Color(0xFFFFF0F7);
  static const kWhite    = Colors.white;

  @override
  void initState() {
    super.initState();
    _privateCnum   = widget.profile.privateCnum;
    _privateGender = widget.profile.privateGender;
    _privateBday   = widget.profile.privateBday;
    _privateEmail  = widget.profile.privateEmail;
  }

  @override
  void dispose() {
    _currentPass.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  // Save privacy settings
  Future<void> _savePrivacy() async {
    setState(() => _saving = true);
    try {
      final updated = widget.profile.copyWith(
        privateCnum:   _privateCnum,
        privateGender: _privateGender,
        privateBday:   _privateBday,
        privateEmail:  _privateEmail,
      );
      await ProfileService().updateProfile(updated);
      if (mounted) _showSnackBar('Privacy settings saved!', success: true);
    } catch (e) {
      if (mounted) _showSnackBar('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // Change password
  Future<void> _changePassword() async {
    if (_newPass.text != _confirmPass.text) {
      _showSnackBar('New passwords do not match');
      return;
    }
    if (_newPass.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters');
      return;
    }

    setState(() => _changingPass = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;

      // Re-authenticate first
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPass.text,
      );
      await user.reauthenticateWithCredential(cred);

      // Then change password
      await user.updatePassword(_newPass.text);

      if (mounted) {
        _currentPass.clear();
        _newPass.clear();
        _confirmPass.clear();
        _showSnackBar('Password changed successfully!', success: true);
      }
    } on FirebaseAuthException catch (e) {
      print('ERROR CODE: "${e.code}"');
      String message;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Current password is incorrect';
          break;
        case 'weak-password':
          message = 'New password is too weak';
          break;
        case 'requires-recent-login':
          message = 'Please log out and log back in first';
          break;
        default:
          message = 'Current password is incorrect';
      }
      if (mounted) _showSnackBar(message);
    } catch (e) {
      if (mounted) _showSnackBar('Current password is incorrect');
    } finally {
      if (mounted) setState(() => _changingPass = false);
    }
  }

  void _showSnackBar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green.shade600 : kPinkDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPink,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kWhite.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: kWhite, size: 22),
                ),
              ),
              const Expanded(
                child: Text(
                  'Account Settings',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: kWhite,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 42),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Manage your privacy and security',
            style: TextStyle(
              fontSize: 13,
              color: kWhite.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: kPink,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Privacy Section ──
            _sectionLabel('Privacy Settings'),
            const SizedBox(height: 6),
            Text(
              'Hidden fields show as "Private" to other users',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),

            _privacyCard([
              _privacyToggle(
                icon: Icons.phone_android_outlined,
                label: 'Contact Number',
                value: _privateCnum,
                onChanged: (v) => setState(() => _privateCnum = v),
              ),
              _divider(),
              _privacyToggle(
                icon: Icons.person_outline_rounded,
                label: 'Gender',
                value: _privateGender,
                onChanged: (v) => setState(() => _privateGender = v),
              ),
              _divider(),
              _privacyToggle(
                icon: Icons.date_range,
                label: 'Birthday',
                value: _privateBday,
                onChanged: (v) => setState(() => _privateBday = v),
              ),
              _divider(),
              _privacyToggle(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                value: _privateEmail,
                onChanged: (v) => setState(() => _privateEmail = v),
              ),
            ]),

            const SizedBox(height: 16),

            // Save privacy button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _saving
                  ? const Center(
                  child: CircularProgressIndicator(color: kPinkDark))
                  : ElevatedButton.icon(
                onPressed: _savePrivacy,
                icon: const Icon(Icons.shield_outlined, size: 18),
                label: const Text('Save Privacy Settings',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPinkDark,
                  foregroundColor: kWhite,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // ── Change Password Section ──
            _sectionLabel('Change Password'),
            const SizedBox(height: 16),

            _privacyCard([
              _passwordField(
                controller: _currentPass,
                hint: 'Current password',
                icon: Icons.lock_outline_rounded,
                show: _showCurrent,
                onToggle: () => setState(() => _showCurrent = !_showCurrent),
              ),
              _divider(),
              _passwordField(
                controller: _newPass,
                hint: 'New password',
                icon: Icons.lock_reset_rounded,
                show: _showNew,
                onToggle: () => setState(() => _showNew = !_showNew),
              ),
              _divider(),
              _passwordField(
                controller: _confirmPass,
                hint: 'Confirm new password',
                icon: Icons.lock_rounded,
                show: _showConfirm,
                onToggle: () => setState(() => _showConfirm = !_showConfirm),
              ),
            ]),

            const SizedBox(height: 16),

            // Change password button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _changingPass
                  ? const Center(
                  child: CircularProgressIndicator(color: kPinkDark))
                  : ElevatedButton.icon(
                onPressed: _changePassword,
                icon: const Icon(Icons.key_rounded, size: 18),
                label: const Text('Change Password',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPinkDark,
                  foregroundColor: kWhite,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _privacyCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kPink.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: kPinkDeep.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _privacyToggle({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPink.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kPinkDark, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3D1A2E),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: kPinkDark,
          ),
        ],
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool show,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPink.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kPinkDark, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: !show,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3D1A2E),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(
                    show ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: kPinkDark,
                    size: 20,
                  ),
                  onPressed: onToggle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: kPinkDark,
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: kPink.withOpacity(0.4),
      indent: 16,
      endIndent: 16,
    );
  }
}