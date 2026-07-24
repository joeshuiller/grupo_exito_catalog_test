import 'package:flutter/material.dart';
import 'package:grupo_exito_catalog_test/features/cart/presentation/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class ExpressSwitcher extends StatelessWidget {
  const ExpressSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: cartProvider.isExpressActive
          ? Colors.deepOrange.shade50
          : Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt,
                color: cartProvider.isExpressActive
                    ? Colors.deepOrange
                    : Colors.amber.shade900,
              ),
              const SizedBox(width: 8),
              const Text(
                'Activar la experiencia express',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Switch(
            value: cartProvider.isExpressActive,
            activeColor: Colors.deepOrange,
            activeTrackColor: Colors.deepOrange.shade200,
            onChanged: (value) {
              cartProvider.toggleExpressMode(value);
            },
          ),
        ],
      ),
    );
  }
}
