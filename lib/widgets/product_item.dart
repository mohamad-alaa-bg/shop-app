import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/products.dart';
import '../providers/product.dart';
import '../screens/product_screen.dart';

// الفرق بين الprovide.of وال consumer الاولى عندم يحدث تغير تقوم بعمل rebuild لكل تابع ال widget
//اما الثانية يمكن تخصيصها لمكان معين
// ايضا يمكن ايقاف ال listen بال provide.of في حال كنا نحتاج معلومات لمرة واحد عند بناء التابع مثل هنا id , imageUrl
//اما بالنسبة لحالة ال isFavorite فنضعها ب consumer وبالتالي فقط هي التي تعاد بنائها وليس كل التابع
//في حال كنا نريدبقلب ال consumer ان نثبت widget فنقوم بكتابتها child: widget في حال لا يوجد يمكننا وضع _
class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: true);
    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () =>
              Navigator.of(context)
                  .pushNamed(
                  ProductDetailScreen.routName, arguments: product.id),
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black87,
          //هنا عندما نختار favorite او لا .. يتم تحديث فقط شكل الايقونة وليس كل العنصر
          leading: Consumer<Product>(
            builder: (ctx, product2, _) =>
                IconButton(
                  // هنا يمكن تسميته ايضا product لانه متغير خاص لهذا التابع لكن للتميز سميته product2
                  icon: product2.isFavorite
                      ? Icon(Icons.favorite)
                      : Icon(Icons.favorite_border),
                  onPressed: () {
                    product.toggleFavoriteStatus();
                    Provider.of<Products>(context, listen: false)
                        .refresh(); // من اجل عند حذف ال favorite يتم حذفها من القائمة Favorite Only
                  },
                  color: Theme
                      .of(context)
                      .accentColor,
                ),
            //child: Text('No Update'), // للتفعيل نضع بدل _ كلمة child
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            /**/
            onPressed: () {
              cart.addItem(product.id, product.title, product.price);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Added item to cart!', textAlign: TextAlign.center,),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(label: 'UNDO', onPressed: () {
                    cart.removeSingleItem(product.id);
                  },),
                ),
              );
            },
            color: Theme
                .of(context)
                .accentColor,
          ),
        ),
      ),
    );
  }
}
