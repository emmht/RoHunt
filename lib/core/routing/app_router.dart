import 'package:flutter/material.dart';
import 'routes.dart';

import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/avatar/screens/avatar_setup_screen.dart';
import '../../features/cities/screens/city_details_screen.dart';
import '../../features/cities/screens/favorite_cities_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/hunt/models/treasure_hunt.dart';
import '../../features/hunt/screens/hunt_screen.dart';
import '../../features/profile/screens/medals_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/quiz/screens/quiz_screen.dart';
import '../../features/quiz/data/romania_cities.dart';
import '../../features/quiz/models/tour_city.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case Routes.verifyEmail:
        return MaterialPageRoute(builder: (_) => const VerifyEmailScreen());
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case Routes.quiz:
        return MaterialPageRoute(builder: (_) => const QuizScreen());
      case Routes.cityDetails:
        final city = settings.arguments is TourCity
            ? settings.arguments as TourCity
            : romaniaCities.first;
        return MaterialPageRoute(builder: (_) => CityDetailsScreen(city: city));
      case Routes.favoriteCities:
        return MaterialPageRoute(builder: (_) => const FavoriteCitiesScreen());
      case Routes.hunt:
        if (settings.arguments is TreasureHunt) {
          return MaterialPageRoute(
            builder: (_) =>
                HuntScreen(hunt: settings.arguments as TreasureHunt),
          );
        }

        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Traseu indisponibil'))),
        );
      case Routes.avatarSetup:
        return MaterialPageRoute(builder: (_) => const AvatarSetupScreen());
      case Routes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case Routes.medals:
        return MaterialPageRoute(builder: (_) => const MedalsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Pagina indisponibilă'))),
        );
    }
  }
}
