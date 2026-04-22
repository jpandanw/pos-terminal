import 'package:flutter/material.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/views/reciept.view.dart';
import 'package:signals/signals_flutter.dart';

@immutable
class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartState = makeTransactionRef(context);
    return Column(
      children: [
        Expanded(
          flex: 9,
          child: Watch(
            (_) => switch (cartState.cart.isEmpty) {
              false => _CartTable(cartState: cartState),
              true => Center(
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.remove_shopping_cart, size: 64),
                    Text("No items. Add items to cart."),
                  ],
                ),
              ),
            },
          ),
        ),

        const Divider(),
        Flexible(
          flex: 3,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total:"),
                  Watch(
                    (_) => Text(
                      "P${cartState.cartTotal.value.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontFamily: "monospace",
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Watch(
            (_) => Row(
              children: [
                if (cartState.heldCarts.isNotEmpty) ...[
                  OutlinedButton.icon(
                    onPressed: () => _showHeldCartsDialog(context, cartState),
                    icon: const Icon(Icons.list_alt),
                    label: Text("Held (${cartState.heldCarts.length})"),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: cartState.cart.isEmpty
                        ? null
                        : () => cartState.holdCurrentCart(),
                    child: const Text("Hold Cart"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: cartState.cart.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecieptView(),
                              ),
                            );
                          },
                    child: const Text("COMPLETE TRANSACTION"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _showHeldCartsDialog(
  BuildContext context,
  MakeTransactionState cartState,
) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Held Transactions"),
        content: SizedBox(
          width: 500,
          child: Watch((_) {
            if (cartState.heldCarts.isEmpty) {
              return const Text("No held transactions.");
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: cartState.heldCarts.length,
              itemBuilder: (context, index) {
                final held = cartState.heldCarts[index];
                final totalItems = held.fold<int>(
                  0,
                  (acc, item) => acc + item.quantity,
                );
                final totalCost = held.fold<double>(
                  0.0,
                  (acc, item) => acc + (item.product.price * item.quantity),
                );
                return ListTile(
                  title: Text(
                    "Cart #${index + 1} - $totalItems items",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text("Total: P${totalCost.toStringAsFixed(2)}"),
                  trailing: FilledButton(
                    onPressed: () {
                      cartState.resumeCart(index);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Resume"),
                  ),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}

class _CartTable extends StatelessWidget {
  const _CartTable({required this.cartState});

  final MakeTransactionState cartState;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: {
        0: FixedColumnWidth(24),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
        4: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,

      children: [
        TableRow(
          children: [
            TableCell(child: Container()),
            TableCell(child: Text("Name")),
            TableCell(child: Text("Price")),
            TableCell(child: Text("Subtotal")),
            TableCell(child: Text("Qty")),
          ],
        ),
        TableRow(
          children: [
            TableCell(child: Divider()),
            TableCell(child: Divider()),
            TableCell(child: Divider()),
            TableCell(child: Divider()),
            TableCell(child: Divider()),
          ],
        ),
        ...cartState.cart.indexed.map(
          (c) => TableRow(
            children: [
              TableCell(child: Text("${c.$1 + 1}.")),
              TableCell(
                child: Text(
                  c.$2.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              TableCell(
                child: Text("PHP ${c.$2.product.price.toStringAsFixed(2)}"),
              ),

              TableCell(
                child: Text(
                  "PHP ${(c.$2.quantity * c.$2.product.price).toStringAsFixed(2)}",
                ),
              ),

              TableCell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (c.$2.quantity <= 1) {
                          cartState.removeFromCart(product: c.$2.product);
                          return;
                        }
                        cartState.addToCart(
                          product: c.$2.product,
                          quantity: -1,
                        );
                      },

                      child: const Icon(Icons.remove),

                      onLongPress: () => {
                        cartState.removeFromCart(product: c.$2.product),
                      },
                    ),
                    Text(c.$2.quantity.toString()),
                    ElevatedButton(
                      onPressed: () {
                        cartState.addToCart(product: c.$2.product, quantity: 1);
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
