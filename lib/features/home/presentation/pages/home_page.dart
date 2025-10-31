import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timnhahang/features/home/data/data/restaurant_remote_datasource.dart';
import 'package:timnhahang/features/home/data/repositories/restaurant_repository_impl.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';
import 'package:timnhahang/features/home/domain/usecase/get_all_restaurant.dart';
// Giả định: Bạn cần import UseCase tìm kiếm
import 'package:timnhahang/features/home/domain/usecase/search_restaurant.dart';
import 'package:timnhahang/features/home/domain/usecase/update_restaurant.dart';
import 'package:timnhahang/features/home/presentation/widgets/home/customer_appBar_homepages.dart';
import 'package:timnhahang/features/home/presentation/pages/detail_restaurant.dart';
import 'package:timnhahang/features/home/presentation/widgets/home/empty_result.dart';
import 'package:timnhahang/features/home/presentation/widgets/home/restaurant_gridview.dart';
import 'package:timnhahang/features/home/presentation/widgets/home/restaurant_not_found.dart';
import 'package:timnhahang/features/home/presentation/widgets/home/srearch_result_list.dart';

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

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentList = _isSearching ? _searchResults : listRestaurants;

    if (currentList.isEmpty) {
      return _isSearching ? NoResult() : EmptyResult();
    }

    if (_isSearching) {
      return SrearchResultList(
        currentList: currentList, 
        loadRestaurants: _loadRestaurants, 
        openDetailRestaurant: openDetailRestaurant,
        );
    } else {
      return RestaurantGridview(
        currentList: currentList, 
        loadRestaurants: _loadRestaurants, 
        openDetailRestaurant: openDetailRestaurant,
      );
    }
  }
}