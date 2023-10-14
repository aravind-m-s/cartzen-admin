import 'package:bloc/bloc.dart';
import 'package:cartzen_admin/controllers/category/category_bloc.dart';
import 'package:cartzen_admin/models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'dropdown_event.dart';
part 'dropdown_state.dart';

class DropdownBloc extends Bloc<DropdownEvent, DropdownState> {
  DropdownBloc() : super(DropdownInitial()) {
    on<GetAllCategory>((event, emit) async {
      final List<CategoryModel> categories = [];
      await FirebaseFirestore.instance
          .collection('category')
          .get()
          .then((value) {
        for (var cat in value.docs) {
          categories.add(CategoryModel.fromJson(cat.data()));
        }
        final List<String> cats = [];
        for (var element in categories) {
          cats.add(element.category);
        }
        emit(DropdownState(
            dropdownValue: state.dropdownValue, categories: cats));
      });
    });
    on<ChangeCategory>((event, emit) {
      emit(DropdownState(
          categories: state.categories, dropdownValue: event.category));
    });
  }
}
