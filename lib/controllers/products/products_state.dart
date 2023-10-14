part of 'products_bloc.dart';

class ProductsState {
  final List<ProductModel> products;
  final bool isLoading;
  ProductsState({required this.products, required this.isLoading});
}

class ProductsInitial extends ProductsState {
  ProductsInitial() : super(products: [], isLoading: false);
}
