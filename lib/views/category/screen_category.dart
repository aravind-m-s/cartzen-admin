import 'package:cartzen_admin/Controllers/category/category_bloc.dart';
import 'package:cartzen_admin/Core/constants.dart';
import 'package:cartzen_admin/Models/category_model.dart';
import 'package:cartzen_admin/views/add_edit_category/screen_add_edit_category.dart';
import 'package:cartzen_admin/views/category_offer/screen_category_offer.dart';
import 'package:cartzen_admin/views/common/app_bar.dart';
import 'package:cartzen_admin/views/common/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenCategory extends StatelessWidget {
  const ScreenCategory({super.key});

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<CategoryBloc>(context).add(GetAllCategory());

    return Scaffold(
      appBar: customAppBar(title: "Categories", context: context),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: padding),
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            final categories = state.category;
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: themeColor,
                ),
              );
            }
            if (categories == null || categories.isEmpty) {
              return Center(
                child: Text(
                  "No Categories available",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              );
            }
            return CustomScrollView(
              slivers: [
                const ActiveTitle(),
                CategoryItems(
                    categories: categories
                        .where((element) => element.isDeleted == false)
                        .toList()),
                const DeletedTitle(),
                CategoryItems(
                    categories: categories
                        .where((element) => element.isDeleted == true)
                        .toList()),
              ],
            );
          },
        ),
      ),
      floatingActionButton: const FAB(),
    );
  }
}

class CategoryItems extends StatelessWidget {
  const CategoryItems({
    super.key,
    required this.categories,
  });
  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        categories.isEmpty
            ? [
                Center(
                  child: Text(
                    'No active Products',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                )
              ]
            : List.generate(
                categories.length,
                (index) => CategoryCard(
                  category: categories[index],
                ),
              ),
      ),
    );
  }
}

class ActiveTitle extends StatelessWidget {
  const ActiveTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          kHeight10,
          Text(
            'Active Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          kHeight10,
        ],
      ),
    );
  }
}

class DeletedTitle extends StatelessWidget {
  const DeletedTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          kHeight10,
          Text(
            'Deleted Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          kHeight10,
        ],
      ),
    );
  }
}

class FAB extends StatelessWidget {
  const FAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: themeColor,
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const ScreenAddEditCategory(),
        ));
      },
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
  });
  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(
              defaultRadius,
            ),
          ),
          child: CategoryDetails(category: category),
        ),
        kHeight,
      ],
    );
  }
}

class CategoryDetails extends StatelessWidget {
  const CategoryDetails({
    super.key,
    required this.category,
  });

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Details(category: category),
          kHeight,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ButtonWidget(
                color: Colors.green,
                label: "Edit Offer",
                category: category,
              ),
              kWidth10,
              ButtonWidget(
                color: themeColor,
                label: "Edit",
                category: category,
              ),
              kWidth10,
              category.isDeleted
                  ? ButtonWidget(
                      color: Colors.red,
                      label: "Restore",
                      category: category,
                    )
                  : ButtonWidget(
                      color: Colors.red,
                      label: "Delete",
                      category: category,
                    )
            ],
          )
        ],
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    Key? key,
    required this.color,
    required this.label,
    required this.category,
  }) : super(key: key);
  final Color color;
  final String label;
  final CategoryModel category;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              defaultRadius,
            ),
          ),
          backgroundColor: color),
      onPressed: () async {
        if (label == "Edit") {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ScreenAddEditCategory(
              isEdit: true,
              category: category,
            ),
          ));
        } else if (label == "Edit Offer") {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ScreenCategoryOffer(
              category: category,
            ),
          ));
        } else if (label == "Delete" || label == "Restore") {
          final cat = CategoryModel(
            id: category.id,
            category: category.category,
            offer: category.offer,
            image: category.image,
            isDeleted: !category.isDeleted,
            isPercent: category.isPercent,
          );

          FirebaseFirestore.instance
              .collection('category')
              .doc(category.id)
              .update(cat.toJson());
        }
      },
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class Details extends StatelessWidget {
  const Details({
    super.key,
    required this.category,
  });

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ImageWidget(category: category),
        kWidth10,
        Column(
          children: [
            Text(
              'Name: ${category.category}',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Offer: ${category.offer} ${category.isPercent ? '%' : '₹'}',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        )
      ],
    );
  }
}

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    required this.category,
  });
  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: BorderRadius.circular(defaultRadius),
        image: DecorationImage(
            image: NetworkImage(category.image), fit: BoxFit.cover),
      ),
      height: 100,
      width: 100,
    );
  }
}
