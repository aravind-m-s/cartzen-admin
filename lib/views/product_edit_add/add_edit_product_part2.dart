import 'dart:developer';
import 'dart:io';
import 'package:cartzen_admin/Controllers/add_edit_product/add_product_bloc.dart';
import 'package:cartzen_admin/Controllers/products/products_bloc.dart';
import 'package:cartzen_admin/controllers/dropdown/dropdown_bloc.dart';
import 'package:cartzen_admin/views/product_edit_add/widgets/chips.dart';
import 'package:cartzen_admin/Core/constants.dart';
import 'package:cartzen_admin/Models/product_model.dart';
import 'package:cartzen_admin/views/common/app_bar.dart';
import 'package:cartzen_admin/views/products/screen_products.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_chip_tags/flutter_chip_tags.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path/path.dart';

String _category = '';
final _formKey = GlobalKey<FormState>();
Color _tempColor = themeColor;

class ScreenAddEdit2 extends StatelessWidget {
  const ScreenAddEdit2({
    super.key,
    required this.product,
    required this.images,
  });
  final ProductModel product;
  final List<File> images;

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<DropdownBloc>(context).add(GetAllCategory());
    final List<String> sizes = ["S", "M", "L", "XL", "XXL"];
    List<int> selectedSizes = [];
    List<Color> selectedColors = [];
    List<String> chips = [];
    if (product.id != '') {
      getAllData(selectedColors, selectedSizes, sizes, chips, context);
    }

    return Scaffold(
      appBar: customAppBar(title: "Add Product", context: context),
      body: BlocBuilder<AddProductBloc, AddProductState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const CircularProgressIndicator();
          } else if (!state.isLoading && !state.addingSuccess) {
            return const CircularProgressIndicator(
              strokeWidth: 2,
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: padding * 2),
            child: ListView(
              children: [
                Column(
                  children: [
                    kHeight,
                    const Titles(label: "Select category"),
                    kHeight,
                    BlocBuilder<DropdownBloc, DropdownState>(
                      builder: (context, state) {
                        if (state.categories.isEmpty) {
                          return Center(
                            child: Text(
                              'No categories',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          );
                        }
                        String value = state.dropdownValue.isEmpty
                            ? state.categories.first
                            : state.dropdownValue;
                        return DropdownButton(
                            hint: const Text(
                              "Choose product",
                              style: TextStyle(color: Colors.black),
                            ),
                            value: value,
                            items: state.categories
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              BlocProvider.of<DropdownBloc>(context)
                                  .add(ChangeCategory(category: value!));
                              _category = value;
                            });
                      },
                    ),
                    kHeight,
                    const Titles(label: "Select Sizes"),
                    kHeight,
                    Sizes(selectedSizes: selectedSizes, sizes: sizes),
                    kHeight,
                    const Titles(label: "Select Colors"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        5,
                        (index) => GestureDetector(
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            colorSelectionDialog(
                                context, selectedColors, index);
                          },
                          child: BlocBuilder<AddProductBloc, AddProductState>(
                            builder: (context, state) {
                              return ColorCard(
                                selectedColors: selectedColors,
                                index: index,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    kHeight,
                    const Titles(label: "Add Keywords"),
                    kHeight,
                    Keywords(chips: chips),
                    kHeight30,
                    ConfirmButton(
                      products: product,
                      images: images,
                      sizeIndexes: selectedSizes,
                      colors: selectedColors,
                      keywords: chips,
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void getAllData(List<Color> selectedColors, List<int> selectedSizes,
      List<String> sizes, List<String> chips, BuildContext context) {
    for (var element in product.colors) {
      selectedColors.add(Color(int.parse(element)));
    }
    for (var element in product.sizes) {
      selectedSizes.add(sizes.indexOf(element));
    }
    for (var element in product.keywords) {
      chips.add(element);
    }
    BlocProvider.of<DropdownBloc>(context)
        .add(ChangeCategory(category: product.category));
    _category = product.category;
  }

  colorSelectionDialog(
      BuildContext context, List<Color> selectedColors, int index) {
    FocusManager.instance.primaryFocus?.unfocus;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ColorPicker(
          pickerAreaBorderRadius: BorderRadius.circular(defaultRadius),
          labelTypes: const [],
          pickerColor: (selectedColors.length - 1 >= index)
              ? selectedColors[index]
              : themeColor,
          onColorChanged: (value) {
            _tempColor = value;
          },
        ),
        actions: [
          const CancelButton(),
          ColorConfirmButton(
            selectedColors: selectedColors,
            index: index,
          ),
        ],
      ),
    );
  }
}

class InputField extends StatelessWidget {
  const InputField({Key? key, required this.controller, required this.label})
      : super(key: key);

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label cannot be empty";
        } else if (value.length > 70) {
          return "$label should be less than 70 characters";
        } else {
          return null;
        }
      },
      maxLines: label == "Description" ? 4 : 1,
      controller: controller,
      style: TextStyle(color: darkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: themeColor,
          ),
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultRadius)),
        focusColor: themeColor,
        hintText: label,
        labelStyle: const TextStyle(color: themeColor),
        label: Text(label),
        alignLabelWithHint: true,
      ),
    );
  }
}

class Sizes extends StatelessWidget {
  const Sizes({
    Key? key,
    required this.selectedSizes,
    required this.sizes,
  }) : super(key: key);

