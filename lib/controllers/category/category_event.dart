part of 'category_bloc.dart';

@immutable
abstract class CategoryEvent {}

class AddImage extends CategoryEvent {
  final String image;
  AddImage({required this.image});
}

class AddCategory extends CategoryEvent {
  final CategoryModel cat;
  final String id;
  AddCategory({required this.cat, this.id = ''});
}

class GetAllCategory extends CategoryEvent {}

class ChangeCategory extends CategoryEvent {
  final String category;
  ChangeCategory({required this.category});
}
