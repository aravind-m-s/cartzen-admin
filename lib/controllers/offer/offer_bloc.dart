import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

part 'offer_event.dart';
part 'offer_state.dart';

class OfferBloc extends Bloc<OfferEvent, OfferState> {
  OfferBloc() : super(OfferInitial()) {
    on<ChangeOfferType>((event, emit) {
      emit(OfferState(value: event.value));
    });
  }
}
