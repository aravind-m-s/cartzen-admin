import 'package:cartzen_admin/Controllers/products/products_bloc.dart';
import 'package:cartzen_admin/Core/constants.dart';
import 'package:cartzen_admin/Models/product_model.dart';
import 'package:cartzen_admin/views/common/app_bar.dart';
import 'package:cartzen_admin/views/common/drawer.dart';
import 'package:cartzen_admin/views/product_edit_add/add_edit_product_part1.dart';
import 'package:cartzen_admin/views/product_offer_add_edit/screen_product_offer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenProducts extends StatelessWidget {
  const ScreenProducts({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => BlocProvider.of<ProductsBloc>(context).add(GetAllProduct()),
    );
    return Scaffold(
      appBar: customAppBar(title: "Products", context: context),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: padding),
        child: BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: themeColor,
                ),
              );
            }
            if (state.products.isEmpty) {
              return Center(
                child: Text(
                  "No Products available",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              );
            }
            return CustomScrollView(
              slivers: [
                const TopTItle(),
                ProductsList(products: state.products),
                const DeletedTitle(),
                DeletedProducts(products: state.products)
              ],
            );
          },
        ),
      ),
      floatingActionButton: const FAB(),
    );
  }
}

class DeletedProducts extends StatelessWidget {
  const DeletedProducts({
    Key? key,
    required this.products,
  }) : super(key: key);
  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> deletedProduct =
        products.where((element) => element.isDeleted).toList();
    if (deletedProduct.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate(
          [
            kHeight,
            Center(
              child: Text(
                'No deleted Products',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      );
    }
    return SliverList(
      delegate: SliverChildListDelegate(
        List.generate(
          deletedProduct.length,
          (index) => ProductCard(
            product: deletedProduct[index],
          ),
        ),
      ),
    );
  }
}

class DeletedTitle extends StatelessWidget {
  const DeletedTitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          const Title(
            title: 'Deleted Products',
          ),
        ],
      ),
    );
  }
}

class ProductsList extends StatelessWidget {
  const ProductsList({Key? key, required this.products}) : super(key: key);
  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    final activeProduct = products
        .where(
          (element) => !element.isDeleted,
        )
        .toList();
    if (activeProduct.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate(
          [
            Center(
              child: Text(
                'No Active Products',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            kHeight,
          ],
        ),
      );
    }
    return SliverList(
      delegate: SliverChildListDelegate(
        List.generate(
          activeProduct.length,
          (index) {
            return ProductCard(
              product: activeProduct[index],
            );
          },
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  final ProductModel product;

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Details(product: product),
              Buttons(
                product: product,
              ),
            ],
          ),
        ),
        kHeight20,
      ],
    );
  }
}

class Buttons extends StatelessWidget {
  const Buttons({
    Key? key,
    required this.product,
  }) : super(key: key);
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        kWidth10,
        ButtonWidget(
          color: Colors.green,
          label: "Edit Offer",
          id: product.id,
          product: product,
        ),
        kWidth10,
        ButtonWidget(
          color: themeColor,
          label: "Edit",
          id: product.id,
          product: product,
        ),
        kWidth10,
        product.isDeleted
            ? ButtonWidget(
                color: Colors.red,
                label: "Restore",
                id: product.id,
              )
            : ButtonWidget(
                color: Colors.red,
                label: "Delete",
                id: product.id,
              ),
        kWidth10,
      ],
    );
  }
}

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    Key? key,
    required this.color,
    required this.label,
    required this.id,
    this.product,
  }) : super(key: key);
  final Color color;
  final String label;
  final String id;
  final ProductModel? product;

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
      onPressed: () {
        if (label == "Delete") {
          BlocProvider.of<ProductsBloc>(context).add(DeleteProduct(id: id));
        } else if (label == "Restore") {
          BlocProvider.of<ProductsBloc>(context).add(RestoreProduct(id: id));
        } else if (label == "Edit") {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ScreenAddEditProduct(
              product: product,
            ),
          ));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ScreenProductOffer(
              product: product!,
            ),
          ));
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
    Key? key,
    required this.product,
  }) : super(key: key);

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ImageWidget(product: product),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            ProductColors(product: product),
            ProductPrices(product: product),
            ProductStock(product: product),
            ProductOffer(product: product),
          ],
        ),
      ],
    );
  }
}

class ProductOffer extends StatelessWidget {
  const ProductOffer({
    super.key,
    required this.product,
  });
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Offer: ',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          '${product.offer.toString()} ${product.isPercent ? '%' : '₹'}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class ProductStock extends StatelessWidget {
  const ProductStock({
    super.key,
    required this.product,
  });
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Stock:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          product.stock.toString(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class ProductColors extends StatelessWidget {
  const ProductColors({
    Key? key,
    required this.product,
  }) : super(key: key);

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Colors:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Row(
          children: List.generate(
            product.colors.length,
            (index) => Row(
              children: [
                kWidth5,
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Color(
                    int.parse(
                      product.colors[index],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class ProductPrices extends StatelessWidget {
  const ProductPrices({
    Key? key,
    required this.product,
  }) : super(key: key);

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Price: ',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          '₹' + product.price.toString(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    Key? key,
    required this.product,
  }) : super(key: key);

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 125,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            product.images[0],
          ),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

class TopTItle extends StatelessWidget {
  const TopTItle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          kHeight,
          const Title(title: "Active Products"),
          kHeight,
        ],
      ),
    );
  }
}

class FAB extends StatelessWidget {
  const FAB({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: themeColor,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const ScreenAddEditProduct(),
        ));
      },
    );
  }
}

class Title extends StatelessWidget {
  const Title({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}
