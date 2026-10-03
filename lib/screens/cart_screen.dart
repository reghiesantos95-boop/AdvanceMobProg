import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/cart.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'product_detail_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const Color _accentOrange = Color(0xFFF57C00);
  static const Color _accentYellow = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;

    return SafeArea(
      child: Builder(
        builder: (context) {
          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      text: 'Error: ${cartProvider.errorMessage}',
                      fontSize: 14,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<CartProvider>().loadUserCart(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (cart == null || cart.products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    const CustomText(
                      text: 'Your cart is empty',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    CustomText(
                      text:
                          'No cart items for this user. Add items from Shop or tap Retry.',
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: CustomText(
                  text: 'Cart loaded using saved user id: ${cart.userId}',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  itemCount: cart.products.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final product = cart.products[index];
                    return _CartItemCard(
                      product: product,
                      onIncrease: () => context
                          .read<CartProvider>()
                          .increaseQuantity(product.id),
                      onDecrease: () => context
                          .read<CartProvider>()
                          .decreaseQuantity(product.id),
                      onTap: () => _openProductDetail(context, product.id),
                    );
                  },
                ),
              ),
              _CartSummary(
                subtotal: cart.discountedTotal,
                onConfirm: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order confirmed!')),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openProductDetail(BuildContext context, int productId) async {
    // Enhancement 1: cart API items are clickable and reuse ProductDetailScreen.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final Product product = await ProductService().getProductById(productId);

      if (!context.mounted) {
        return;
      }

      Navigator.pop(context);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to open product: $error')));
    }
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.product,
    required this.onIncrease,
    required this.onDecrease,
    required this.onTap,
  });

  final CartProduct product;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.thumbnail,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 72,
                      height: 72,
                      color: colors.surfaceContainerHighest,
                      child: const Icon(Icons.image_not_supported, size: 24),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: product.title,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    CustomText(
                      text: formatPesoPrice(product.price),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: CartScreen._accentOrange,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      text:
                          '${product.discountPercentage.toStringAsFixed(0)}% off - '
                          '${formatPesoPrice(product.discountedTotal)} total',
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  _QuantityButton(
                    icon: Icons.add,
                    backgroundColor: CartScreen._accentYellow,
                    iconColor: Colors.black87,
                    onPressed: onIncrease,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: CustomText(
                      text: '${product.quantity}',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  _QuantityButton(
                    icon: Icons.remove,
                    backgroundColor: colors.surfaceContainerHighest,
                    iconColor: colors.onSurfaceVariant,
                    onPressed: onDecrease,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onPressed,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.subtotal, required this.onConfirm});

  final double subtotal;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                text: 'Subtotal:',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              CustomText(
                text: formatPesoPrice(subtotal),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CartScreen._accentOrange,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: CartScreen._accentYellow,
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const CustomText(
                text: 'Confirm Order',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
