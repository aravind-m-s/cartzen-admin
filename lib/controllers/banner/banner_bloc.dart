import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cartzen_admin/models/banner_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';

part 'banner_event.dart';
part 'banner_state.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  BannerBloc() : super(BannerInitial()) {
    on<EditImage>((event, emit) {
      emit(BannerState(image: event.image, banners: state.banners));
    });
    on<AddBanner>((event, emit) async {
      final path = 'banners/${event.banner.image}';
      final file = File(event.banner.image);
      final uploadPath =
          FirebaseStorage.instance.ref().child(path).putFile(file);
      final snapshot = await uploadPath.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();
      final doc = FirebaseFirestore.instance.collection('banners').doc();
      final banner = BannerModel(image: url, id: doc.id);
      doc.set(banner.toJson());
    });
    on<EditBanner>((event, emit) async {
      final path = 'banners/${event.banner.image}';
      final file = File(event.banner.image);
      final uploadPath =
          FirebaseStorage.instance.ref().child(path).putFile(file);
      final snapshot = await uploadPath.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();
      final doc =
          FirebaseFirestore.instance.collection('banners').doc(event.banner.id);
      final banner = BannerModel(image: url, id: event.banner.id);
      doc.update(banner.toJson());
    });
    on<DeleteBanner>((event, emit) async {
      final doc =
          FirebaseFirestore.instance.collection('banners').doc(event.id);

      await doc.delete();
    });
    on<GetAllBanners>((event, emit) async {
      await FirebaseFirestore.instance
          .collection('banners')
          .get()
          .then((value) {
        final List<BannerModel> banners = [];
        for (var element in value.docs) {
          banners.add(BannerModel.fromJson(element.data()));
        }
        emit(BannerState(banners: banners, image: state.image));
      });
    });
  }
}
