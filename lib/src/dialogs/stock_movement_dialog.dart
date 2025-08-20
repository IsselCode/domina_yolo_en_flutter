import 'package:flutter/material.dart';

import '../../core/app/enums.dart';

class MovementResult {
  final DeltaType deltaType;
  final int quantity;
  MovementResult(this.deltaType, this.quantity);
}

/// Muestra el diálogo y devuelve el movimiento elegido, o null si se cancela.
Future<MovementResult?> stockMovementDialog({
  required BuildContext context,
  required String productName,
  required int available,
}) {
  return showDialog<MovementResult>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      int delta = 0; // puede ser negativo (baja) o positivo (alta)
      return StatefulBuilder(
        builder: (context, setState) {

          TextTheme textTheme = Theme.of(context).textTheme;
          ColorScheme colorScheme = Theme.of(context).colorScheme;

          final isDecrease = delta < 0;
          final isIncrease = delta > 0;
          final absQty = delta.abs();

          final exceeds = isDecrease && absQty > available;
          final canConfirm = delta != 0 && !exceeds;

          String movementLabel;
          if (delta == 0) {
            movementLabel = '—';
          } else if (isIncrease) {
            movementLabel = DeltaType.increase.label; // "Incremento"
          } else {
            movementLabel = DeltaType.decrease.label; // "Decremento"
          }

          void inc() => setState(() => delta += 1);
          void dec() => setState(() => delta -= 1);

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Actualizar: $productName'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cantidad disponible
                Text('Disponible: $available', style: textTheme.titleMedium),

                const SizedBox(height: 12),

                // Contador
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decrementar
                    IconButton(
                      onPressed: dec,
                      icon: const Icon(Icons.remove),
                    ),
                    // Cantidad
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Text(
                        '$delta',
                        style: textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: inc,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Tipo de movimiento
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Movimiento: ', style: textTheme.bodyMedium),
                    Text(
                      movementLabel,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isIncrease
                          ? Colors.green
                          : isDecrease
                          ? Colors.orange
                          : null
                      ),
                    ),
                  ],
                ),

                // Advertencia si excede disponible
                if (exceeds) ...[
                  const SizedBox(height: 8),
                  Text(
                    'No puedes decrementar más de lo disponible.',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: canConfirm
                    ? () {
                  final type = delta > 0 ? DeltaType.increase : DeltaType.decrease;
                  final qty = delta.abs();
                  Navigator.pop(context, MovementResult(type, qty));
                } : null,
                child: const Text('Actualizar'),
              ),
            ],
          );
        },
      );
    },
  );
}
