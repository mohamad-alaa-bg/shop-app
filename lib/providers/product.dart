import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    @required this.price,
    this.isFavorite = false,
  });
  //فقط ال get , put هي التي تعيد خطا throw error اما الباقي يجيب استخدام ال statusCode
  Future <void> toggleFavoriteStatus() async{
    final oldFavorite = isFavorite ;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = 'https://shop-app-c5d91.firebaseio.com/products/$id';
    try{
      final response = await http.patch(url,body:json.encode({
        'isFavorite' : isFavorite,
      }));
      if(response.statusCode >=400)
        {
          //اما نقوم بتنفيذ الكود هنا في حال وجود خطا او نقوم بعمل throw وبالتالي سيتم قدح ال catch ويتم تنفيذه
//          isFavorite = oldFavorite;
//          notifyListeners();
          throw response.statusCode;
        }
    }
    catch(error){
      isFavorite = oldFavorite;
      notifyListeners();
    }

  }
}
