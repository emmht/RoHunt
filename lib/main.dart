import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/routing/routes.dart';
import 'core/theme/theme_mode_service.dart';
import 'features/cities/services/favorite_cities_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FavoriteCitiesService.initialize();
  await ThemeModeService.initialize();

  final User? currentUser = FirebaseAuth.instance.currentUser;

  runApp(
    currentUser == null
        ? const RoHuntApp()
        : currentUser.emailVerified
        ? const RoHuntApp(initialRoute: Routes.home)
        : const RoHuntApp(initialRoute: Routes.verifyEmail),
  );
}
