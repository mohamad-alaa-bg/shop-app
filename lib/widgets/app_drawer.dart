import 'package:flutter/material.dart';
import 'package:shopapp/screens/auth_screen.dart';
import 'package:shopapp/screens/products_overview_screen.dart';
import '../screens/user_products_screen.dart';
import '../screens/orders-screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello Friend!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: () {
              Navigator.of(context).pushNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () {
              Navigator.of(context).pushNamed(OrdersScreen.routName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () {
              Navigator.of(context).pushNamed(UserProductsScreen.routName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
             // Navigator.of(context).pushNamed('/');
              Navigator.of(context).popUntil((route) => route.isFirst); // pop to root
              Provider.of<Auth>(context,listen: false).logout();

            },
          ),
        ],
      ),
    );
  }
}
