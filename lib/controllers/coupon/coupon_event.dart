part of 'coupon_bloc.dart';

@immutable
abstract class CouponEvent {}

class GetAllCoupon extends CouponEvent {}

class AddCoupon extends CouponEvent {
  final CouponModel coupon;
  AddCoupon({required this.coupon});
}

class EditCoupon extends CouponEvent {
  final CouponModel coupon;
  EditCoupon({required this.coupon});
}

class DeleteCoupon extends CouponEvent {
  final String id;
  DeleteCoupon({required this.id});
}

class ChangeDate extends CouponEvent {
  final String date;
  ChangeDate({required this.date});
}
