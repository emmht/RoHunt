import 'dart:io';

import 'package:flutter/material.dart';

import '../services/avatar_service.dart';

class ProfileImageAvatar extends StatelessWidget {
  const ProfileImageAvatar({
    super.key,
    this.radius = 28,
    this.fit = BoxFit.cover,
  });

  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final avatarService = AvatarService();
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<ProfileImage?>(
      stream: avatarService.watchProfileImage(),
      builder: (context, snapshot) {
        final profileImage = snapshot.data;

        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: switch (profileImage) {
            ProfileImage(isAsset: true, path: final path) => Image.asset(
              _activeAvatarPath(path),
              fit: fit,
              alignment: Alignment.center,
              width: radius * 2,
              height: radius * 2,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.person,
                size: radius,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            ProfileImage(isNetwork: true, path: final path) => Image.network(
              path,
              fit: fit,
              alignment: Alignment.center,
              width: radius * 2,
              height: radius * 2,
            ),
            ProfileImage(isLocalFile: true, path: final path) => Image.file(
              File(path),
              fit: fit,
              alignment: Alignment.center,
              width: radius * 2,
              height: radius * 2,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.person,
                size: radius,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            _ => Icon(
              Icons.person,
              size: radius,
              color: colorScheme.onPrimaryContainer,
            ),
          },
        );
      },
    );
  }

  String _activeAvatarPath(String savedPath) {
    final oldAvatarMatch = RegExp(
      r'assets/avatars/avatar_0([1-4])\.png$',
    ).firstMatch(savedPath);

    if (oldAvatarMatch != null) {
      return 'assets/avatars/avatar_0${oldAvatarMatch.group(1)}.jpg.png';
    }

    return savedPath;
  }
}
