import 'package:flutter/material.dart';
import 'package:pos_terminal/common/repository_store.dart';
import 'package:pos_terminal/features/categories/domain/models/category.domain.dart';
import '../../../../products/domain/models/products.domain.dart' show Product;
import '../widgets/product_grid_widget.dart';
import 'package:result_dart/result_dart.dart';
import 'package:signals/signals_flutter.dart';

import '../widgets/product_list_widget.dart';

enum _ViewMode { grid, list }

final _viewMode = signal(_ViewMode.list);

final _fetchProducts = computedAsync(
  () async => await repositoryStoreRef.instance.productRepository
      .get()
      .getOrElse((_) => []),
);
final _fetchCategories = computedAsync(
  () async => await repositoryStoreRef.instance.categoryRepository
      .get()
      .getOrElse((_) => []),
);
final _selectedCategories = signal<Set<Category>>({});

class ProductListingView extends StatelessWidget {
  const ProductListingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SearchBar(leading: Icon(Icons.search)),
            Watch(
              (_) => SegmentedButton<_ViewMode>(
                segments: [
                  ButtonSegment(value: _ViewMode.list, icon: Icon(Icons.list)),
                  ButtonSegment(
                    value: _ViewMode.grid,
                    icon: Icon(Icons.grid_3x3),
                  ),
                ],
                onSelectionChanged: (p0) {
                  _viewMode.value = p0.first;
                },
                selected: {_viewMode.value},
              ),
            ),
          ],
        ),
        SizedBox(
          height: 50,
          child: Watch(
            (_) => _fetchCategories.value.map(
              loading: () => const LinearProgressIndicator(),
              error: () => [],
              data: (value) => ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  FilterChip(
                    label: const Text("All"),
                    selected: _selectedCategories.value.isEmpty,
                    onSelected: (bool value) => _selectedCategories.value = {},
                  ),

                  ...value.map(
                    (c) => FilterChip(
                      label: Text(c.name),
                      selected: _selectedCategories.value.any(
                        (cat) => cat.id == c.id,
                      ),
                      onSelected: (checked) {
                        if (!checked) {
                          _selectedCategories.value = _selectedCategories.value
                              .where((cat) => cat.id != c.id)
                              .toSet();
                        } else {
                          _selectedCategories.add(c);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          child: Watch(
            (_) => _fetchProducts.value.map(
              loading: () => CircularProgressIndicator(),
              error: (err, _) => Text("Something went wrong"),
              data: (List<Product> products) {
                return Watch((_) {
                  if (_viewMode.value == _ViewMode.grid) {
                    return ProductGridWidget(products: products);
                  } else {
                    return ProductListWidget(products: products);
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
