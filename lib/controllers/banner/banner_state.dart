part of 'banner_bloc.dart';

class BannerState {
  final String image;
  final List<BannerModel> banners;
  BannerState({this.image = '', this.banners = const []});
}

class BannerInitial extends BannerState {
  BannerInitial() : super(image: '');
}
