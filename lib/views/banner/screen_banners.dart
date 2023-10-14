import 'package:cartzen_admin/controllers/banner/banner_bloc.dart';
import 'package:cartzen_admin/core/constants.dart';
import 'package:cartzen_admin/models/banner_model.dart';
import 'package:cartzen_admin/views/banner_add_edit/banner_add_edit.dart';
import 'package:cartzen_admin/views/common/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenBanners extends StatelessWidget {
  const ScreenBanners({super.key});

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<BannerBloc>(context).add(GetAllBanners());
    return Scaffold(
      appBar: customAppBar(title: 'Banners', context: context),
      body: Padding(
        padding: const EdgeInsets.all(2 * padding),
        child: BlocBuilder<BannerBloc, BannerState>(
          builder: (context, state) {
            if (state.banners.isEmpty) {
              return Center(
                child: Text(
                  'No banners Found',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              );
            }
            return ListView.separated(
              itemBuilder: (context, index) => Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: themeColor,
                      borderRadius: BorderRadius.circular(defaultRadius),
                      image: DecorationImage(
                          image: NetworkImage(
                            state.banners[index].image,
                          ),
                          fit: BoxFit.cover),
                    ),
                  ),
                  kHeight,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ButtonWidget(
                        label: 'Edit',
                        index: index,
                        banner: state.banners[index],
                      ),
                      ButtonWidget(
                        label: 'Delete',
                        index: index,
                        banner: state.banners[index],
                      ),
                    ],
                  )
                ],
              ),
              separatorBuilder: (context, index) => kHeight,
              itemCount: state.banners.length,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const BannersAddEdit(),
          ));
        },
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    required this.label,
    required this.index,
    required this.banner,
  });
  final String label;
  final BannerModel banner;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: label == 'Edit' ? themeColor : Colors.red,
      ),
      onPressed: () {
        if (label == 'Delete') {
          BlocProvider.of<BannerBloc>(context).add(DeleteBanner(id: banner.id));
          BlocProvider.of<BannerBloc>(context).add(GetAllBanners());
        } else {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BannersAddEdit(
              banner: banner,
            ),
          ));
        }
      },
      child: Text(
        label,
        style: TextStyle(color: Theme.of(context).textTheme.titleMedium!.color),
      ),
    );
  }
}
