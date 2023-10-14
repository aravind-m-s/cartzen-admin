import 'dart:developer';

import 'package:cartzen_admin/controllers/coupon/coupon_bloc.dart';
import 'package:cartzen_admin/core/constants.dart';
import 'package:cartzen_admin/models/coupon_model.dart';
import 'package:cartzen_admin/views/common/app_bar.dart';
import 'package:cartzen_admin/views/coupon_add_edit/coupon_add_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenCoupon extends StatelessWidget {
  const ScreenCoupon({super.key});

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<CouponBloc>(context).add(GetAllCoupon());
    return Scaffold(
      appBar: customAppBar(title: 'Coupon', context: context),
      body: Padding(
        padding: const EdgeInsets.only(top: padding),
        child: BlocBuilder<CouponBloc, CouponState>(
          builder: (context, state) {
            if (state.coupons.isEmpty) {
              return Center(
                child: Text(
                  "No Coupons",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              );
            }
            return ListView.separated(
                itemBuilder: (context, index) =>
                    CouponCard(coupon: state.coupons[index]),
                separatorBuilder: (context, index) => const Divider(),
                itemCount: state.coupons.length);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CouponAddEdit(),
          ));
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class CouponCard extends StatelessWidget {
  const CouponCard({
    super.key,
    required this.coupon,
  });
  final CouponModel coupon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        kHeight,
        Container(
          width: 200,
          height: 100,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/coupon.png'),
              fit: BoxFit.contain,
            ),
          ),
          child: Row(
            children: [
              kWidth20,
              kWidth20,
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    coupon.isPercent
                        ? '${coupon.offer} %'
                        : '₹ ${coupon.offer}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  kHeight10,
                  Text(
                    coupon.couponCode,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        kHeight,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CouponAddEdit(coupon: coupon)));
                  },
                  child: Text(
                    'Edit',
                    style: Theme.of(context).textTheme.titleMedium,
                  )),
            ),
            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Are you sure"),
                        content: Text(
                          "Do you want Delete this coupon",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "cancel",
                                style: Theme.of(context).textTheme.titleSmall,
                              )),
                          TextButton(
                              onPressed: () {
                                BlocProvider.of<CouponBloc>(context)
                                    .add(DeleteCoupon(id: coupon.id));
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "OK",
                                style: Theme.of(context).textTheme.titleSmall,
                              ))
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Delete',
                    style: Theme.of(context).textTheme.titleMedium,
                  )),
            )
          ],
        ),
        kHeight
      ],
    );
  }
}
