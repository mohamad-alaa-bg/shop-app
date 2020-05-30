import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';
import '../widgets/cart_item.dart' /*as si*/; // هنا لدينا تابعين نفس الاسم في cart.dart  وهنا

// لحل المشكلة اما نضع as واسم او رمز ما ثم عند استدعاء التابع نضع الاسم و dot ثم اسم التابع
// او مثلا هنا نحتاج من ال cart.dart تابع واحد وبالتالي نكتبه بعد ال show اما الباقي لا نحتاجه فبهذه الطريقة لن يتم استدعاء التوابع الاخرى
class CartScreen extends StatelessWidget {
  static const routName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your  Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.headline6.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  FlatButton(
                    onPressed: () {
                      Provider.of<Orders>(context, listen: false).addOrder(
                        cart.items.values.toList(),
                        cart.totalAmount,
                      );
                      cart.clear();
                    },
                    child: Text('ORDER NOW'),
                    textColor: Theme.of(context).primaryColor,
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
                itemCount: cart.itemCount,
                itemBuilder: (ctx, i) => CartItem(
                      //هنا استخدما .values لان العنصر الذي يحوي المعلومات هو عبارة عن map
                      //ونحن نريد القيمة فقط لا نريد ال key
                      //.values return Iterable so we use toList()
                      cart.items.values.toList()[i].id,
                      cart.items.keys.toList()[i], // هنا نحصل عل الكي
                      cart.items.values.toList()[i].price,
                      cart.items.values.toList()[i].title,
                      cart.items.values.toList()[i].quantity,
                    )),
          )
        ],
      ),
    );
  }
}
