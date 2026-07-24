import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:grupo_exito_catalog_test/features/catalog/presentation/widgets/category_card.dart';

void main() {
  const tCategoryName = 'electronics';

  Widget buildWidgetUnderTest({required String categoryName}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              Scaffold(body: CategoryCard(categoryName: categoryName)),
        ),
        GoRoute(
          path: '/category/:categoryName',
          builder: (context, state) {
            final categoryParam = state.pathParameters['categoryName'];
            return Scaffold(
              body: Text('Pantalla de Categoría: $categoryParam'),
            );
          },
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  group('CategoryCard - Widget Tests', () {
    testWidgets(
      'Debe mostrar el nombre de la categoría en mayúsculas e icono representativo',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidgetUnderTest(categoryName: tCategoryName),
        );
        await tester.pumpAndSettle();

        // Verifica el formato en mayúsculas
        expect(find.text('ELECTRONICS'), findsOneWidget);
        expect(find.byIcon(Icons.category), findsOneWidget);
      },
    );

    testWidgets(
      'Tocar la tarjeta debe navegar hacia la ruta /category/:categoryName con el parámetro correspondiente',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidgetUnderTest(categoryName: tCategoryName),
        );
        await tester.pumpAndSettle();

        final cardFinder = find.byType(InkWell);
        expect(cardFinder, findsOneWidget);

        await tester.tap(cardFinder);
        await tester.pumpAndSettle();

        // Verifica la navegación correcta pasándole el parámetro 'electronics'
        expect(find.text('Pantalla de Categoría: electronics'), findsOneWidget);
      },
    );
  });
}
