import 'package:cartzen_admin/Core/constants.dart';
import 'package:cartzen_admin/views/banner/screen_banners.dart';
import 'package:cartzen_admin/views/category/screen_category.dart';
import 'package:cartzen_admin/views/coupon/screen_coupon.dart';
import 'package:cartzen_admin/views/orders/screen_orders.dart';
import 'package:cartzen_admin/views/products/screen_products.dart';
import 'package:flutter/material.dart';

enum Locatins {
  products,
  categories,
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(children: [
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            ItemWidget(label: 'Products'),
            ItemWidget(label: 'Categories'),
            ItemWidget(label: 'Banners'),
            ItemWidget(label: 'Orders'),
            ItemWidget(label: 'Coupon'),
          ],
        ),
      ),
    ]);
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    super.key,
    required this.label,
  });
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (label == 'Products') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ScreenProducts(),
            ),
          );
        } else if (label == 'Categories') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ScreenCategory(),
            ),
          );
        } else if (label == 'Banners') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ScreenBanners(),
            ),
          );
        } else if (label == 'Orders') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ScreenOrder(),
            ),
          );
        } else if (label == 'Coupon') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ScreenCoupon(),
            ),
          );
        }
      },
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            kWidth20,
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const Expanded(child: SizedBox()),
            const Icon(
              Icons.arrow_forward_rounded,
              color: themeColor,
            ),
            kWidth20,
          ],
        ),
      ),
    );
  }
}
