part of 'category_bloc.dart';

class CategoryState {
  String image;
  bool isLoading;
  List<CategoryModel>? category;
  String cat;
  CategoryState(
      {this.image = '', this.cat = '', this.isLoading = false, this.category});
}

class CategoryInitial extends CategoryState {}
