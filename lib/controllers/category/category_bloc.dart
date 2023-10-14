import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cartzen_admin/Models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryInitial()) {
    on<GetAllCategory>((event, emit) async {
      emit(CategoryState(
          cat: state.cat, category: state.category, isLoading: true));
      final List<CategoryModel> categories = [];
      await FirebaseFirestore.instance
          .collection('category')
          .get()
          .then((value) {
        for (var cat in value.docs) {
          categories.add(CategoryModel.fromJson(cat.data()));
        }
      });
      emit(CategoryState(
          cat: state.cat, category: categories, isLoading: false));
    });
    on<AddImage>((event, emit) {
      emit(CategoryState(
          cat: state.cat, isLoading: true, category: state.category));
      emit(CategoryState(
          cat: state.cat,
          isLoading: false,
          image: event.image,
          category: state.category));
    });
    on<AddCategory>((event, emit) async {
      final path = 'categoryImages/${event.cat.category}';
      final file = File(event.cat.image);
      final uploadPath =
          FirebaseStorage.instance.ref().child(path).putFile(file);
      final snapshot = await uploadPath.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();
      if (event.id == '') {
        log(event.id);
        final document =
            FirebaseFirestore.instance.collection('category').doc();

        final Map<String, dynamic> cat = CategoryModel(
                category: event.cat.category,
                offer: event.cat.offer,
                image: url,
                id: document.id)
            .toJson();
        document.set(cat);
      } else {
        final document =
            FirebaseFirestore.instance.collection('category').doc(event.id);

        final Map<String, dynamic> cat = CategoryModel(
                category: event.cat.category,
                offer: event.cat.offer,
                image: url,
                id: document.id)
            .toJson();
        document.update(cat);
      }
    });
    on<ChangeCategory>((event, emit) {
      emit(CategoryState(
          cat: event.category,
          category: state.category,
          image: state.image,
          isLoading: state.isLoading));
    });
  }
}
