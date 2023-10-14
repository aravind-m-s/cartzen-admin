part of 'add_product_bloc.dart';

class AddProductState {
  final List<File> images;
  final int size;
  final Color color;
  final bool isLoading;
  final bool addingSuccess;
  AddProductState({
    this.images = const [],
    this.size = 5,
    this.color = themeColor,
    this.isLoading = false,
    this.addingSuccess = true,
  });
}

class AddProductInitial extends AddProductState {}
