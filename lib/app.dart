import 'package:flutter/material.dart';
import 'package:timnhahang/core/presentation/theme/app_theme.dart';
import 'package:timnhahang/core/routing/app_go_router.dart';
// import 'core/routing/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Clean Flutter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppGoRouter.router,
    );
  }
}
