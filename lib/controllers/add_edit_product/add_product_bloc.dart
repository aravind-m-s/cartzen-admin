import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cartzen_admin/Core/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

part 'add_product_event.dart';
part 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  AddProductBloc() : super(AddProductInitial()) {
    on<AddImages>((event, emit) {
      emit(AddProductState(isLoading: true));
      emit(AddProductState(images: event.images));
      emit(AddProductState(isLoading: false, images: state.images));
    });

    on<AddProduct>((event, emit) async {
      emit(AddProductState(isLoading: true, addingSuccess: false));
      final product = event.product;
      final images = event.images;
      final firebaseImagePaths = [];
      for (int i = 0; i < images.length; i++) {
        final path = 'productImages/${product["name"] + '-' + i.toString()}';
        final file = File(images[i].path);
        final uploadPath =
            FirebaseStorage.instance.ref().child(path).putFile(file);
        final snapshot = await uploadPath.whenComplete(() {});
        final url = await snapshot.ref.getDownloadURL();
        firebaseImagePaths.add(url);
      }
      product['images'] = firebaseImagePaths;
      if (product['id'] == '') {
        final document =
            FirebaseFirestore.instance.collection('products').doc();
        product['id'] = document.id;
        await document.set(product).then(
              (value) => emit(
                AddProductState(isLoading: false, addingSuccess: true),
              ),
            );
      } else {
        final document = FirebaseFirestore.instance
            .collection('products')
            .doc(product['id']);
        await document.update(product).then(
              (value) => emit(
                AddProductState(isLoading: false, addingSuccess: true),
              ),
            );
      }
    });

    on<AddSize>((event, emit) {
      emit(AddProductState(
        size: event.index,
        images: state.images,
      ));
    });
    on<RemoveSize>((event, emit) {
      emit(AddProductState(
        size: event.index,
        images: state.images,
      ));
    });
    on<AddColor>((event, emit) => emit(AddProductState(
          size: state.size,
          images: state.images,
          color: event.color,
        )));
    on<RemoveColor>((event, emit) => emit(AddProductState(
          size: state.size,
          images: state.images,
          color: event.color,
        )));
  }
}
