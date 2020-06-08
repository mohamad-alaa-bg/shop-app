import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/models/http_exception.dart';
import '../providers/auth.dart';

enum AuthMode { SignUp, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // عندما نستخدم .. اي يقوم باعادة ما يعيدها ال object السابقة اي ال matrix
                      // وبنفس الوقت ياخذ بعين الاعتبار التغير اما لو نقة واحدة فيكون الخرج من
                      // نوع ال translate
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color:
                              Theme.of(context).accentTextTheme.headline6.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    flex: 1,
                    fit: FlexFit.loose,
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    fit: FlexFit.loose,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

//SingleTickerProviderStateMixin
//تستخدم من اجل ال animation عند استخدام ال vsync وايضا تخبر
//ال widget عند انتهاء تحديث ال frame
class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;

  //هنا استخدمنا ال controller لان في حال تسجيل  الحساب نريد التحقق من الباسورد مع ال confirm
  //وذلك قبل حفظ ال form اي ال onSave لم ينفذ بعد لذلك نحتاج القيمة مباشرة
  final _passwordController = TextEditingController();

  //بالنسبة لل animation فانه يعتمد على معدل تحديث الشاشة
  //والذي هو 60 مرة في الثانية اي مرة كل 16 ميلي ثانية
  //سنقوم هنا بعمل animation للتبديل بطول الكونتينر بين login or signUp
  // الفكرة هنا اما نستخدم تايمر ليقوم بالزيادة على الارتفاع مثلا كل وقت معين
  //او استخدام ال widget المبنية اساسا من قبل ال flutter
  AnimationController _controller; // متغير من هذا النوع للتحكم في ال animation
  // هنا كلاس من نوع animation يجب تحديد الشيء المراد التحكم به وهنا هو الحجم(الارتفاع)
  Animation<Size> _heightAnimation;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    //نضع في ال vsync ال widget المراد عمل ال animation لها والتي هي في حالتنا
    // ال widget التي نحنا فيها اي يتم تحديث تابع ال build عند كل تغيير
    //الطريقة الثانية لعمل الانميشن وهي تابع AnimatedBuilder خاص ويتم اضافته على ال widget محدد
    // وبالتالي لا يتم تحديث كامل الصفحة اي تانع ال build الكلي ولكن يتم تحديث
    //فقط الحقل او جزء من هذه الصفحة
    // في حال لم نحدد زمن الرجوع بالانميشن فهو نفسها زمن ال duration
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    // هنا سوف نحدد البداية والنهاية اي التغيرات التي نريدها
    // ثم طريقة عرضها وهنا استخدمنا التغير الخطي اي بسرعة متساوية
    // ممكن استخدام بداية سريعة ونهاية بطيئة .....
//    _heightAnimation = Tween<Size>(
//      begin: Size(double.infinity, 260),
//      end: Size(double.infinity, 320),
//    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _opacityAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    // هنا نضيف listener من اجل تحديث الصفحة عند تغير القيمة
    //فقط في حالة التي لم نستخدم فيها اي Animation widget
    // او الافضل نستخدم طريقة AnimatedBuilder التي تحدث فقط الجزء المراد تغيره
//    _heightAnimation.addListener(() {
//      setState(() {});
//    });
//
    // الان يجب عمل اتصال بين ما كتبنا والمكان الذي نريد تطبيق الكلام عليه
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An Error Occurred'),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        await Provider.of<Auth>(context, listen: false).signUp(
          _authData['email'],
          _authData['password'],
        );
        // Sign user up
      }
      // هنا استخدمنا on ومن ثم اسمع التابع و catch في هذه الطريقة في حال بال provider
      //قمنا بعمل throw من خلال هذا التابع سيظهر الخطا هنا فقط اما في ال catch الاخير تبقي للاخطاء العامة
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      print(error);
      const errorMessage =
          'Could not authentication you.Please try again later.';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
      _controller.forward(); // to start Animation
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse(); // اعادة الى الوضع الديفولت او الحركة العكسية
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      //AnimationBuilder
      // هنا في تابع ال builder نضع فقط الجزء المراد تحديثه rebuild
      //اما في ال child فنضع الجزء الثابت الذي لا نريد تغيره
      // هنا ايضا يمكنن استخدام ال AnimatedContainer بدلا من ال animatedBuilder
      //هنا يقوم بنفس الوظيفة تماما يحدث فقط الجزء المتعلق بالتغيير
      // ولسنا بحاجة هنا الى كونترولر فقط نضع المدة وطريقة التغيير
      // وهو عند السطر الذي سوف يتغير سووف يقوم بالتغيير
      child: AnimatedContainer(
//        animation: _heightAnimation,
//        builder: (ctx, ch) => Container(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.SignUp ? 320 : 260,
        //  height: _heightAnimation.value.height,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.SignUp ? 320 : 260),
        // BoxConstraints(minHeight: _heightAnimation.value.height),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                  },
                  onSaved: (value) {
                    _authData['email'] = value.trim(); // حذف ال space
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                // if (_authMode == AuthMode.SignUp)
                //هنا بدل من استخدام الشرط لاظهار او اخفاء الحقل سنقوم
                //باخفاء او اظهار الحقل بهذه الطريقة تغيير الشفافية
                //FadeTransition
                // استخدمنا انميشن تابع لنفس الكونترولر وقمنا بتشغيله
                //اضفنا ال animatedContainer لتغير الحجم من ال 0 لل 60
                // لان في حال لم نضعه وقمنا باخفاء الحقل سيبقى لدينا فراغ باللون الابيض
                // يجب الاخذ بالعلم ان وضع عدة انميشن داخل بعض فهذا يجعل التطبيق يحتاج معالجة اكثر
                //لذلك يجب تجربة التطبيق عل الاجهزة الضعيفة ايضا
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.SignUp ? 60 : 0,
                      maxHeight: _authMode == AuthMode.SignUp ? 120 : 0),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.SignUp,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.SignUp
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
