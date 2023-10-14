import 'package:cartzen_admin/Core/constants.dart';
import 'package:cartzen_admin/models/order_model.dart';
import 'package:cartzen_admin/models/product_model.dart';
import 'package:cartzen_admin/views/common/app_bar.dart';
import 'package:flutter/material.dart';

class ScreenOrderDetails extends StatelessWidget {
  const ScreenOrderDetails(
      {super.key, required this.order, required this.products});
  final OrderModel order;
  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> pdts = [];
    for (var orderPdt in order.products) {
      pdts.add(
        products
            .where((element) => element.id == orderPdt['productId'])
            .toList()
            .first,
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(title: 'ORDER', context: context),
      body: Padding(
        padding: const EdgeInsets.all(padding * 2),
        child: ListView.separated(
          itemBuilder: (context, index) => Container(
              child: Row(
            children: [
              ImageWidget(image: pdts[index].images[0]),
              kWidth10,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    products[index].name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      Text(
                        'Color:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      kWidth10,
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Color(
                          int.parse(
                            order.products[index]['color'],
                          ),
                        ),
                      )
                    ],
                  ),
                  Text(
                    'Size:  ${order.products[index]["size"]}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    "Quantity:  ${order.products[index]["quantity"]}",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    "Price:  ₹ ${pdts[index].price * order.products[index]['quantity']}",
                    style: Theme.of(context).textTheme.titleLarge,
                  )
                ],
              )
            ],
          )),
          separatorBuilder: (context, index) => kHeight,
          itemCount: order.products.length,
        ),
      ),
    );
  }
}

class ImageWidget extends StatelessWidget {
  const ImageWidget({Key? key, required this.image}) : super(key: key);
  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 175,
      width: 125,
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      ),
    );
  }
}
