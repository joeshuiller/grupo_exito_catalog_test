import 'package:flutter/material.dart';
import 'package:grupo_exito_catalog_test/core/network/http_client.dart';
import 'package:grupo_exito_catalog_test/core/router/app_router.dart';
import 'package:grupo_exito_catalog_test/core/theme/app_theme.dart';
import 'package:grupo_exito_catalog_test/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:grupo_exito_catalog_test/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:grupo_exito_catalog_test/features/cart/presentation/providers/cart_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/data/datasources/catalog_remote_datasource.dart';
import 'package:grupo_exito_catalog_test/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/usecases/get_categories.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/usecases/get_products_by_category.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inyección de dependencias para Catálogo
  final customHttpClient = HttpClient();
  final catalogRemoteDataSource = CatalogRemoteDataSourceImpl(
    client: customHttpClient,
  );
  final catalogRepository = CatalogRepositoryImpl(
    remoteDataSource: catalogRemoteDataSource,
  );

  // Inyección de dependencias para Carrito
  final cartLocalDataSource = CartLocalDataSourceImpl();
  final cartRepository = CartRepositoryImpl(
    localDataSource: cartLocalDataSource,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(
            getCategoriesUseCase: GetCategories(catalogRepository),
            getProductsByCategoryUseCase: GetProductsByCategory(
              catalogRepository,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CartProvider(cartRepository: cartRepository)..loadCarts(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ecommerce Clean Architecture',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
