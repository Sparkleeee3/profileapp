import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/userprofile.dart';
import '../profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<UserProfile> _results = [];
  bool _loading = false;
  bool _searched = false;

  static const kPink     = Color(0xFFF9B2D7);
  static const kPinkDeep = Color(0xFFF075B0);
  static const kPinkDark = Color(0xFFD63384);
  static const kCream    = Color(0xFFFFF0F7);
  static const kWhite    = Colors.white;

  final _currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String email) async {
    final query = email.trim().toLowerCase();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _searched = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: query)
          .get();

      final results = snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data(), doc.id))
          .where((profile) => profile.uid != _currentUid) // exclude yourself
          .toList();

      setState(() => _results = results);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: $e'),
          backgroundColor: kPinkDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kPinkDark,
        foregroundColor: kWhite,
        title: const Text(
          'Search Users',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: kPinkDark,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Container(
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: kPinkDark.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                keyboardType: TextInputType.emailAddress,
                onSubmitted: _search,
                style: const TextStyle(fontSize: 15, color: Color(0xFF3D1A2E)),
                decoration: InputDecoration(
                  hintText: 'Search by email...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search_rounded, color: kPinkDark),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded, color: kPinkDark),
                    onPressed: () => _search(_searchController.text),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Results
          Expanded(
            child: _loading
                ? const Center(
                child: CircularProgressIndicator(color: kPinkDark))
                : !_searched
                ? _buildEmptyState(
              icon: Icons.person_search_rounded,
              message: 'Search for a user by email',
            )
                : _results.isEmpty
                ? _buildEmptyState(
              icon: Icons.search_off_rounded,
              message: 'No user found with that email',
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _results.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
              itemBuilder: (_, i) => _userCard(_results[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: kPink),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCard(UserProfile profile) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>ProfileScreen(uid: profile.uid),
        ),
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kPink.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: kPinkDeep.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: kPinkDeep,
              child: Text(
                _initials(profile.name),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kWhite,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name.isEmpty ? 'No name' : profile.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3D1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: kPinkDark),
          ],
        ),
      ),
    );
  }
}