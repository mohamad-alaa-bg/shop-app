import 'package:flutter/material.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
//    Product(
//      id: 'p1',
//      title: 'Red Shirt',
//      description: 'A red shirt - it is pretty red!',
//      price: 29.99,
//      imageUrl:
//          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
//    ),
//    Product(
//      id: 'p2',
//      title: 'Trousers',
//      description: 'A nice pair of trousers.',
//      price: 59.99,
//      imageUrl:
//          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
//    ),
//    Product(
//      id: 'p3',
//      title: 'Yellow Scarf',
//      description: 'Warm and cozy - exactly what you need for the winter.',
//      price: 19.99,
//      imageUrl:
//          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
//    ),
//    Product(
//      id: 'p4',
//      title: 'A Pan',
//      description: 'Prepare any meal you want.',
//      price: 49.99,
//      imageUrl:
//          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
//    ),
  ];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItem {
    return _items.where((element) => element.isFavorite == true).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }


  void refresh() {

    notifyListeners();
  }

  Future<void> fetchAndSetProducts() async {
    const url = 'https://shop-app-c5d91.firebaseio.com/products.json';
    try {
      final response = await http.get(url);
      //هنا الخرج عبارة عن map بداخلها map وال key لل map الاولى هو id
      //اما ال map الثانية فيوجد بداخلها ال productData
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if(extractedData == null){return;}
      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          title: productData['title'],
          price: productData['price'],
          description: productData['description'],
          imageUrl: productData['imageUrl'],
          isFavorite: productData['isFavorite'],
        ));
        _items = loadedProducts;
        notifyListeners();
      });
      }
       catch (error) {
      print(error);
      throw (error);
    }
  }

  // هنا تابع ال future لا نستطيع وضع ال return في ال then لانها تعتبر return للتابع ال  anonymous
  // وابضا لا نستطيع وضعها بعد ال then لان سوف يتم تفيذها فورا
  // نحن نريد تنفيذها بعد عملية الحفظ في الداتا بيز لذلك
  //return http
  //بهذه الطريقة سيتم تنفيذ ال return الكلي بعد الانتهاء من كل العمليات
  //الطريقة الاولى اما الطريقة الاكثر استخداما هي الثانية
  /*Future<void> addProduct(Product value) {
    const url = 'https://shop-app-c5d91.firebaseio.com/products.json';
    //ممكن ال json.encode دخلها map اما ان نستخدم ال value او نكتب map خاصة
    //http.post(url,body: json.encode(value),);
    return http
        .post(
      url,
      body: json.encode({
        'title': value.title,
        'description': value.description,
        'price': value.price,
        'imageUrl': value.imageUrl,
        'isFavorite': value.isFavorite,
      }),
    )
        .then((response) {
      final newProduct = Product(
        title: value.title,
        price: value.price,
        description: value.description,
        imageUrl: value.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
//    _items.insert(0, newProduct);
      print(newProduct.id);
      notifyListeners();
    }).catchError((error) {
      throw error;
    });
  }*/

  //الطريقة الثانية async try catch
  // هنا قمنا بوضع الكود الاول بال try وفي حال يوجد خطا سيتم تنفيذ ال catch
  //بالنسبة لل await فهي تقوم بايقاف تنفيذ باقي ال try حتى يتم ارجاع ال response
  //ثم يكمل تنفيذ
  //في حال لا يوجد قيمة return نستخدم finally
  Future<void> addProduct(Product value) async {
    const url = 'https://shop-app-c5d91.firebaseio.com/products.json';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': value.title,
          'description': value.description,
          'price': value.price,
          'imageUrl': value.imageUrl,
          'isFavorite': value.isFavorite,
        }),
      );
      final newProduct = Product(
        title: value.title,
        price: value.price,
        description: value.description,
        imageUrl: value.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
//    _items.insert(0, newProduct);
      print(newProduct.id);
      notifyListeners();
    } catch (error) {
      print(error);

      throw error;
    }
  }

  Future<void> updateProduct(String id, Product editProduct) async {
    final productIndex = _items.indexWhere((element) => element.id == id);

    if (productIndex >= 0) {
      final url = 'https://shop-app-c5d91.firebaseio.com/products/$id.json';
      await http.patch(url,
          body: json.encode({
            'title': editProduct.title,
            'description': editProduct.description,
            'price': editProduct.price,
            'imageUrl': editProduct.imageUrl,
          }));
      _items[productIndex] = editProduct;
      notifyListeners();
    } else {
      print('.');
    }
  }

  Future<void> deleteProduct(String id) async {
    // قمنا باستخدام هذه الطريقة لاعادة العنصر في حال حصل error
    //حيث انه يبقى في ال memory حتى لو قمنا بحذفه من القائمة
    // في حال نجاح العملية قمنا بتصفير العنصر الذي خذنا القيمة فيه حتى لا يبقى في الذاكرة

    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];
    // هنا عند استخدام ال delete وفي حال حدوث خطأ فلا يقوم بارجاع الخطا
    // ونقوم بداخل تابع ال then اكتشاف الخطا statusCode ونقوم ببناء ال exception
    final url = 'https://shop-app-c5d91.firebaseio.com/products/$id.json';
    _items.removeAt(existingProductIndex);
    // _items.removeWhere((element) => element.id == id);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
  }
}
