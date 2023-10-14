part of 'coupon_bloc.dart';

class CouponState {
  final List<CouponModel> coupons;
  final String date;
  CouponState({required this.coupons, required this.date});
}

class CouponInitial extends CouponState {
  CouponInitial() : super(coupons: [], date: '');
}
