import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:log_auth/pages/login_page.dart';
import 'package:log_auth/pages/home_page.dart';
import 'package:log_auth/pages/profile_page.dart';
import 'package:log_auth/pages/settings_page.dart';
import 'package:log_auth/pages/about_page.dart';
import '../pages/sign_in_page.dart';
import 'routes.dart';

class RoutePath {
  static final GoRouter router = GoRouter(
    initialLocation: Routes.login,
    routes: [
      GoRoute(
        path: Routes.login,
        name: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.signUp,
        name: Routes.signUp,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: Routes.home,
        name: Routes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: Routes.profile,
        name: Routes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: Routes.settings,
        name: Routes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: Routes.about,
        name: Routes.about,
        builder: (context, state) => const AboutPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
