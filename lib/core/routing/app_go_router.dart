import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:timnhahang/core/presentation/widget/customer_bottom_nav.dart';
import 'package:timnhahang/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:timnhahang/core/routing/go_router_refresh_change.dart';
import 'package:timnhahang/features/auth/presentation/pages/login_page.dart';
import 'package:timnhahang/features/auth/presentation/pages/signup_page.dart';
import 'package:timnhahang/features/notes/presentation/pages/notes_list_page.dart';

class AppGoRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: CustomerBottomNav(initialIndex: 0),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.notes,
            builder: (context, state) => const NotesListPage(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggedIn = user != null;
      final loggingIn =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;
      if (!loggedIn && !loggingIn) return AppRoutes.login;

      if (loggedIn && loggingIn) return AppRoutes.notes;
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
  );
}
