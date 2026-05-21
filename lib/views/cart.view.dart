import 'package:flutter/material.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/states/restriction.state.dart';
import 'package:pos_terminal/views/dialogs/customer_money.dialog.dart';
import 'package:pos_terminal/views/dialogs/change_quantity.dialog.dart';
import 'package:pos_terminal/views/dialogs/customer_card.dialog.dart';
import 'package:pos_terminal/views/dialogs/supervisor_validation.dialog.dart';
import 'package:pos_terminal/views/total.view.dart';
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
        Flexible(flex: 3, child: Column(children: [const TotalView()])),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Watch(
            (context) => Column(
              children: [
                if (cartState.customerName.value != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Customer:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(cartState.customerName.value!),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            cartState.customerId.value = null;
                            cartState.customerName.value = null;
                          },
                        )
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const CustomerCardDialog(),
                      );
                    },
                    icon: const Icon(Icons.credit_card),
                    label: Text(cartState.customerName.value == null ? "ADD CUSTOMER CARD" : "CHANGE CUSTOMER CARD"),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: cartState.cart.isEmpty
                        ? null
                        : () {
                            cartState.customerMoney.value = null; // reset
                            showDialog(
                              context: context,
                              builder: (context) => const CustomerMoneyDialog(),
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
                        final restriction = restrictionStateRef(context);

                        void executeAction() {
                          if (c.$2.quantity <= 1) {
                            cartState.removeFromCart(product: c.$2.product);
                          } else {
                            cartState.addToCart(
                              product: c.$2.product,
                              quantity: -1,
                            );
                          }
                        }

                        if (restriction.isAuthorized) {
                          executeAction();
                          restriction.useAuthorization();
                        } else {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => SupervisorValidationDialog(
                              actionDescription: c.$2.quantity <= 1 
                                  ? "remove '${c.$2.product.name}'" 
                                  : "reduce quantity of '${c.$2.product.name}'",
                              onSuccess: executeAction,
                            ),
                          );
                        }
                      },

                      child: const Icon(Icons.remove),

                      onLongPress: () {
                        final restriction = restrictionStateRef(context);

                        void executeAction() {
                          cartState.removeFromCart(product: c.$2.product);
                        }

                        if (restriction.isAuthorized) {
                          executeAction();
                          restriction.useAuthorization();
                        } else {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => SupervisorValidationDialog(
                              actionDescription: "remove '${c.$2.product.name}'",
                              onSuccess: executeAction,
                            ),
                          );
                        }
                      },
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => ChangeQuantityDialog(
                            product: c.$2.product,
                            currentQuantity: c.$2.quantity,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          c.$2.quantity.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
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
