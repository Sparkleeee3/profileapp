import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'signup_screen.dart';
import 'forgotpass_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _loading = false;
  bool _obscurePass = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;


  static const kGreen      = Color(0xFFDAF9DE);
  static const kGreenDeep  = Color(0xFF7EE89A);
  static const kGreenDark  = Color(0xFF2E9E52);
  static const kCream      = Color(0xFFF2FFF4);
  static const cblack      = Colors.black;
  static const fg          = Color(0xFfF6FFDC);


  @override
  void initState() {
    super.initState();
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
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => _loading = true);
    try {
      await AuthService().login(_email.text.trim(), _pass.text.trim());
    } catch (e) {
      if (mounted) {
        String message;
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'wrong-password':
            case 'invalid-credential':
              message = 'Incorrect email or password';
              break;
            case 'user-not-found':
              message = 'No account found with that email';
              break;
            case 'invalid-email':
              message = 'Please enter a valid email';
              break;
            case 'user-disabled':
              message = 'This account has been disabled';
              break;
            default:
              message = 'Incorrect email or password';
          }
        } else {
          message = 'Incorrect email or password';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),  // 👈 no longer '$e'
            backgroundColor: kGreenDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreen,
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

  //Top header
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      child: Column(
        children: [
          // Logo / icon
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kGreenDark.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: kGreenDeep,
              child: const Icon(
                Icons.account_circle,
                size: 40,
                color: cblack,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Jeneroso Profile App',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: kGreenDark,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: kGreenDeep .withOpacity(0.50
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Sign in to continue',
              style: TextStyle(
                fontSize: 13,
                color: kGreenDark.withOpacity(0.9),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card
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
                  color: kGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Email field
            _sectionLabel('Email'),
            const SizedBox(height: 10),
            _styledField(
              controller: _email,
              icon: Icons.mail_outline_rounded,
              hint: 'Your email',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 24),

            // Password field
            _sectionLabel('Password'),
            const SizedBox(height: 10),
            _styledField(
              controller: _pass,
              icon: Icons.lock_outline_rounded,
              hint: 'Your password',
              obscureText: _obscurePass,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: kGreenDark,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: kGreenDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Login button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: _loading
                  ? const Center(
                child: CircularProgressIndicator(color: kGreenDark),
              )
                  : ElevatedButton.icon(
                onPressed: _login,
                icon: const Icon(Icons.login_rounded, size: 20),
                label: const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreenDark,
                  foregroundColor: fg,
                  elevation: 4,
                  shadowColor: kGreenDark.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Sign up link
            Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: kGreenDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14),
                    children: [
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      const TextSpan(
                        text: 'Sign up',
                        style: TextStyle(
                          color: kGreenDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusabl widgets
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: kGreenDark,
      ),
    );
  }

  Widget _styledField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kGreen.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: kGreenDeep.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A3D24),
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
                color: kGreen.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: kGreenDark, size: 18),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}