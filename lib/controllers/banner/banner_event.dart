part of 'banner_bloc.dart';

@immutable
abstract class BannerEvent {}

class AddBanner extends BannerEvent {
  final BannerModel banner;
  AddBanner({required this.banner});
}

class EditBanner extends BannerEvent {
  final BannerModel banner;
  EditBanner({required this.banner});
}

class DeleteBanner extends BannerEvent {
  final String id;
  DeleteBanner({required this.id});
}

class EditImage extends BannerEvent {
  final String image;
  EditImage({required this.image});
}

class GetAllBanners extends BannerEvent {}
