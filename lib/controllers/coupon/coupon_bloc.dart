import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cartzen_admin/models/coupon_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'coupon_event.dart';
part 'coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  CouponBloc() : super(CouponInitial()) {
    on<GetAllCoupon>((event, emit) async {
      await FirebaseFirestore.instance
          .collection('coupons')
          .get()
          .then((value) {
        final List<CouponModel> coupons = [];
        if (value.docs.isNotEmpty) {
          for (var element in value.docs) {
            coupons.add(CouponModel.fromJson(element.data()));
          }
          emit(CouponState(coupons: coupons, date: state.date));
        }
      });
    });
    on<AddCoupon>((event, emit) async {
      await FirebaseFirestore.instance
          .collection('coupons')
          .add(event.coupon.toJson())
          .then((value) async {
        await FirebaseFirestore.instance
            .collection('coupons')
            .get()
            .then((value) {
          final List<CouponModel> coupons = [];
          if (value.docs.isNotEmpty) {
            for (var element in value.docs) {
              coupons.add(CouponModel.fromJson(element.data()));
            }
            emit(CouponState(coupons: coupons, date: state.date));
          }
        });
      });
    });
    on<EditCoupon>((event, emit) async {
      await FirebaseFirestore.instance
          .collection('coupons')
          .doc(event.coupon.id)
          .update(event.coupon.toJson())
          .then((value) async {
        await FirebaseFirestore.instance
            .collection('coupons')
            .get()
            .then((value) {
          final List<CouponModel> coupons = [];
          if (value.docs.isNotEmpty) {
            for (var element in value.docs) {
              coupons.add(CouponModel.fromJson(element.data()));
            }
            emit(CouponState(coupons: coupons, date: state.date));
          }
        });
      });
    });
    on<DeleteCoupon>((event, emit) async {
      await FirebaseFirestore.instance
          .collection('coupons')
          .doc(event.id)
          .delete()
          .then((value) async {
        await FirebaseFirestore.instance
            .collection('coupons')
            .get()
            .then((value) {
          final List<CouponModel> coupons = [];

          for (var element in value.docs) {
            coupons.add(CouponModel.fromJson(element.data()));
          }
          emit(CouponState(coupons: coupons, date: state.date));
        });
      });
    });
    on<ChangeDate>((event, emit) {
      emit(CouponState(coupons: state.coupons, date: event.date));
    });
  }
}
