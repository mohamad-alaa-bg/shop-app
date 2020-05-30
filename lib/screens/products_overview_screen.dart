import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/cart_screen.dart';
import '../providers/cart.dart';
import '../widgets/badge.dart';
import '../widgets/productGrid.dart';
import '../widgets/app_drawer.dart';

enum FilterOption {
  Favorite,
  All,
}

//هنا لم نستخدم provider واستخدمنا ال SateFull لان التغير local يمكن ايضا استخدام provider لكن هذه الطريقة الاصح
class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showFavoriteData = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOption selectedValue) {
              setState(() {
                selectedValue == FilterOption.Favorite
                    ? _showFavoriteData = true
                    : _showFavoriteData = false;
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOption.Favorite,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOption.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(icon: Icon(Icons.shopping_cart),onPressed: (){
              Navigator.of(context).pushNamed(CartScreen.routName);
            },),
          ),
        ],
        title: Text(_showFavoriteData ? 'My Favorite' : 'MyShop'),
      ),
      drawer: AppDrawer(),
      body: ProductGrid(_showFavoriteData),
    );
  }
}