  final List<int> selectedSizes;
  final List<String> sizes;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddProductBloc, AddProductState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            5,
            (index) => SizeCard(
              selectedSizes: selectedSizes,
              sizes: sizes,
              index: index,
            ),
          ),
        );
      },
    );
  }
}

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({
    Key? key,
    required this.products,
    required this.images,
    required this.sizeIndexes,
    required this.colors,
    required this.keywords,
  }) : super(key: key);
  final ProductModel products;
  final List<File> images;
  final List<int> sizeIndexes;
  final List<Color> colors;
  final List<String> keywords;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        child: Text(
          "Continue",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onPressed: () {
          _submit(context);
        },
      ),
    );
  }

  _submit(BuildContext context) {
    if (sizeIndexes.isEmpty && colors.isEmpty) {
      showWarningDialog(context, "Size & Color");
    } else if (sizeIndexes.isEmpty) {
      showWarningDialog(context, "Size");
    } else if (colors.isEmpty) {
      showWarningDialog(context, "Color");
    } else {
      final List<String> sizeTemplate = ["S", "M", "L", "XL", "XXL"];
      final List<String> sizes = [];
      final List<String> colorList = [];
      for (int i = 0; i < sizeIndexes.length; i++) {
        sizes.add(sizeTemplate[i]);
      }
      for (int i = 0; i < colors.length; i++) {
        colorList.add(ColorToHex(colors[i]).toString().substring(6, 16));
      }
      final ProductModel pdt = ProductModel(
        sizes: sizes,
        colors: colorList,
        keywords: keywords,
        id: products.id,
        name: products.name,
        description: products.description,
        category: _category,
        images: [],
        stock: products.stock,
        price: products.price,
      );
      BlocProvider.of<AddProductBloc>(context).add(
        AddProduct(
          product: pdt.toJson(),
          images: images,
        ),
      );
      BlocProvider.of<ProductsBloc>(context).add(GetAllProduct());
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ScreenProducts(),
    ));
    BlocProvider.of<ProductsBloc>(context).add(GetAllProduct());
  }
}

showWarningDialog(BuildContext context, String label) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: const Center(
          child: Text(
        "Ooops!",
        style: TextStyle(color: Colors.red),
      )),
      content: Text(
        "Select at least one $label",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge!,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            "Ok",
            style: TextStyle(color: themeColor),
          ),
        ),
      ],
    ),
  );
}

class Keywords extends StatelessWidget {
  const Keywords({
    Key? key,
    required this.chips,
  }) : super(key: key);

  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return ChipTags(
      list: chips,
      chipColor: themeColor,
      decoration: InputDecoration(
        label: const Text("Chips"),
        hintText: "Separate the keywords with space",
        hintStyle: Theme.of(context).textTheme.bodySmall,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text("Cancel"),
    );
  }
}

class ColorConfirmButton extends StatelessWidget {
  const ColorConfirmButton({
    Key? key,
    required this.selectedColors,
    required this.index,
  }) : super(key: key);

  final List<Color> selectedColors;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        if (!selectedColors.contains(_tempColor)) {
          if (selectedColors.length - 1 >= index) {
            selectedColors[index] = _tempColor;
            BlocProvider.of<AddProductBloc>(context)
                .add(AddColor(color: _tempColor));
            Navigator.of(context).pop();
          } else {
            selectedColors.add(_tempColor);
            BlocProvider.of<AddProductBloc>(context)
                .add(AddColor(color: _tempColor));
            Navigator.of(context).pop();
          }
          _tempColor = themeColor;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Color already selected",
              ),
            ),
          );
          Navigator.of(context).pop();
        }
      },
      child: const Text("Confirm"),
    );
  }
}

class ColorCard extends StatelessWidget {
  const ColorCard({
    Key? key,
    required this.selectedColors,
    required this.index,
  }) : super(key: key);

  final List<Color> selectedColors;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        (selectedColors.length - 1 >= index)
            ? GestureDetector(
                onTap: () {
                  BlocProvider.of<AddProductBloc>(context)
                      .add(RemoveColor(color: selectedColors[index]));

                  selectedColors.removeAt(index);
                },
                child: const ColorDeleteOption(),
              )
            : const SizedBox(
                height: 15,
              ),
        AnimatedContainer(
          duration: kDuration250,
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (selectedColors.length - 1 >= index)
                ? selectedColors[index]
                : Colors.transparent,
            border: Border.all(),
          ),
          // radius: 25,
          child: Center(
            child: Text(
              (selectedColors.length - 1 >= index) ? "" : "Add\nColor",
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}

class ColorDeleteOption extends StatelessWidget {
  const ColorDeleteOption({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 9,
      // backgroundColor: ,
      child: Icon(
        Icons.close_outlined,
        size: 14,
        color: Colors.white,
      ),
    );
  }
}

class SizeCard extends StatelessWidget {
  const SizeCard(
      {Key? key,
      required this.selectedSizes,
      required this.sizes,
      required this.index})
      : super(key: key);

  final List<int> selectedSizes;
  final List<String> sizes;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (selectedSizes.contains(index)) {
          selectedSizes.remove(index);
          BlocProvider.of<AddProductBloc>(context)
              .add(RemoveSize(index: index));
        } else {
          selectedSizes.add(index);

          BlocProvider.of<AddProductBloc>(context).add(AddSize(index: index));
        }
      },
      child: AnimatedContainer(
        duration: kDuration250,
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color:
              selectedSizes.contains(index) ? themeColor : Colors.transparent,
          border: Border.all(),
          borderRadius: BorderRadius.circular(
            defaultRadius / 2,
          ),
        ),
        child: Center(
          child: Text(
            sizes[index],
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: selectedSizes.contains(index)
                      ? Colors.white
                      : Theme.of(context).textTheme.titleLarge!.color,
                ),
          ),
        ),
      ),
    );
  }
}

class Titles extends StatelessWidget {
  const Titles({Key? key, required this.label}) : super(key: key);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}
