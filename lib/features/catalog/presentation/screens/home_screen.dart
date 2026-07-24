import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grupo_exito_catalog_test/features/cart/presentation/providers/cart_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/widgets/category_card.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/widgets/express_switcher.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CatalogProvider>().loadCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalogProvider = context.watch<CatalogProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cartProvider.cartBadgeColor,
        elevation: 0,
        title: const Text('Ecommerce App'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              // Envolvemos el Chip con InkWell para habilitar el clic y navegación
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  context.push('/cart');
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Chip(
                    backgroundColor: Colors.white,
                    avatar: Icon(
                      Icons.shopping_cart,
                      color: cartProvider.cartBadgeColor,
                      size: 20,
                    ),
                    label: Text(
                      '${cartProvider.totalActiveUnits} und',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (cartProvider.canShowExpressOption()) ...[
              const ExpressSwitcher(),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade100,
              child: Row(
                children: const [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.black87,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '¿Cómo quieres recibir tu pedido?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.edit, size: 16, color: Colors.black54),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Grilla cuadrada',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Ver todos',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (catalogProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (catalogProvider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade400,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(catalogProvider.errorMessage!),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => context
                                .read<CatalogProvider>()
                                .loadCategories(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (catalogProvider.categories.isEmpty) {
                    return const Center(
                      child: Text('No hay categorías disponibles.'),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.95,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: catalogProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = catalogProvider.categories[index];
                          return CategoryCard(categoryName: category);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
