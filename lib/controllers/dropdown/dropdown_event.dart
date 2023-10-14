part of 'dropdown_bloc.dart';

@immutable
abstract class DropdownEvent {}

class GetAllCategory extends DropdownEvent {}

class ChangeCategory extends DropdownEvent {
  final String category;
  ChangeCategory({required this.category});
}
