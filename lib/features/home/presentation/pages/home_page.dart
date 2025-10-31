import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timnhahang/features/home/data/data/restaurant_remote_datasource.dart';
import 'package:timnhahang/features/home/data/repositories/restaurant_repository_impl.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';
import 'package:timnhahang/features/home/domain/usecase/get_all_restaurant.dart';
// Giả định: Bạn cần import UseCase tìm kiếm
import 'package:timnhahang/features/home/domain/usecase/search_restaurant.dart';
import 'package:timnhahang/features/home/domain/usecase/update_restaurant.dart';
import 'package:timnhahang/features/home/presentation/pages/customer_appBar_homepages.dart';
import 'package:timnhahang/features/home/presentation/pages/detail_restaurant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- Use Cases ---
  late final _remote = RestaurantsRemoteDataSourceImpl();
  late final _repo = RestaurantRepositoryImpl(_remote);

  late final _getAllRestaurants = GetAllRestaurants(_repo);
  late final _updateRestaurant = UpdateRestaurant(_repo);
  late final _searchRestaurant = SearchRestaurant(_repo);

  // --- Biến trạng thái ---
  bool isLoading = true;
  List<Restaurant> listRestaurants = [];

  // --- Biến trạng thái cho tìm kiếm ---
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<Restaurant> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // --- Các hàm logic ---
  Future<void> _loadRestaurants() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final restaurants = await _getAllRestaurants();
      if (mounted) {
        setState(() {
          listRestaurants = restaurants;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void openDetailRestaurant(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailRestaurantPage(
          restaurant: restaurant,
          updateRestaurant: _updateRestaurant,
        ),
      ),
    );
  }

  // --- Các hàm logic cho tìm kiếm ---
  void _onSearchChanged() {
    _performSearch(_searchController.text);
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      if (mounted) setState(() => _searchResults = []);
      return;
    }
    final results = await _searchRestaurant(query);
    if (mounted) {
      setState(() => _searchResults = results);
    }
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchResults = [];
    });
  }

  // --- BUILD UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isSearching: _isSearching,
        searchController: _searchController,
        onStartSearch: _startSearch,
        onStopSearch: _stopSearch,
        onReload: _loadRestaurants,
        isLoading: isLoading,
      ), 
      body: _buildBody()
      );
  }

  // --- BUILD BODY (ĐÃ CẬP NHẬT) ---
  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentList = _isSearching ? _searchResults : listRestaurants;

    if (currentList.isEmpty) {
      return _isSearching ? _buildNoResultsState() : _buildEmptyState();
    }

    // TÁCH BIỆT LOGIC HIỂN THỊ
    if (_isSearching) {
      // 1. Khi tìm kiếm: Hiển thị dạng DANH SÁCH (ListView)
      return _buildSearchResultsList(currentList);
    } else {
      // 2. Khi bình thường: Hiển thị dạng LƯỚI (GridView)
      return _buildRestaurantGrid(currentList);
    }
  }

  // --- WIDGET MỚI: HIỂN THỊ DẠNG LƯỚI (GridView) ---
  Widget _buildRestaurantGrid(List<Restaurant> restaurants) {
    return RefreshIndicator(
      onRefresh: _loadRestaurants,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: restaurants.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            childAspectRatio: 0.75, // Tỷ lệ cho GridView
          ),
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            // Card cho GridView (Dùng Expanded cho ảnh)
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  openDetailRestaurant(restaurant);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      // Dùng Expanded
                      child: Image.network(
                        restaurant.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            restaurant.address,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET MỚI: HIỂN THỊ DẠNG DANH SÁCH (ListView) ---
  Widget _buildSearchResultsList(List<Restaurant> restaurants) {
    return RefreshIndicator(
      onRefresh: _loadRestaurants, // Vẫn cho phép kéo để làm mới
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0), // Padding cho cả danh sách
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          // Card cho ListView (Dùng Row: Ảnh bên trái, Text bên phải)
          return Card(
            margin: const EdgeInsets.only(
              bottom: 8.0,
            ), // Khoảng cách giữa các item
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                openDetailRestaurant(restaurant);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Padding bao quanh Row
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trên
                  children: [
                    // 1. Hình ảnh (Bên trái)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        restaurant.imageUrl,
                        fit: BoxFit.cover,
                        width: 100, // Chiều rộng cố định
                        height: 100, // Chiều cao cố định
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12), // Khoảng cách giữa ảnh và chữ
                    // 2. Thông tin (Bên phải)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2, // Tên tối đa 2 dòng
                          ),
                          const SizedBox(height: 8),
                          Text(
                            restaurant.address,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                            maxLines: 3, // Địa chỉ tối đa 3 dòng
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Widget trạng thái rỗng (Giữ nguyên) ---
  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy nhà hàng',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng thử từ khóa khác.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_outlined, // Đổi icon cho phù hợp
            size: 80,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có nhà hàng nào',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Kéo xuống để tải lại danh sách.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
