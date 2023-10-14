part of 'order_bloc.dart';

@immutable
abstract class OrderEvent {}

class GetAllOrders extends OrderEvent {}

class ChangeStatus extends OrderEvent {
  final String id;
  final String status;
  ChangeStatus({
    required this.id,
    required this.status,
  });
}
