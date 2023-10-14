import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cartzen_admin/Models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc() : super(ProductsInitial()) {
    on<GetAllProduct>((event, emit) async {
      emit(ProductsState(products: [], isLoading: true));
      final List<ProductModel> products =
          await FirebaseFirestore.instance.collection('products').get().then(
                (value) => value.docs
                    .map(
                      (e) => ProductModel.fromJson(
                        e.data(),
                      ),
                    )
                    .toList(),
              );

      emit(ProductsState(products: products, isLoading: false));
    });
    on<DeleteProduct>((event, emit) async {
      final product = FirebaseFirestore.instance.collection('products');
      product.doc(event.id).update({'isDeleted': true});
      emit(ProductsState(products: state.products, isLoading: true));
      final List<ProductModel> products = await product.get().then(
            (value) => value.docs
                .map(
                  (e) => ProductModel.fromJson(
                    e.data(),
                  ),
                )
                .toList(),
          );
      emit(ProductsState(products: products, isLoading: false));
    });
    on<RestoreProduct>((event, emit) async {
      final product = FirebaseFirestore.instance.collection('products');
      product.doc(event.id).update({'isDeleted': false});
      emit(ProductsState(products: state.products, isLoading: true));
      final List<ProductModel> products = await product.get().then(
            (value) => value.docs
                .map(
                  (e) => ProductModel.fromJson(
                    e.data(),
                  ),
                )
                .toList(),
          );
      emit(ProductsState(products: products, isLoading: false));
    });
    on<ResetProducts>((event, emit) {
      emit(ProductsState(products: event.products, isLoading: false));
    });
  }
}
