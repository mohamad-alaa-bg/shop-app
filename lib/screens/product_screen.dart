import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    String productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);

    return Scaffold(
//      appBar: AppBar(
//        title: Text(loadedProduct.title),
//      ),
      body: CustomScrollView(
        // تسخدم من اجل اخفاء ال appBar واظهاره فقط عند ال scroll
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true, // في حالة ال true عند ظهور ال appBar يبقى ثابت
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                color: Colors.purple,
                padding: EdgeInsets.all(3),
                child: Text(loadedProduct.title),
              ),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(
                height: 10,
              ),
              Text(
                '\$${loadedProduct.price}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  loadedProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              SizedBox(
                height: 800,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
