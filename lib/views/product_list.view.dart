import 'package:flutter/material.dart';
import 'package:pos_terminal/states/load_data.state.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/types/product.type.dart';
import 'package:signals/signals_flutter.dart';

final _selectedCategory = signal<Category?>(null);

@immutable
class ProductListView extends StatelessWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    final fetchData = fetchDataRef(context);
    return Column(
      spacing: 16,
      children: [
        SearchBar(
          hintText: "Search Product Name, SKU, or Barcode....",
          leading: const Icon(Icons.search),
        ),
        Expanded(
          child: Watch((context) {
            return switch (_selectedCategory.value) {
              null => GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                ),
                itemCount: fetchData.categories.length,
                itemBuilder: (context, index) => _CategoryCard(
                  index: index,
                  onClick: () {
                    _selectedCategory.value = fetchData.categories[index];
                  },
                ),
              ),
              _ => Scaffold(
                appBar: AppBar(
                  leading: TextButton.icon(
                    onPressed: () {
                      _selectedCategory.value = null;
                    },
                    label: const Icon(Icons.arrow_left_rounded),
                  ),
                  title: Text(_selectedCategory.value!.name),
                ),
                body: Watch((_) {
                  final productList = fetchData.products
                      .where((p) => true)
                      .toList();

                  return ListView.builder(
                    itemCount: productList.length,
                    itemBuilder: (context, index) => Card(
                      child: ListTile(
                        title: Text(productList[index].name),
                        subtitle: Flex(
                          direction: Axis.horizontal,
                          children: [
                            Text("Barcode: ${productList[index].barcode}"),
                          ],
                        ),
                        trailing: Text(
                          "P${productList[index].price.toStringAsFixed(2)}",
                        ),
                        onTap: () {
                          makeTransactionRef(
                            context,
                          ).addToCart(product: productList[index], quantity: 1);
                        },
                      ),
                    ),
                  );
                }),
              ),
            };
          }),
        ),
        Divider(),
        SizedBox(
          height: 64,
          child: Flex(
            direction: Axis.horizontal,
            spacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () {},
                label: const Text("Hold Transaction"),
                icon: Icon(Icons.holiday_village),
              ),

              FilledButton.icon(
                onPressed: () {},
                label: const Text("Restore Transactions"),
                icon: Icon(Icons.holiday_village),
              ),

              FilledButton.icon(
                onPressed: () {},
                label: const Text("Clear Cart"),
                icon: Icon(Icons.holiday_village),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

@immutable
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.index, required this.onClick});
  final int index;
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    final fetchData = fetchDataRef(context);
    return InkWell(
      onTap: () {
        onClick();
      },
      child: Card.outlined(
        elevation: 4,
        child: Center(
          child: Text(
            fetchData.categories[index].name,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
