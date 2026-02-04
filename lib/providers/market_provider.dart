import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/product_model.dart';
import '../core/services/logger_service.dart';

class MarketProvider with ChangeNotifier {
  List<Product> _products = [];
  List<CartItem> _cartItems = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  List<Product> get products => _products;
  List<CartItem> get cartItems => _cartItems;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  List<String> get categories => [
    'All',
    'Seeds',
    'Fertilizers',
    'Tools',
    'Equipment',
    'Pesticides',
    'Organic',
    'Other',
  ];

  MarketProvider() {
    _loadProducts();
    _loadCart();
  }

  List<Product> get filteredProducts {
    var filtered = _products;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }

    return filtered;
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = await Hive.openBox('products');
      final savedProducts = box.get('product_list', defaultValue: []);
      
      if (savedProducts is List && savedProducts.isNotEmpty) {
        _products = savedProducts
            .map((p) => Product.fromJson(Map<String, dynamic>.from(p)))
            .toList();
      } else {
        // Add sample products
        _products = _getSampleProducts();
        await _saveProducts();
      }
    } catch (e, stackTrace) {
      logger.error(
        'Failed to load products',
        tag: 'MarketProvider',
        error: e,
        stackTrace: stackTrace,
      );
      _products = _getSampleProducts();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveProducts() async {
    try {
      final box = await Hive.openBox('products');
      await box.put('product_list', _products.map((p) => p.toJson()).toList());
    } catch (e, stackTrace) {
      logger.error(
        'Failed to save products',
        tag: 'MarketProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _loadCart() async {
    try {
      final box = await Hive.openBox('cart');
      final savedCart = box.get('cart_items', defaultValue: []);
      
      if (savedCart is List) {
        _cartItems = savedCart
            .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        notifyListeners();
      }
    } catch (e, stackTrace) {
      logger.error(
        'Failed to load cart',
        tag: 'MarketProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _saveCart() async {
    try {
      final box = await Hive.openBox('cart');
      await box.put('cart_items', _cartItems.map((item) => item.toJson()).toList());
    } catch (e, stackTrace) {
      logger.error(
        'Failed to save cart',
        tag: 'MarketProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> addProduct(Product product) async {
    _products.insert(0, product);
    await _saveProducts();
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      await _saveProducts();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((p) => p.id == productId);
    await _saveProducts();
    notifyListeners();
  }

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    _saveCart();
    notifyListeners();
  }

  void updateCartItemQuantity(String productId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    
    if (index != -1) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = quantity;
      }
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    _saveCart();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  int getCartQuantity(String productId) {
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: Product(
        id: '',
        name: '',
        description: '',
        price: 0,
        imageUrl: '',
        category: '',
        sellerId: '',
        sellerName: '',
        createdAt: DateTime.now(),
      ), quantity: 0),
    );
    return item.quantity;
  }

  List<Product> _getSampleProducts() {
    return [
      Product(
        id: '1',
        name: 'Hybrid Maize Seeds',
        description: 'High-yield hybrid maize seeds suitable for various climates. Resistant to common pests and diseases. Expected harvest in 90-100 days.',
        price: 1500.0,
        imageUrl: 'https://images.unsplash.com/photo-1603048297172-c92544798d5a?w=800',
        category: 'Seeds',
        sellerId: 'seller1',
        sellerName: 'AgroSeeds Ltd',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        stock: 50,
        tags: ['maize', 'hybrid', 'high-yield'],
        rating: 4.5,
        reviewCount: 23,
      ),
      Product(
        id: '2',
        name: 'NPK Fertilizer 20kg',
        description: 'Complete NPK fertilizer (20-10-10) for all crops. Improves soil fertility and crop yield. Suitable for vegetables, fruits, and grains.',
        price: 3500.0,
        imageUrl: 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=800',
        category: 'Fertilizers',
        sellerId: 'seller2',
        sellerName: 'FarmSupply Co',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        stock: 100,
        tags: ['fertilizer', 'NPK', 'organic'],
        rating: 4.8,
        reviewCount: 45,
      ),
      Product(
        id: '3',
        name: 'Garden Hoe',
        description: 'Durable steel garden hoe with wooden handle. Perfect for weeding, cultivating, and preparing soil. Rust-resistant coating.',
        price: 850.0,
        imageUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800',
        category: 'Tools',
        sellerId: 'seller3',
        sellerName: 'Farm Tools Direct',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        stock: 30,
        tags: ['tool', 'hoe', 'gardening'],
        rating: 4.3,
        reviewCount: 12,
      ),
      Product(
        id: '4',
        name: 'Tomato Seeds - Organic',
        description: 'Organic heirloom tomato seeds. Disease-resistant variety with excellent flavor. Perfect for home gardens and commercial farming.',
        price: 250.0,
        imageUrl: 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=800',
        category: 'Seeds',
        sellerId: 'seller1',
        sellerName: 'AgroSeeds Ltd',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        stock: 200,
        tags: ['tomato', 'organic', 'seeds'],
        rating: 4.7,
        reviewCount: 67,
      ),
      Product(
        id: '5',
        name: 'Organic Pesticide 1L',
        description: 'Natural organic pesticide for controlling pests without harmful chemicals. Safe for vegetables and fruits. Biodegradable formula.',
        price: 1200.0,
        imageUrl: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800',
        category: 'Pesticides',
        sellerId: 'seller2',
        sellerName: 'FarmSupply Co',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        stock: 75,
        tags: ['pesticide', 'organic', 'eco-friendly'],
        rating: 4.6,
        reviewCount: 34,
      ),
      Product(
        id: '6',
        name: 'Water Pump - Electric',
        description: 'High-efficiency electric water pump for irrigation. 1HP motor with 50m delivery head. Durable and energy-efficient.',
        price: 12500.0,
        imageUrl: 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=800',
        category: 'Equipment',
        sellerId: 'seller3',
        sellerName: 'Farm Tools Direct',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        stock: 15,
        tags: ['pump', 'irrigation', 'equipment'],
        rating: 4.9,
        reviewCount: 28,
      ),
    ];
  }

  Future<void> refreshProducts() async {
    await _loadProducts();
  }
}
