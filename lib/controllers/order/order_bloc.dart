import 'package:bloc/bloc.dart';
import 'package:cartzen_admin/models/order_model.dart';
import 'package:cartzen_admin/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    on<GetAllOrders>((event, emit) async {
      await FirebaseFirestore.instance
          .collection('orders')
          .get()
          .then((value) async {
        final List<OrderModel> orders = [];
        for (var element in value.docs) {
          orders.add(OrderModel.fromJson(element.data()));
        }
        await FirebaseFirestore.instance
            .collection('products')
            .get()
            .then((value) async {
          final List<ProductModel> products = [];
          for (var element in value.docs) {
            products.add(ProductModel.fromJson(element.data()));
          }
          emit(OrderState(orders: orders, products: products));
        });
      });
    });
    on<ChangeStatus>((event, emit) async {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(event.id)
          .get()
          .then((value) async {
        if (value.data() != null) {
          final data = value.data();
          data!['status'] = event.status;
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(event.id)
              .update(data)
              .then((value) async {
            await FirebaseFirestore.instance
                .collection('orders')
                .get()
                .then((value) async {
              final List<OrderModel> orders = [];
              for (var element in value.docs) {
                orders.add(OrderModel.fromJson(element.data()));
              }
              await FirebaseFirestore.instance
                  .collection('products')
                  .get()
                  .then((value) async {
                final List<ProductModel> products = [];
                for (var element in value.docs) {
                  products.add(ProductModel.fromJson(element.data()));
                }
                emit(OrderState(orders: orders, products: products));
                if (event.status == "Returned") {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(data['uid'])
                      .get()
                      .then((value) {
                    if (value.data() != null) {
                      final user = value.data()!;
                      user['wallet'] =
                          user['wallet'] + int.parse(data['total']);
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(data['uid'])
                          .update(user);
                    }
                  });
                }
              });
            });
          });
        }
      });
    });
  }
}
