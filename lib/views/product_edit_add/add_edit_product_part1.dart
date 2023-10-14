import 'dart:io';
import 'dart:developer';

import 'package:cartzen_admin/Controllers/add_edit_product/add_product_bloc.dart';
import 'package:cartzen_admin/Core/constants.dart';
import 'package:cartzen_admin/Models/product_model.dart';
import 'package:cartzen_admin/views/common/app_bar.dart';
import 'package:cartzen_admin/views/product_edit_add/add_edit_product_part2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

final TextEditingController _name = TextEditingController();
final TextEditingController _stock = TextEditingController();
final TextEditingController _description = TextEditingController();
final TextEditingController _price = TextEditingController();
final _formKey = GlobalKey<FormState>();
final List<File> croppedImages = [];

class ScreenAddEditProduct extends StatelessWidget {
  const ScreenAddEditProduct({
    super.key,
    this.product,
  });
  final ProductModel? product;

  @override
  Widget build(BuildContext context) {
    croppedImages.clear();
    List<File> productImages = [];
    if (product != null) {
      getAllData(productImages, context);
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(title: "Add Product", context: context),
      body: Padding(
        padding: const EdgeInsets.all(padding),
        child: ListView(
          children: [
            BlocBuilder<AddProductBloc, AddProductState>(
              builder: (context, state) {
                return InkWell(
                  onTap: () async {
                    List<File> temp = [];
                    if (productImages.length == 4) {
                      return;
                    }
                    await ImagePicker().pickMultiImage().then((value) {
                      if (productImages.length + value.length > 4) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Center(child: Text("Oops!")),
                            content:
                                const Text("There can only be four images"),
                            actions: [
                              TextButton(
                                child: const Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          ),
                        );
                      } else {
                        for (var element in value) {
                          temp.add(File(element.path));
                        }
                      }
                    });
                    await crop(temp, context, productImages);
                    BlocProvider.of<AddProductBloc>(context)
                        .add(AddImages(images: productImages));
                  },
                  child: AddingImageWidget(
                    images: productImages,
                  ),
                );
              },
            ),
            kHeight,
            Form(
              key: _formKey,
              child: Column(
                children: [
                  InputField(controller: _name, label: "Name"),
                  kHeight,
                  InputField(controller: _description, label: "Description"),
                  kHeight,
                  InputField(controller: _stock, label: "Stock"),
                  kHeight,
                  InputField(controller: _price, label: "Price"),
                ],
              ),
            ),
            kHeight,
            ConfirmButton(
              images: productImages,
              editingProduct: product,
            ),
            kHeight50,
          ],
        ),
      ),
    );
  }

  Future<void> crop(
      List<File> temp, BuildContext context, List<File> productImages) async {
    for (int i = 0; i < temp.length; i++) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: temp[i].path,
        aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 7),
        uiSettings: [
          AndroidUiSettings(
            // hideBottomControls: true,
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );
      if (croppedFile != null) {
        productImages.add(File(croppedFile.path));
        if (!croppedImages.contains(File(croppedFile.path))) {
          croppedImages.add(File(croppedFile.path));
        }
      }
    }
  }

  getAllData(List<File> productImages, BuildContext context) async {
    productImages.clear();

    for (int i = 0; i < product!.images.length; i++) {
      await fileFromImageUrl(product!.images[i], i).then((value) {
        BlocProvider.of<AddProductBloc>(context)
            .add(AddImages(images: productImages));
        productImages.add(value);
      });
    }

    croppedImages.addAll(productImages);

    _stock.text = product!.stock.toString();
    _price.text = product!.price.toString();
    _name.text = product!.name.toString();
    _description.text = product!.description.toString();
  }

  Future<File> fileFromImageUrl(image, int index) async {
    final response = await http.get(Uri.parse(image));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(join(documentDirectory.path, 'productImage$index.png'));
    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }
}

