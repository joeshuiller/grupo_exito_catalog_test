import 'package:flutter/material.dart';
import 'package:grupo_exito_catalog_test/features/cart/presentation/providers/cart_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/widgets/product_card.dart';
import 'package:provider/provider.dart';

class ProductsByCategoryScreen extends StatefulWidget {
  static const String routeName = 'products-by-category';
  final String categoryName;

  const ProductsByCategoryScreen({super.key, required this.categoryName});

  @override
  State<ProductsByCategoryScreen> createState() =>
      _ProductsByCategoryScreenState();
}

class _ProductsByCategoryScreenState extends State<ProductsByCategoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<CatalogProvider>(
        context,
        listen: false,
      ).loadProductsByCategory(widget.categoryName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogProvider = Provider.of<CatalogProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cartProvider.cartBadgeColor,
        title: Text(widget.categoryName.toUpperCase()),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;

          if (catalogProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (catalogProvider.errorMessage != null) {
            return Center(child: Text(catalogProvider.errorMessage!));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.68,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: catalogProvider.products.length,
            itemBuilder: (context, index) {
              final product = catalogProvider.products[index];
              return ProductCard(product: product);
            },
          );
        },
      ),
    );
  }
}
