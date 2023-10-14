import 'dart:developer';

import 'package:cartzen_admin/Core/constants.dart';
import 'package:cartzen_admin/controllers/coupon/coupon_bloc.dart';
import 'package:cartzen_admin/models/coupon_model.dart';
import 'package:cartzen_admin/views/common/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final TextEditingController _offer = TextEditingController();
final TextEditingController _coupon = TextEditingController();
final TextEditingController _max = TextEditingController();

String startDate = '';
String endDate = '';

class CouponAddEdit extends StatelessWidget {
  const CouponAddEdit({super.key, this.coupon});

  final CouponModel? coupon;

  update() {
    if (coupon != null) {
      startDate = coupon!.startDate;
      endDate = coupon!.endDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    update();
    return Scaffold(
      appBar: customAppBar(title: 'Coupon', context: context),
      body: Padding(
        padding: const EdgeInsets.all(padding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InputWidget(
              controller: _coupon,
              label: 'Coupon Code',
              couponCode: coupon == null ? ' ' : coupon!.couponCode,
            ),
            kHeight,
            InputField(
              controller: _offer,
              label: 'Coupon Offer',
              offer: coupon == null ? 0 : coupon!.offer,
            ),
            kHeight,
            InputField(
              controller: _max,
              label: 'Minimum Amount',
              offer: coupon == null ? 0 : coupon!.max,
            ),
            kHeight,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2024, 12, 31));
                    if (date != null) {
                      startDate = date.toString();
                      BlocProvider.of<CouponBloc>(context)
                          .add(ChangeDate(date: startDate));
                    }
                  },
                  child: BlocBuilder<CouponBloc, CouponState>(
                    builder: (context, state) {
                      return Text(
                        startDate == ''
                            ? 'Start Date'
                            : startDate.substring(0, 10),
                        style: Theme.of(context).textTheme.titleMedium,
                      );
                    },
                  ),
                ),
                const Icon(Icons.remove),
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                        context: context,
                        initialDate: startDate == ''
                            ? DateTime.now()
                            : DateTime.parse(startDate),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2024, 12, 31));
                    if (date != null) {
                      endDate = date.toString();
                      BlocProvider.of<CouponBloc>(context)
                          .add(ChangeDate(date: endDate));
                    }
                  },
                  child: BlocBuilder<CouponBloc, CouponState>(
                    builder: (context, state) {
                      return Text(
                        endDate == '' ? 'End Date' : endDate.substring(0, 10),
                        style: Theme.of(context).textTheme.titleMedium,
                      );
                    },
                  ),
                ),
              ],
            ),
            kHeight,
            ConfirmButton(coupon: coupon),
          ],
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  const InputField({
    Key? key,
    required this.controller,
    required this.label,
    required this.offer,
  }) : super(key: key);

  final TextEditingController controller;
  final String label;
  final int offer;

  getData(int data) {
    controller.text = data.toString();
  }

  @override
  Widget build(BuildContext context) {
    getData(offer);

    return TextFormField(
      style: TextStyle(color: darkMode ? Colors.white : Colors.black),
      keyboardType: TextInputType.number,
      controller: controller,
      cursorColor: themeColor,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: themeColor,
          ),
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultRadius)),
        focusColor: themeColor,
        hintText: label,
        labelStyle: const TextStyle(color: themeColor),
        label: Text(label),
        alignLabelWithHint: true,
      ),
    );
  }
}

class InputWidget extends StatelessWidget {
  const InputWidget({
    Key? key,
    required this.controller,
    required this.label,
    required this.couponCode,
  }) : super(key: key);

  final TextEditingController controller;
  final String label;
  final String couponCode;

  getData(String data) {
    controller.text = data.toString();
  }

  @override
  Widget build(BuildContext context) {
    getData(couponCode);

    return TextFormField(
      style: TextStyle(color: darkMode ? Colors.white : Colors.black),
      controller: controller,
      cursorColor: themeColor,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: themeColor,
          ),
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultRadius)),
        focusColor: themeColor,
        hintText: label,
        labelStyle: const TextStyle(color: themeColor),
        label: Text(label),
        alignLabelWithHint: true,
      ),
    );
  }
}

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({Key? key, required this.coupon}) : super(key: key);
  final CouponModel? coupon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        child: Text(
          "Continue",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onPressed: () async {
          if (_coupon.text != '' &&
              _offer.text != '' &&
              startDate != '' &&
              endDate != '') {
            if (coupon == null) {
              final coupon = CouponModel(
                id: '',
                offer: int.parse(_offer.text),
                isPercent: false,
                couponCode: _coupon.text,
                startDate: startDate,
                endDate: endDate,
                max: int.parse(_max.text),
                redeemedUsers: [],
              );
              BlocProvider.of<CouponBloc>(context)
                  .add(AddCoupon(coupon: coupon));
              Navigator.of(context).pop();
            } else {
              final cpn = CouponModel(
                id: coupon!.id,
                offer: int.parse(_offer.text),
                isPercent: coupon!.isPercent,
                couponCode: _coupon.text,
                startDate: startDate,
                endDate: endDate,
                max: int.parse(_max.text),
                redeemedUsers: coupon!.redeemedUsers,
              );
              BlocProvider.of<CouponBloc>(context).add(EditCoupon(coupon: cpn));
              Navigator.of(context).pop();
            }
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('OOPs!'),
                content: Text('All fields must be filled'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'))
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
