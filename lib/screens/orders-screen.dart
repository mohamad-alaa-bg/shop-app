import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

// هنا في حال لا نريد تحويل ال sateLess ل StateFull ووضع التغيرات في ال initState
// FutureBuilder
//الملاحظة هنا قمنا بستخدام ال consumer بدل من ال provider حتى لا يتم اعادة بناء كل ال build وبالتالي سندخل في حلقة غير منتهة
//فقط قمنا بتحديث القسم الخاص بال list وبالتالي سيتم تنفيذ ال FutureBuilder مرة واحدة فقط عند بناء تابع ال build
class OrdersScreen extends StatelessWidget {
  static const routName = '/orders';

  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSerOrders(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.error != null) {
              return Center(child: Text('error'));
            } else {
              return Consumer<Orders>(
                builder: (context, orderData, child) => ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
