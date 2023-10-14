part of 'offer_bloc.dart';

@immutable
abstract class OfferEvent {}

class ChangeOfferType extends OfferEvent {
  final bool value;
  ChangeOfferType({required this.value});
}
