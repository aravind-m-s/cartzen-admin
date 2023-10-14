part of 'products_bloc.dart';

@immutable
abstract class ProductsEvent {}

class GetAllProduct extends ProductsEvent {}

class DeleteProduct extends ProductsEvent {
  final String id;
  DeleteProduct({required this.id});
}

class RestoreProduct extends ProductsEvent {
  final String id;
  RestoreProduct({required this.id});
}

class ResetProducts extends ProductsEvent {
  final List<ProductModel> products;
  ResetProducts({required this.products});
}
