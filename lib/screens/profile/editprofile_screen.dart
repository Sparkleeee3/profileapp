  import 'package:flutter/material.dart';
  import '../../models/userprofile.dart';
  import '../../services/profile_service.dart';
  import 'package:flutter/services.dart';

  class EditProfileScreen extends StatefulWidget {
    final UserProfile profile;
    const EditProfileScreen({super.key, required this.profile});
    @override
    State<EditProfileScreen> createState() => _EditProfileScreenState();
  }

  class _EditProfileScreenState extends State<EditProfileScreen>
      with SingleTickerProviderStateMixin {
    late final _name = TextEditingController(text: widget.profile.name);
    late final _bio  = TextEditingController(text: widget.profile.bio);
    late final _cnum  = TextEditingController(text: widget.profile.cnum);
    late final _bday  = TextEditingController(text: widget.profile.bday);
    String? _selectedGender;
    bool _saving = false;

    late AnimationController _animController;
    late Animation<double> _fadeAnim;
    late Animation<Offset> _slideAnim;

    static const cpink     = Color(0xFFF9B2D7);
    static const kPinkDeep = Color(0xFFF075B0);
    static const kPinkDark = Color(0xFFD63384);
    static const kCream    = Color(0xFFFFF0F7);
    static const kWhite    = Colors.white;

    @override
    void initState() {
      super.initState();
      _selectedGender = widget.profile.gender;
      _animController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      );
      _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
      _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
          .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
      _animController.forward();
    }

    @override
    void dispose() {
      _animController.dispose();
      _name.dispose();
      _bio.dispose();
      super.dispose();
    }

    String get _initials {
      final parts = (_name.text.isEmpty ? widget.profile.name : _name.text)
          .trim()
          .split(' ');
      if (parts.isEmpty || parts[0].isEmpty) return '?';
      if (parts.length == 1) return parts[0][0].toUpperCase();
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }



    Future<void> _save() async {
      setState(() => _saving = true);
      try {
        final updated = widget.profile.copyWith(
          name: _name.text.trim(),
          bio:  _bio.text.trim(),
          cnum: _cnum.text.trim(),
          gender: _selectedGender ?? '',
          bday:_bday.text.trim(),
        );
        await ProfileService().updateProfile(updated);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$e'),
              backgroundColor: kPinkDark,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }

    Future<void> _pickDate() async {
      DateTime? initial;
      try {
        initial = _bday.text.isNotEmpty
            ? DateTime.parse(_bday.text)
            : DateTime(2000);
      } catch (_) {
        initial = DateTime(2000);
      }
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: kPinkDark,
                onPrimary: kWhite,
                surface: kCream,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        setState(() {
          _bday.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: cpink,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildCard()),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Top header
    Widget _buildHeader() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          children: [
            // App bar row
            Row(
              children: [
                _iconBtn(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                  tooltip: 'Back',
                ),
                const Expanded(
                  child: Text(
                    'Edit Profile',
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
                // Invisible
                const SizedBox(width: 42),
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
                child: AnimatedBuilder(
                  animation: _name,
                  builder: (_, __) => Text(
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
            ),

            const SizedBox(height: 12),

            Text(
              'Update your information below',
              style: TextStyle(
                fontSize: 13,
                color: kWhite.withOpacity(0.75),
                letterSpacing: 0.2,
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
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: cpink,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bio
              _sectionLabel('About Me'),
              const SizedBox(height: 8),
              _styledField(
                controller: _bio,
                icon: Icons.edit_note_rounded,
                hint: 'Write something about yourself',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Name
              _sectionLabel('Name'),
              const SizedBox(height: 8),
              _styledField(
                controller: _name,
                icon: Icons.person_outline_rounded,
                hint: 'Your full name',
              ),
              const SizedBox(height: 16),

              // Contact Number
              _sectionLabel('Contact Number'),
              const SizedBox(height: 8),
              _styledField(
                controller: _cnum,
                icon: Icons.phone_android_outlined,
                hint: 'Your contact number',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
              const SizedBox(height: 16),

              // Gender
              _sectionLabel('Gender'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cpink.withOpacity(0.6)),
                  boxShadow: [
                    BoxShadow(
                      color: kPinkDeep.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: ['Male', 'Female'].map((g) {
                    return Expanded(
                      child: RadioListTile<String>(
                        title: Text(g,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        value: g,
                        groupValue: _selectedGender,
                        activeColor: kPinkDark,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _selectedGender = val),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Birthday
              _sectionLabel('Birthday'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: _styledField(
                    controller: _bday,
                    icon: Icons.date_range,
                    hint: 'Select your birthday',
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: _saving
                    ? const Center(
                    child: CircularProgressIndicator(color: kPinkDark))
                    : ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
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
              const SizedBox(height: 10),

              // Cancel button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: kPinkDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Reusable widget
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

    Widget _styledField({
      required TextEditingController controller,
      required IconData icon,
      required String hint,
      int maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
      List<TextInputFormatter>? inputFormatters,
    }) {
      return Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cpink.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: kPinkDeep.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
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
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cpink.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: kPinkDark, size: 18),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 14,
            ),
          ),
        ),
      );
    }

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
  }