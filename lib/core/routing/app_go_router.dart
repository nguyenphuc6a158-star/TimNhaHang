import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:timnhahang/core/presentation/widget/customer_bottom_nav.dart';
import 'package:timnhahang/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:timnhahang/core/routing/go_router_refresh_change.dart';
import 'package:timnhahang/features/auth/presentation/pages/login_page.dart';
import 'package:timnhahang/features/auth/presentation/pages/signup_page.dart';
import 'package:timnhahang/features/history/presentation/page/history_page.dart';
import 'package:timnhahang/features/home/presentation/pages/home_page.dart';
import 'package:timnhahang/features/profile/presentation/pages/profile_page.dart';
import 'package:timnhahang/features/profile/presentation/pages/setting_pages.dart';
import 'package:timnhahang/features/restaurantsave/presentation/pages/restaurant_save_list.dart';

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
          // --- (CẬP NHẬT) Lấy UID và Vị trí hiện tại ---
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            // Trường hợp này không nên xảy ra nếu redirect hoạt động
            return const Scaffold(body: Center(child: Text("Lỗi xác thực.")));
          }

          final String uid = user.uid;
          final String location = state.matchedLocation;

          // Tính toán index hiện tại dựa trên route
          int currentIndex = 0;
          if (location == AppRoutes.home) {
            currentIndex = 0;
          } else if (location == AppRoutes.saved) {
            currentIndex = 1;
          } else if (location == AppRoutes.history) {
            currentIndex = 2;
          } else if (location.startsWith(AppRoutes.setting)) {
            // Dùng startsWith vì route profile bây giờ có /:uid
            currentIndex = 3;
          }

          return Scaffold(
            body: child,
            // (CẬP NHẬT) Truyền uid và currentIndex vào bottom nav
            bottomNavigationBar: CustomerBottomNav(
              initialIndex: currentIndex,
              uid: uid,
            ),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.saved,
            builder: (context, state) => const RestaurantSaveListPage(),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (context, state) => const HistoryPage(),
          ),
          GoRoute(
            path: '${AppRoutes.profile}/:uid',
            builder: (context, state) {
              final uid = state.pathParameters['uid']!;
              return ProfilePage(uid: uid);
            },
          ),
          GoRoute(
            path: '${AppRoutes.setting}/:uid',
            builder: (context, state) {
              final uid = state.pathParameters['uid']!;
              return SettingPage(uid: uid);
            },
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

      if (loggedIn && loggingIn) return AppRoutes.home;
      if (loggedIn && state.matchedLocation == AppRoutes.profile) {
        return '${AppRoutes.profile}/${user.uid}';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
  );
}
