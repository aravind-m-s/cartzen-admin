part of 'dropdown_bloc.dart';

class DropdownState {
  final String dropdownValue;
  final List<String> categories;
  DropdownState({required this.dropdownValue, required this.categories});
}

class DropdownInitial extends DropdownState {
  DropdownInitial() : super(dropdownValue: "", categories: []);
}
