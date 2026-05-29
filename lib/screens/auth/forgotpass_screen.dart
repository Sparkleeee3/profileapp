import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _emailSent = false;

  static const kPink     = Color(0xFFF9B2D7);
  static const kPinkDeep = Color(0xFFF075B0);
  static const kPinkDark = Color(0xFFD63384);
  static const kCream    = Color(0xFFFFF0F7);
  static const kWhite    = Colors.white;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('Please enter your email'),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() => _emailSent = true);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with that email.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        default:
          message = 'Something went wrong. Please try again.';
      }
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(_snackBar(message));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  SnackBar _snackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: kPinkDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
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
          ),

          const SizedBox(height: 28),

          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kWhite.withOpacity(0.3),
            ),
            child: const Icon(Icons.lock_reset_rounded,
                size: 48, color: kWhite),
          ),

          const SizedBox(height: 16),

          const Text(
            'Forgot Password?',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: kWhite,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Enter your email and we\'ll send\na reset link',
            textAlign: TextAlign.center,
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
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
      child: _emailSent ? _buildSuccessState() : _buildFormState(),
    );
  }

  // After email is sent
  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mark_email_read_rounded,
            size: 72, color: kPinkDark),
        const SizedBox(height: 20),
        const Text(
          'Check your inbox!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Georgia',
            color: kPinkDark,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We sent a password reset link to\n${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        // Resend button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _emailSent = false),
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text(
              'Resend Email',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
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

        const SizedBox(height: 16),

        // Back to login
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Back to Login',
            style: TextStyle(
              color: kPinkDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Email input form
  Widget _buildFormState() {
    return Column(
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
        const SizedBox(height: 32),

        const Text(
          'EMAIL',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: kPinkDark,
          ),
        ),
        const SizedBox(height: 10),

        // Email field
        Container(
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
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3D1A2E),
            ),
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPink.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.mail_outline_rounded,
                    color: kPinkDark, size: 18),
              ),
              prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Send button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: _loading
              ? const Center(
              child: CircularProgressIndicator(color: kPinkDark))
              : ElevatedButton.icon(
            onPressed: _sendResetEmail,
            icon: const Icon(Icons.send_rounded, size: 20),
            label: const Text(
              'Send Reset Link',
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

        const SizedBox(height: 16),

        // Back to login
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: kPinkDark),
            child: const Text(
              'Back to Login',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}