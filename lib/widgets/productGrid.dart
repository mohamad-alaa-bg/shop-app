import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import './product_item.dart';

class ProductGrid extends StatelessWidget {
  final bool showFavoriteData ;
  ProductGrid(this.showFavoriteData);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFavoriteData ? productsData.favoriteItem : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      //عندما يكون ال object موجود وفقط نريد استخدامها فالافضل نستخدم هذه الطريقة افضل لتجنب المشاكل حسب الدرس رقم195
      // اما عندما يكون حجديد ونريد انشاؤه نستخدم الطريقة مثل ما فعلنا في ال main ويمكن استخدام هذه الطريقة ايضا لكن في تلك الحالة
      //  استخدام تابع ال crate افضل
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
//        create: (ctx) => products[i] ,
        value: products[i],
        child: ProductItem(),
      ),
      itemCount: products.length,
    );
  }
}
