import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/cart.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  CartProvider() {
    _cart = Cart.empty(_userId);
  }

  final CartService _cartService = CartService();

  Cart? _cart;
  int _userId = cartUserId;
  bool _isLoading = false;
  String? _errorMessage;

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _cart?.totalQuantity ?? 0;
  int get userId => _userId;

  Future<void> loadUserCart() async {
    await loadCartForUser(_userId);
  }

  Future<void> loadCartForUser(int userId) async {
    // Enhancement 3: saved user id determines which cart endpoint is rendered.
    _userId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await _cartService.getCartByUserId(userId);
    } catch (error) {
      _errorMessage = error.toString();
      _cart = Cart.empty(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _userId = cartUserId;
    _cart = Cart.empty(_userId);
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    _addProductLocally(product);
    notifyListeners();

    // Enhancement 3: call DummyJSON /carts/add with product id and quantity.
    // The demo API does not persist carts, so local state drives added items.
    try {
      await _cartService.addToCart(
        userId: _userId,
        productId: product.id,
        quantity: 1,
      );
    } catch (_) {
      // Keep the locally added item visible even if the API call fails.
    }
  }

  void increaseQuantity(int productId) {
    _updateQuantity(productId, 1);
  }

  void decreaseQuantity(int productId) {
    _updateQuantity(productId, -1);
  }

  void _updateQuantity(int productId, int delta) {
    final currentCart = _cart ?? Cart.empty(_userId);
    final updatedProducts = [...currentCart.products];
    final index = updatedProducts.indexWhere((item) => item.id == productId);

    if (index == -1) {
      return;
    }

    final item = updatedProducts[index];
    final nextQuantity = item.quantity + delta;

    if (nextQuantity <= 0) {
      updatedProducts.removeAt(index);
    } else {
      final nextTotal = item.price * nextQuantity;
      final nextDiscountedTotal =
          nextTotal * (1 - (item.discountPercentage / 100));

      updatedProducts[index] = item.copyWith(
        quantity: nextQuantity,
        total: nextTotal,
        discountedTotal: nextDiscountedTotal,
      );
    }

    _cart = _buildCart(currentCart, updatedProducts);
    notifyListeners();
  }

  void _addProductLocally(Product product) {
    final currentCart = _cart ?? Cart.empty(_userId);
    final updatedProducts = [...currentCart.products];
    final existingIndex = updatedProducts.indexWhere(
      (item) => item.id == product.id,
    );

    if (existingIndex == -1) {
      updatedProducts.add(CartProduct.fromProduct(product));
    } else {
      final item = updatedProducts[existingIndex];
      final nextQuantity = item.quantity + 1;
      final nextTotal = item.price * nextQuantity;
      final nextDiscountedTotal =
          nextTotal * (1 - (item.discountPercentage / 100));

      updatedProducts[existingIndex] = item.copyWith(
        quantity: nextQuantity,
        total: nextTotal,
        discountedTotal: nextDiscountedTotal,
      );
    }

    _cart = _buildCart(currentCart, updatedProducts);
  }

  Cart _buildCart(Cart currentCart, List<CartProduct> updatedProducts) {
    final total = updatedProducts.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );
    final discountedTotal = updatedProducts.fold<double>(
      0,
      (sum, item) => sum + item.discountedTotal,
    );
    final totalQuantity = updatedProducts.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return currentCart.copyWith(
      products: updatedProducts,
      total: total,
      discountedTotal: discountedTotal,
      totalProducts: updatedProducts.length,
      totalQuantity: totalQuantity,
    );
  }
}
