import 'package:flutter/material.dart';
import 'package:pos_terminal/states/load_data.state.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/states/products_loaded.state.dart';
import 'package:pos_terminal/types/product.type.dart';
import 'package:pos_terminal/views/make_transactions_actions.view.dart';
import 'package:signals/signals_flutter.dart';

final _selectedCategory = signal<String?>(null);
final _searchQuery = signal<String>('');

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      untracked(() {
        _searchQuery.value = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    untracked(() {
      _searchQuery.value = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final fetchData = fetchDataRef(context);
    return Column(
      spacing: 16,
      children: [
        SearchBar(
          controller: _searchController,
          hintText: 'Search Product Name, SKU, or Barcode...',
          leading: const Icon(Icons.search),
          trailing: [
            Watch((context) {
              final query = _searchQuery.value;
              if (query.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear search',
                onPressed: _clearSearch,
              );
            }),
          ],
        ),
        Expanded(
          child: Watch((context) {
            final query = _searchQuery.value;
            final selectedCategory = _selectedCategory.value;
            final categories = fetchData.categories.value;

            // — Search mode: show results globally across all products —
            if (query.isNotEmpty) {
              final results =
                  productsLoadedRef(context).searchProducts(query);
              return _ProductList(
                products: results,
                emptyMessage: 'No products match "$query"',
              );
            }

            // — Category not yet selected: show category grid —
            if (selectedCategory == null) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                ),
                itemCount: categories.length + 1, // +1 for Uncategorized
                itemBuilder: (context, index) {
                  if (index == categories.length) {
                    return _UncategorizedCard(
                      onClick: () {
                        untracked(() {
                          _selectedCategory.value = 'uncategorized';
                        });
                      },
                    );
                  }
                  return _CategoryCard(
                    category: categories[index],
                    onClick: () {
                      untracked(() {
                        _selectedCategory.value = categories[index].id;
                      });
                    },
                  );
                },
              );
            }

            // — Category selected: show its products —
            final productList =
                productsLoadedRef(context).getProductsByCategory(
              selectedCategory,
            );
            return Scaffold(
              appBar: AppBar(
                leading: TextButton.icon(
                  onPressed: () {
                    untracked(() {
                      _selectedCategory.value = null;
                    });
                    _clearSearch();
                  },
                  label: const Icon(Icons.arrow_left_rounded),
                ),
                title: Text(_getCategoryName(categories, selectedCategory)),
              ),
              body: _ProductList(
                products: productList,
                emptyMessage: 'No products in this category',
              ),
            );
          }),
        ),
        const Divider(),
        const SizedBox(height: 64, child: MakeTransactionsActionsView()),
      ],
    );
  }

  String _getCategoryName(List<Category> categories, String categoryId) {
    if (categoryId == 'uncategorized') return 'Uncategorized';
    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => const Category(id: '', name: 'Unknown'),
    );
    return category.name;
  }
}

// ── Shared product list widget ────────────────────────────────────────────────

class _ProductList extends StatelessWidget {
  const _ProductList({required this.products, required this.emptyMessage});

  final List<Product> products;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: ListTile(
            title: Text(product.name),
            subtitle: Text('Barcode: ${product.barcode ?? '-'} | SKU: ${product.sku ?? '-'}'),
            trailing: Text('P${product.price.toStringAsFixed(2)}'),
            onTap: () {
              makeTransactionRef(context).addToCart(
                product: product,
                quantity: 1,
              );
            },
          ),
        );
      },
    );
  }
}

// ── Category cards ────────────────────────────────────────────────────────────

@immutable
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onClick});
  final Category category;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Card.outlined(
        elevation: 4,
        child: Center(
          child: Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

@immutable
class _UncategorizedCard extends StatelessWidget {
  const _UncategorizedCard({required this.onClick});
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Card.outlined(
        elevation: 4,
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category_outlined, color: Colors.grey[600], size: 32),
              const SizedBox(height: 8),
              Text(
                'Uncategorized',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
