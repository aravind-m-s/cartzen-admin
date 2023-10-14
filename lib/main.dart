import 'package:cartzen_admin/Controllers/add_edit_product/add_product_bloc.dart';
import 'package:cartzen_admin/Controllers/category/category_bloc.dart';
import 'package:cartzen_admin/Controllers/offer/offer_bloc.dart';
import 'package:cartzen_admin/Controllers/products/products_bloc.dart';
import 'package:cartzen_admin/controllers/banner/banner_bloc.dart';
import 'package:cartzen_admin/controllers/coupon/coupon_bloc.dart';
import 'package:cartzen_admin/controllers/dropdown/dropdown_bloc.dart';
import 'package:cartzen_admin/controllers/order/order_bloc.dart';
import 'package:cartzen_admin/views/products/screen_products.dart';
import 'package:cartzen_admin/core/themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AddProductBloc(),
        ),
        BlocProvider(
          create: (context) => ProductsBloc(),
        ),
        BlocProvider(
          create: (context) => OfferBloc(),
        ),
        BlocProvider(
          create: (context) => CategoryBloc(),
        ),
        BlocProvider(
          create: (context) => BannerBloc(),
        ),
        BlocProvider(
          create: (context) => OrderBloc(),
        ),
        BlocProvider(
          create: (context) => DropdownBloc(),
        ),
        BlocProvider(
          create: (context) => CouponBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const ScreenProducts(),
        themeMode: ThemeMode.light,
        theme: lightTheme,
        darkTheme: darkTheme,
      ),
    );
  }
}
