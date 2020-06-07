import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import './screens/auth_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/user_products_screen.dart';
import './screens/orders-screen.dart';
import './screens/cart_screen.dart';
import './screens/product_screen.dart';
import './screens/products_overview_screen.dart';

import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        //هنا نريد تمرير داتا من ال auth لل products والطريقة الافضل استخدام proxyProvider
        //النقطة الاولى يجب ان يكون المكان الذي يعطي الداتا في الاعلى
        // عند حصول اي تغير في ال auth فان اي proxy يستخدمه يقوم بالتحديث
        //قمنا بتمرير القيمة السابقة لان هنا عند rebuild يقوم بانشاء new instance
        //وللحفاظ على الداتا السابقة قمنا بتمرير المصفوفة
        ChangeNotifierProxyProvider<Auth, Products>(
            update: (ctx, auth, previousProducts) => Products(
                  auth.token,
                  auth.userId,
                  previousProducts == null ? [] : previousProducts.items,
                )),
        ChangeNotifierProvider(create: (ctx) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, authData, _) => MaterialApp(
          title: 'My Shop',
          theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato'),
          debugShowCheckedModeBanner: false,
          home: authData.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: authData.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routName: (ctx) => ProductDetailScreen(),
            CartScreen.routName: (ctx) => CartScreen(),
            OrdersScreen.routName: (ctx) => OrdersScreen(),
            UserProductsScreen.routName: (ctx) => UserProductsScreen(),
            EditProductScreen.routName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
