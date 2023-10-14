import 'dart:io';

import 'package:cartzen_admin/controllers/banner/banner_bloc.dart';
import 'package:cartzen_admin/core/constants.dart';
import 'package:cartzen_admin/models/banner_model.dart';
import 'package:cartzen_admin/views/common/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

String image = '';

class BannersAddEdit extends StatelessWidget {
  const BannersAddEdit({super.key, this.banner});
  final BannerModel? banner;

  getData(BuildContext context) async {
    final response = await http.get(Uri.parse(banner!.image));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(join(documentDirectory.path, '${banner!.id}.png'));
    file.writeAsBytesSync(response.bodyBytes);
    image = file.path;
    BlocProvider.of<BannerBloc>(context).add(EditImage(image: image));
  }

  @override
  Widget build(BuildContext context) {
    image = '';
    if (banner != null) {
      getData(context);
    }

    return Scaffold(
      appBar: customAppBar(title: 'Add banners', context: context),
      body: Padding(
        padding: const EdgeInsets.all(padding * 2),
        child: BlocBuilder<BannerBloc, BannerState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    final img = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (img != null) {
                      BlocProvider.of<BannerBloc>(context)
                          .add(EditImage(image: img.path));
                      image = img.path;
                    }
                  },
                  child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(defaultRadius),
                          image: image == ''
                              ? null
                              : DecorationImage(
                                  image: FileImage(File(image)),
                                  fit: BoxFit.cover)),
                      child: image == ''
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image,
                                  size: 70,
                                ),
                                Text(
                                  'Choose\nImage',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge,
                                )
                              ],
                            )
                          : null),
                ),
                kHeight,
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      child: Text(
                        "Continue",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      onPressed: () {
                        if (banner == null) {
                          BlocProvider.of<BannerBloc>(context).add(
                              AddBanner(banner: BannerModel(image: image)));
                          Navigator.of(context).pop();
                        } else {
                          BlocProvider.of<BannerBloc>(context).add(EditBanner(
                              banner:
                                  BannerModel(image: image, id: banner!.id)));
                          Navigator.of(context).pop();
                        }
                      }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
