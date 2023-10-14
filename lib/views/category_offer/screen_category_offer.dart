import 'package:cartzen_admin/Controllers/offer/offer_bloc.dart';
import 'package:cartzen_admin/Core/constants.dart';
import 'package:cartzen_admin/Models/category_model.dart';
import 'package:cartzen_admin/Views/category/screen_category.dart';
import 'package:cartzen_admin/Views/common/bottom_bordered_card.dart';
import 'package:cartzen_admin/views/common/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

TextEditingController controller = TextEditingController();
bool value = false;

class ScreenCategoryOffer extends StatelessWidget {
  const ScreenCategoryOffer({super.key, required this.category});

  final CategoryModel category;

  getData() {
    value = category.isPercent;
  }

  @override
  Widget build(BuildContext context) {
    getData();
    final TextEditingController controller = TextEditingController();
    return Scaffold(
      appBar: customAppBar(title: 'Category Offer', context: context),
      body: Padding(
        padding: const EdgeInsets.all(padding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.category,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            kHeight,
            InputField(
                controller: controller, label: 'Offer', offer: category.offer),
            Row(
              children: [
                BlocBuilder<OfferBloc, OfferState>(
                  builder: (context, state) {
                    return Checkbox(
                      activeColor: themeColor,
                      value: value,
                      onChanged: (val) {
                        value = val!;
                        BlocProvider.of<OfferBloc>(context)
                            .add(ChangeOfferType(value: value));
                      },
                    );
                  },
                ),
                kHeight10,
                Text(
                  'Offer in Percentage',
                  style: Theme.of(context).textTheme.titleSmall,
                )
              ],
            ),
            kHeight10,
            ConfirmButton(controller: controller, productId: category.id),
          ],
        ),
      ),
      bottomSheet: const BottomBorderedCard(),
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

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({
    Key? key,
    required this.controller,
    required this.productId,
  }) : super(key: key);

  final TextEditingController controller;
  final String productId;

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
            final doc = FirebaseFirestore.instance
                .collection('category')
                .doc(productId);

            final product = await doc.get().then((value) => value.data());
            if (product != null) {
              product['isPercent'] = value;
              if (controller.text.isEmpty) {
                product['offer'] = 0;
              } else {
                product['offer'] = int.parse(controller.text);
              }
              doc.update(product).then((val) =>
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const ScreenCategory(),
                  )));
            }
          }),
    );
  }
}
