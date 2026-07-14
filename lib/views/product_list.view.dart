import 'package:flutter/material.dart';
import 'package:pos_terminal/states/load_data.state.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/states/products_loaded.state.dart';
import 'package:pos_terminal/types/product.type.dart';
import 'package:pos_terminal/views/make_transactions_actions.view.dart';
import 'package:signals/signals_flutter.dart';

final selectedCategory = signal<String?>(null);
final searchModeActive = signal<bool>(false);
final searchCursorIndex = signal<int>(0);
final searchFocusNode = FocusNode();
final searchQuery = signal<String>('');
final mainFocusNode = FocusNode();

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final _searchController = SearchController();
  final _scrollController = ScrollController();
  EffectCleanup? _effectCleanup;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      untracked(() {
        searchQuery.value = _searchController.text;
        searchCursorIndex.value = 0; // reset selection when query changes
      });
    });

    searchFocusNode.addListener(_onFocusChanged);

    _effectCleanup = effect(() {
      final index = searchCursorIndex.value;
      _scrollToIndex(index);
    });
  }

  void _onFocusChanged() {
    if (searchFocusNode.hasFocus) {
      untracked(() {
        searchModeActive.value = true;
        // Select all text in the controller
        _searchController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _searchController.text.length,
        );
      });
    } else {
      untracked(() {
        searchModeActive.value = false;
        _clearSearch();
      });
      mainFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _effectCleanup?.call();
    searchFocusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    untracked(() {
      searchQuery.value = '';
      searchCursorIndex.value = 0;
    });
  }

  void _exitSearchMode() {
    _clearSearch();
    searchFocusNode.unfocus();
    mainFocusNode.requestFocus();
    untracked(() {
      searchModeActive.value = false;
    });
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;
    const itemHeight = 72.0; // estimate height of card/listtile
    final position = index * itemHeight;
    final viewportHeight = _scrollController.position.viewportDimension;
    final currentScroll = _scrollController.offset;
    if (position < currentScroll) {
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
      );
    } else if (position + itemHeight > currentScroll + viewportHeight) {
      _scrollController.animateTo(
        position + itemHeight - viewportHeight,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fetchData = fetchDataRef(context);
    return Column(
      spacing: 16,
      children: [
        Watch((context) {
          final isActive = searchModeActive.value;
          final colorScheme = Theme.of(context).colorScheme;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: SearchBar(
              controller: _searchController,
              focusNode: searchFocusNode,
              hintText: isActive
                  ? 'SEARCH MODE ACTIVE - Type to filter...'
                  : 'Search Product Name, SKU, or Barcode...',
              leading: Badge(
                label: Text(
                  isActive ? "ESC" : "/",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
                alignment: Alignment.topLeft,
                backgroundColor: isActive
                    ? colorScheme.error
                    : colorScheme.secondary,
                child: Icon(
                  Icons.search,
                  color: isActive ? colorScheme.primary : null,
                ),
              ),
              side: WidgetStateProperty.all(
                BorderSide(
                  color: isActive ? colorScheme.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  final results = productsLoadedRef(context).searchProducts(value);
                  if (results.isNotEmpty) {
                    final selectedIndex = searchCursorIndex.value;
                    final targetProduct = (selectedIndex >= 0 && selectedIndex < results.length)
                        ? results[selectedIndex]
                        : results.first;
                    makeTransactionRef(context).addToCart(
                      product: targetProduct,
                      quantity: 1,
                    );
                    _exitSearchMode();
                  }
                }
              },
              trailing: [
                Watch((context) {
                  final query = searchQuery.value;
                  if (query.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear search',
                    onPressed: _clearSearch,
                  );
                }),
              ],
            ),
          );
        }),
        Expanded(
          child: Watch((context) {
            final query = searchQuery.value;
            final currentSelectedCategory = selectedCategory.value;
            final categories = fetchData.categories.value;

            // — Search mode: show results globally across all products —
            if (query.isNotEmpty) {
              final results =
                  productsLoadedRef(context).searchProducts(query);
              return _SearchProductList(
                products: results,
                scrollController: _scrollController,
                emptyMessage: 'No products match "$query"',
                onSelected: (product) {
                  makeTransactionRef(context).addToCart(
                    product: product,
                    quantity: 1,
                  );
                  _exitSearchMode();
                },
              );
            }

            // — Category not yet selected: show category grid —
            if (currentSelectedCategory == null) {
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
                          selectedCategory.value = 'uncategorized';
                        });
                      },
                    );
                  }
                  return _CategoryCard(
                    category: categories[index],
                    onClick: () {
                      untracked(() {
                        selectedCategory.value = categories[index].id;
                      });
                    },
                  );
                },
              );
            }

            // — Category selected: show its products —
            final productList =
                productsLoadedRef(context).getProductsByCategory(
              currentSelectedCategory,
            );
            return Scaffold(
              appBar: AppBar(
                leading: TextButton.icon(
                  onPressed: () {
                    untracked(() {
                      selectedCategory.value = null;
                    });
                    _clearSearch();
                  },
                  label: const Icon(Icons.arrow_left_rounded),
                ),
                title: Text(_getCategoryName(categories, currentSelectedCategory)),
              ),
              body: _SearchProductList(
                products: productList,
                scrollController: _scrollController,
                emptyMessage: 'No products in this category',
                onSelected: (product) {
                  makeTransactionRef(context).addToCart(
                    product: product,
                    quantity: 1,
                  );
                  _exitSearchMode();
                },
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

// ── Shared product list widget with selection support ──────────────────────────

class _SearchProductList extends StatelessWidget {
  const _SearchProductList({
    required this.products,
    required this.scrollController,
    required this.emptyMessage,
    required this.onSelected,
  });

  final List<Product> products;
  final ScrollController scrollController;
  final String emptyMessage;
  final ValueChanged<Product> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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

    return Watch((context) {
      final selectedIndex = searchCursorIndex.value;
      final isActive = searchModeActive.value;

      return ListView.builder(
        controller: scrollController,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final isSelected = isActive && index == selectedIndex;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: ListTile(
              title: Text(
                product.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                'Barcode: ${product.barcode ?? '-'} | SKU: ${product.sku ?? '-'}',
              ),
              trailing: Text(
                'P${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => onSelected(product),
            ),
          );
        },
      );
    });
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
