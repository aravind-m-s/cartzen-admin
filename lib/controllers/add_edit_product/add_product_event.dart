part of 'add_product_bloc.dart';

@immutable
abstract class AddProductEvent {}

class AddImages extends AddProductEvent {
  final List<File> images;
  AddImages({required this.images});
}

class RemoveImages extends AddProductEvent {
  final List<File> images;
  RemoveImages({required this.images});
}

class AddProduct extends AddProductEvent {
  final Map<String, dynamic> product;
  final List<File> images;
  AddProduct({required this.product, required this.images});
}

class EditProduct extends AddProductEvent {
  final Map<String, dynamic> product;
  final List<File> images;
  EditProduct({required this.product, required this.images});
}

class AddSize extends AddProductEvent {
  final int index;
  AddSize({required this.index});
}

class RemoveSize extends AddProductEvent {
  final int index;
  RemoveSize({required this.index});
}

class AddColor extends AddProductEvent {
  final Color color;
  AddColor({required this.color});
}

class RemoveColor extends AddProductEvent {
  final Color color;
  RemoveColor({required this.color});
}
