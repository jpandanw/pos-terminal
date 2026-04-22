import 'package:flutter/material.dart';
import 'package:lite_ref/lite_ref.dart';
import 'package:pos_terminal/data/server/fetch_categories.dart';
import 'package:pos_terminal/data/server/fetch_products.dart';
import 'package:pos_terminal/data/server/fetch_sale_modifier.dart';
import 'package:pos_terminal/types/product.type.dart';
import 'package:pos_terminal/types/transactions.type.dart';
import 'package:result_dart/result_dart.dart';
import 'package:signals/signals.dart';

class FetchDataState extends Disposable {
  final BuildContext context;
  FetchDataState(this.context);

  final hasInitialSync = signal(false);
  final isFetcing = signal(false);

  final products = listSignal<Product>([]);
  final categories = listSignal<Category>([]);
  final saleModifiers = listSignal<TransactionModifier>([]);

  AsyncResult<void> load() async {
    isFetcing.value = true;
    final products = await fetchProducts();
    if (products.isError()) {
      isFetcing.value = false;
      return Exception("Unable to fetch Products").toFailure();
    }

    final categories = await fetchCategories();
    if (categories.isError()) {
      isFetcing.value = false;
      return Exception("Unable to fetch Categories").toFailure();
    }

    final saleModifiers = await fetchSaleModifiers();
    if (saleModifiers.isError()) {
      isFetcing.value = false;
      return Exception("Unable to fetch Sale Modifiers").toFailure();
    }

    this.categories.value = categories.getOrDefault([]);
    this.products.value = products.getOrDefault([]);
    this.saleModifiers.value = saleModifiers.getOrDefault([]);

    hasInitialSync.value = true;
    isFetcing.value = false;
    return Success(0);
  }

  @override
  void dispose() {
    hasInitialSync.dispose();
    isFetcing.dispose();
    products.dispose();
    categories.dispose();
    saleModifiers.dispose();
  }
}

final fetchDataRef = Ref.scoped((context) => FetchDataState(context));
