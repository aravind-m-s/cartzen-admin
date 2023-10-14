import 'dart:developer';
import 'dart:io';

import 'package:cartzen_admin/Controllers/category/category_bloc.dart';
import 'package:cartzen_admin/Core/constants.dart';
import 'package:cartzen_admin/Models/category_model.dart';
import 'package:cartzen_admin/views/category/screen_category.dart';
import 'package:cartzen_admin/views/common/app_bar.dart';
import 'package:cartzen_admin/views/common/bottom_bordered_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final TextEditingController _controller = TextEditingController();
String _image = '';
String id = '';

class ScreenAddEditCategory extends StatelessWidget {
  const ScreenAddEditCategory({super.key, this.isEdit = false, this.category});
  final bool isEdit;
  final CategoryModel? category;

  getAllData(context) async {
    final image = await fileFromImageUrl(category!.image, category!.category);
    _image = image.path;
    BlocProvider.of<CategoryBloc>(context).add(AddImage(image: _image));
    _controller.text = category!.category;
    id = category!.id;
  }

  Future<File> fileFromImageUrl(image, String name) async {
    final response = await http.get(Uri.parse(image));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(join(documentDirectory.path, '$name.png'));
    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    if (isEdit) {
      getAllData(context);
    }
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(title: 'Add Category', context: context),
      body: Padding(
        padding: const EdgeInsets.all(padding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const ImageWidget(),
            Form(
              key: formKey,
              child: InputField(
                controller: _controller,
                label: 'Category',
              ),
            ),
            ConfirmButton(
              controller: _controller,
              formKey: formKey,
            ),
            kHeight,
          ],
        ),
      ),
      bottomSheet: const BottomBorderedCard(),
    );
  }
}

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () {
          clicked(context);
        },
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state.image == '' || _image == '') {
              return Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(
                    defaultRadius,
                  ),
                ),
              );
            } else {
              return Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(defaultRadius),
                  image: DecorationImage(
                      image: FileImage(File(_image)), fit: BoxFit.cover),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

clicked(context) async {
  await ImagePicker().pickImage(source: ImageSource.gallery).then(
    (value) {
      value == null ? _image = '' : _image = value.path;
    },
  ).then((value) =>
      BlocProvider.of<CategoryBloc>(context).add(AddImage(image: _image)));
}

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({
    Key? key,
    required this.controller,
    required this.formKey,
  }) : super(key: key);

  final TextEditingController controller;
  final formKey;

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
          if (formKey.currentState!.validate()) {
            if (_image.isNotEmpty) {
              if (id == '') {
                BlocProvider.of<CategoryBloc>(context).add(
                  AddCategory(
                    cat: CategoryModel(
                      category: controller.text.trim(),
                      image: _image,
                      offer: 0,
                    ),
                  ),
                );
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const ScreenCategory(),
                ));
              } else {
                BlocProvider.of<CategoryBloc>(context).add(
                  AddCategory(
                      cat: CategoryModel(
                        category: controller.text.trim(),
                        image: _image,
                        offer: 0,
                      ),
                      id: id),
                );
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const ScreenCategory(),
                ));
              }
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Center(child: Text("Oops!")),
                  content: Text("At least one image is requried",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color:
                              Theme.of(context).textTheme.titleLarge!.color)),
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
            }
          }
        },
      ),
    );
  }
}

class InputField extends StatelessWidget {
  const InputField({
    Key? key,
    required this.controller,
    required this.label,
  }) : super(key: key);

  final TextEditingController controller;
  final String label;

  getData(int data) {
    controller.text = data.toString();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(color: darkMode ? Colors.white : Colors.black),
      controller: controller,
      cursorColor: themeColor,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Category Cannot be empty';
        } else if (value.length > 15) {
          return 'Only 15 characters allowed';
        } else {
          return null;
        }
      },
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
