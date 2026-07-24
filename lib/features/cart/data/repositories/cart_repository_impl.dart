import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../data/datasources/cart_local_datasource.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CartItem>> getStandardCart() async {
    try {
      return localDataSource.getStandardCart();
    } on ServerException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw const CacheFailure(
        'Error inesperado al cargar el carrito estándar',
      );
    }
  }

  @override
  Future<List<CartItem>> getExpressCart() async {
    try {
      return localDataSource.getExpressCart();
    } on ServerException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw const CacheFailure('Error inesperado al cargar el carrito express');
    }
  }

  @override
  Future<void> addProduct(Product product, {required bool isExpress}) async {
    try {
      localDataSource.addProduct(product, isExpress: isExpress);
    } on ServerException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw const CacheFailure('Error al agregar el producto al carrito');
    }
  }

  @override
  Future<void> removeProduct(int productId, {required bool isExpress}) async {
    try {
      localDataSource.removeProduct(productId, isExpress: isExpress);
    } on ServerException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw const CacheFailure('Error al remover el producto del carrito');
    }
  }

  @override
  Future<void> clearCart({required bool isExpress}) async {
    try {
      localDataSource.clearCart(isExpress: isExpress);
    } on ServerException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw const CacheFailure('Error al vaciar el carrito');
    }
  }
}
