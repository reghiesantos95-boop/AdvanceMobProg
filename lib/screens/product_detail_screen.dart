import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_text.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: product.title,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            AspectRatio(
              aspectRatio: 1.1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    product.images.isNotEmpty
                        ? product.images.first
                        : product.thumbnail,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported, size: 40);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(icon: Icons.category, label: product.category),
                _InfoChip(
                  icon: Icons.inventory_2,
                  label: '${product.stock} in stock',
                ),
                _InfoChip(
                  icon: Icons.star,
                  label: product.rating.toStringAsFixed(1),
                ),
              ],
            ),
            const SizedBox(height: 18),
            CustomText(
              text: product.title,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CustomText(
                  text: formatPesoPrice(product.price),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
                const SizedBox(width: 10),
                CustomText(
                  text: '${product.discountPercentage.toStringAsFixed(1)}% off',
                  fontSize: 13,
                  color: colors.tertiary,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomText(
              text: product.description,
              fontSize: 15,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                // Enhancement 3: detail screen also supports adding the
                // selected product to the user cart.
                onPressed: () => _addToCart(context),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
              ),
            ),
            const SizedBox(height: 20),
            _DetailSection(
              title: 'Product Details',
              rows: [
                _DetailRow(
                  'Brand',
                  product.brand.isEmpty ? 'N/A' : product.brand,
                ),
                _DetailRow('SKU', product.sku),
                _DetailRow('Weight', '${product.weight.toStringAsFixed(1)} kg'),
                _DetailRow(
                  'Dimensions',
                  '${product.dimensions.width.toStringAsFixed(1)} x '
                      '${product.dimensions.height.toStringAsFixed(1)} x '
                      '${product.dimensions.depth.toStringAsFixed(1)}',
                ),
              ],
            ),
            const SizedBox(height: 14),
            _DetailSection(
              title: 'Delivery',
              rows: [
                _DetailRow('Availability', product.availabilityStatus),
                _DetailRow('Shipping', product.shippingInformation),
                _DetailRow('Warranty', product.warrantyInformation),
                _DetailRow('Return Policy', product.returnPolicy),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(BuildContext context) async {
    try {
      await context.read<CartProvider>().addProduct(product);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${product.title} added to cart')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to add item: $error')));
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: CustomText(text: label, fontSize: 12),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.rows});

  final String title;
  final List<_DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: title, fontSize: 16, fontWeight: FontWeight.w800),
            const SizedBox(height: 10),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: CustomText(
                        text: row.label,
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: CustomText(
                        text: row.value.isEmpty ? 'N/A' : row.value,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;
}