class AddingImageWidget extends StatelessWidget {
  const AddingImageWidget({
    Key? key,
    required this.images,
  }) : super(key: key);
  final List<File> images;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      child: BlocBuilder<AddProductBloc, AddProductState>(
        builder: (context, state) {
          if (images.isEmpty) {
            return const NoImageWidget();
          } else {
            return HaveImageWidget(images: images);
          }
        },
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
      style: TextStyle(color: darkMode ? Colors.white : Colors.black),
      keyboardType: label == 'Stock' || label == 'Price'
          ? TextInputType.number
          : TextInputType.text,
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
      cursorColor: themeColor,
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

class NoImageWidget extends StatelessWidget {
  const NoImageWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.image,
          size: 100,
        ),
        Text(
          "Choose an Image",
          style: Theme.of(context).textTheme.titleLarge,
        )
      ],
    );
  }
}

class HaveImageWidget extends StatelessWidget {
  const HaveImageWidget({super.key, required this.images});
  final List<File> images;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Row(
        children: List.generate(
          images.length > 4 ? 4 : images.length,
          (index) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  images.removeAt(index);
                  croppedImages.removeLast();
                  BlocProvider.of<AddProductBloc>(context).add(
                    AddImages(images: images),
                  );
                },
                icon: const Icon(Icons.close),
              ),
              InkWell(
                onTap: () async {
                  CroppedFile? croppedFile = await ImageCropper().cropImage(
                    sourcePath: images[index].path,
                    aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 7),
                    uiSettings: [
                      AndroidUiSettings(
                        // hideBottomControls: true,
                        toolbarTitle: 'Cropper',
                        toolbarColor: Colors.deepOrange,
                        toolbarWidgetColor: Colors.white,
                        initAspectRatio: CropAspectRatioPreset.original,
                        lockAspectRatio: false,
                      ),
                      IOSUiSettings(
                        title: 'Cropper',
                      ),
                      WebUiSettings(
                        context: context,
                      ),
                    ],
                  );
                  if (croppedFile != null) {
                    images[index] = File(croppedFile.path);
                    if (!croppedImages.contains(File(croppedFile.path))) {
                      croppedImages.add(File(croppedFile.path));
                    }
                    BlocProvider.of<AddProductBloc>(context)
                        .add(AddImages(images: images));
                  }
                },
                child: Container(
                  height: 100,
                  width: 81,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    image: DecorationImage(
                      image: FileImage(
                        File(
                          images[index].path.toString(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({
    Key? key,
    required this.images,
    required this.editingProduct,
  }) : super(key: key);

  final ProductModel? editingProduct;
  final List<File> images;

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
          if (_formKey.currentState!.validate()) {
            if (images.length != 4) {
              errorDialog(context);
            } else if (croppedImages.length != 4) {
              log(croppedImages.toString());
              cropErrorDialog(context);
            } else {
              if (editingProduct == null) {
                final product = ProductModel(
                    id: '',
                    name: _name.text,
                    description: _description.text,
                    category: '',
                    colors: [],
                    images: [],
                    keywords: [],
                    sizes: [],
                    stock: int.parse(_stock.text),
                    price: int.parse(_price.text));
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ScreenAddEdit2(product: product, images: images),
                ));
              } else {
                final product = ProductModel(
                  id: editingProduct!.id,
                  name: _name.text,
                  description: _description.text,
                  category: editingProduct!.category,
                  colors: editingProduct!.colors,
                  images: images,
                  keywords: editingProduct!.keywords,
                  sizes: editingProduct!.sizes,
                  stock: int.parse(_stock.text),
                  price: int.parse(_price.text),
                );
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ScreenAddEdit2(
                    product: product,
                    images: images,
                  ),
                ));
              }
            }
          }
        },
      ),
    );
  }

  errorDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text("Oops"),
        ),
        content: const Text(
          "There should be four images",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'))
        ],
      ),
    );
  }

  cropErrorDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text("Oops"),
        ),
        content: const Text(
          "All images should be cropped",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'))
        ],
      ),
    );
  }
}
