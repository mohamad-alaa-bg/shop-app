import 'package:flutter/foundation.dart';
import '../providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url = 'https://shop-app-c5d91.firebaseio.com/orders.json';
    final timeStamp =
        DateTime.now(); // من اجل جعل الوقت هو نفسه في السيرفر وال memory
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          // هنا لم نستخدم to string لان من الصعب استرجاعه لوقت اما toIso8601String افضل لاسترجاعه لوقت بسهولة

          'dateTime': timeStamp.toIso8601String(),
          'product': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'price': e.price,
                    'quantity': e.quantity
                  })
              .toList(),
        }));
    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timeStamp,
        )); // الصفر يدل على اول عنصر ثم ال index يزداد تلقائي
    notifyListeners();
  }

  Future<void> fetchAndSerOrders() async {
    const url = 'https://shop-app-c5d91.firebaseio.com/orders.json';
    final responses = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractData = json.decode(responses.body) as Map<String, dynamic>;
    if (extractData == null) {
      return;
    }

    extractData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        id: orderId,
        amount: orderData['amount'],
        products: (orderData['product'] as List<dynamic>)
            .map((e) => CartItem(
                  id: e['id'],
                  title: e['title'],
                  price: e['price'],
                  quantity: e['quantity'],
                ))
            .toList(),
        dateTime: DateTime.parse(orderData['dateTime']),
      ));
    });
    _orders = loadedOrders;
    notifyListeners();
  }
}
