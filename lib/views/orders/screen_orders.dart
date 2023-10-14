import 'package:cartzen_admin/Core/constants.dart';
import 'package:cartzen_admin/controllers/order/order_bloc.dart';
import 'package:cartzen_admin/models/order_model.dart';
import 'package:cartzen_admin/views/common/app_bar.dart';
import 'package:cartzen_admin/views/order_details/screen_order_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenOrder extends StatelessWidget {
  const ScreenOrder({super.key});

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<OrderBloc>(context).add(GetAllOrders());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(title: 'Orders', context: context),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state.orders.isEmpty) {
            return Center(
              child: Text(
                "No Orders",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.separated(
                itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ScreenOrderDetails(
                          order: state.orders[index],
                          products: state.products,
                        ),
                      ));
                    },
                    child: OrderCard(order: state.orders[index])),
                separatorBuilder: (context, index) => kHeight,
                itemCount: state.orders.length),
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({Key? key, required this.order}) : super(key: key);
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final date = order.date;
    final String formattedDate =
        '${date.substring(5, 7)}-${date.substring(8, 10)}-${date.substring(0, 4)}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: padding * 2),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: themeColor),
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderID(id: order.id),
              OrderDetailsCard(title: "Ordered on:", value: formattedDate),
              OrderDetailsCard(
                  title: "No of Products:",
                  value: order.products.length.toString()),
              OrderDetailsCard(
                  title: "PaymentMethod", value: order.paymentMethod),
              OrderDetailsCard(title: "Order Status", value: order.status),
              OrderDetailsCard(
                  title: "Total Amount:", value: order.total.toString()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  order.status != "Returned" &&
                          order.status != "Delivered" &&
                          order.status != "Canceled"
                      ? ElevatedButton(
                          onPressed: () {
                            if (order.status == "Return Pending") {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Are you sure"),
                                  content: Text(
                                    "Do you want Cancel the return",
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "cancel",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        )),
                                    TextButton(
                                        onPressed: () {
                                          BlocProvider.of<OrderBloc>(context)
                                              .add(ChangeStatus(
                                                  id: order.id,
                                                  status: "Return Canceled"));
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "OK",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ))
                                  ],
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Are you sure"),
                                  content: Text(
                                    "Do you want Cancel the order",
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "cancel",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        )),
                                    TextButton(
                                        onPressed: () {
                                          BlocProvider.of<OrderBloc>(context)
                                              .add(ChangeStatus(
                                                  id: order.id,
                                                  status: "Canceled"));
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "OK",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ))
                                  ],
                                ),
                              );
                            }
                          },
                          child: Text(
                            "Cancel",
                            style: Theme.of(context).textTheme.titleMedium,
                          ))
                      : const SizedBox(),
                  ChangeStatusButton(order: order),
                ],
              ),
              kHeight10,
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeStatusButton extends StatelessWidget {
  const ChangeStatusButton({
    Key? key,
    required this.order,
  }) : super(key: key);

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return order.status == "Canceled" ||
            order.status == "Returned" ||
            order.status == "Delivered"
        ? const SizedBox()
        : Center(
            child: SizedBox(
              width: 200,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                onPressed: () async {
                  if (order.status == "Pending") {
                    BlocProvider.of<OrderBloc>(context)
                        .add(ChangeStatus(id: order.id, status: "Shipped"));
                  } else if (order.status == "Return Pending") {
                    BlocProvider.of<OrderBloc>(context)
                        .add(ChangeStatus(id: order.id, status: "Returned"));
                  } else {
                    BlocProvider.of<OrderBloc>(context)
                        .add(ChangeStatus(id: order.id, status: "Delivered"));
                  }
                },
                child: order.status == "Pending"
                    ? Text(
                        'Shipped',
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    : order.status == "Return Pending"
                        ? Text(
                            'Accept',
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        : Text(
                            'Delivered',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
              ),
            ),
          );
  }
}

class OrderDetailsCard extends StatelessWidget {
  const OrderDetailsCard({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20),
        ),
      ],
    );
  }
}

class OrderID extends StatelessWidget {
  const OrderID({
    Key? key,
    required this.id,
  }) : super(key: key);
  final String id;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Id: $id",
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: themeColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
