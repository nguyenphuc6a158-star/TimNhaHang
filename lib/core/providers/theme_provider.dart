// lib/core/providers/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Mặc định là giao diện sáng
  ThemeMode _themeMode = ThemeMode.light;

  // Getter để các widget khác có thể đọc trạng thái hiện tại
  ThemeMode get themeMode => _themeMode;

  // Getter để biết có đang ở chế độ tối hay không (cho cái Switch)
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Hàm để thay đổi theme
  void setTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    // Thông báo cho tất cả các widget đang "lắng nghe" để chúng build lại
    notifyListeners();
  }
}
