import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timnhahang/core/presentation/theme/app_theme.dart';
import 'package:timnhahang/core/providers/theme_provider.dart';
import 'package:timnhahang/core/routing/app_go_router.dart';
// import 'core/routing/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'Tìm Nhà Hàng',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          themeMode: themeProvider.themeMode,

          debugShowCheckedModeBanner: false,
          routerConfig: AppGoRouter.router,
        );
      },
    );
  }
}
