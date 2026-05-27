import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/userprofile.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import 'editprofile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  UserProfile? _profile;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;


  static const kPink      = Color(0xFFF9B2D7);
  static const kPinkDeep  = Color(0xFFF075B0);
  static const kPinkDark  = Color(0xFFD63384);
  static const kCream     = Color(0xFFFFF0F7);
  static const kWhite     = Colors.white;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final p   = await ProfileService().getProfile(uid);
    setState(() => _profile = p);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }


  String get _initials {
    final parts = (_profile?.name ?? '').trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPink,
      body: _profile == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD63384)))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                _buildCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Top Heaader
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        children: [
          // App bar row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Profile',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: kWhite,
                  letterSpacing: 0.5,
                ),
              ),
              _iconBtn(
                icon: Icons.logout_rounded,
                onTap: () => AuthService().logout(),
                tooltip: 'Logout',
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Avatar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kWhite.withOpacity(0.6),
              boxShadow: [
                BoxShadow(
                  color: kPinkDark.withOpacity(0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 56,
              backgroundColor: kPinkDeep,
              child: Text(
                _initials,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: kWhite,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            _profile!.name.isEmpty ? 'Your Name' : _profile!.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: kWhite,
              fontFamily: 'Georgia',
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 6),

          // Email
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: kWhite.withOpacity(0.35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _profile!.email,
              style: const TextStyle(
                fontSize: 13,
                color: kWhite,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── White card section ────────────────────────────────────
  Widget _buildCard() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      decoration: const BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
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

          // Bio
          _sectionLabel('About Me'),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
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
            child: Text(
              _profile!.bio.isEmpty
                  ? 'No bio yet. Tap Edit Profile to add one ✨'
                  : _profile!.bio,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: _profile!.bio.isEmpty
                    ? Colors.grey.shade400
                    : Colors.grey.shade800,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Info
          _sectionLabel('Details'),
          const SizedBox(height: 10),
          _infoTile(Icons.person_outline_rounded, 'Name',
              _profile!.name.isEmpty ? '—' : _profile!.name),
          const SizedBox(height: 10),
          _infoTile(Icons.mail_outline_rounded, 'Email', _profile!.email),

          const SizedBox(height: 36),

          // Edit button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(profile: _profile!),
                  ),
                );
                _profile = null;
                setState(() {});
                _animController.reset();
                _load();
              },
              icon: const Icon(Icons.edit_rounded, size: 20),
              label: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPinkDark,
                foregroundColor: kWhite,
                elevation: 4,
                shadowColor: kPinkDark.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Reusable widgets
  Widget _iconBtn({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kWhite.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: kWhite, size: 22),
        ),
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
        color: Color(0xFFD63384),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPink.withOpacity(0.5)),
      ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: Color(0xFF3D1A2E))),
            ],
          ),
        ],
      ),
    );
  }
}