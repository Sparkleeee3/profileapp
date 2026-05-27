import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  final String photoUrl;
  final double radius;
  const ProfileAvatar({super.key, required this.photoUrl, this.radius = 40});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: photoUrl.isNotEmpty
          ? CachedNetworkImageProvider(photoUrl)
          : null,
      child: photoUrl.isEmpty
          ? Icon(Icons.person, size: radius)
          : null,
    );
  }
}