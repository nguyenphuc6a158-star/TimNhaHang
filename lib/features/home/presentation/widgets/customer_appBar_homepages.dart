// ignore_for_file: file_names

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final VoidCallback onStartSearch;
  final VoidCallback onStopSearch;
  final VoidCallback onReload;
  final bool isLoading;

  const CustomAppBar({
    super.key,
    required this.isSearching,
    required this.searchController,
    required this.onStartSearch,
    required this.onStopSearch,
    required this.onReload,
    required this.isLoading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onStopSearch,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            Expanded(
              child: TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm nhà hàng...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          if (searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => searchController.clear(),
              tooltip: 'Xóa',
              color: Theme.of(context).colorScheme.onSurface,
            ),
        ],
      );
    } else {
      return AppBar(
        title: const Text("Trang chủ"),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: onStartSearch,
            tooltip: 'Tìm kiếm',
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : onReload,
            tooltip: 'Tải lại',
            color: Colors.white,
          ),
        ],
      );
    }
  }
}
