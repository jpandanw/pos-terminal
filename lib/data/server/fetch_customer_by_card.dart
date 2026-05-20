import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pos_terminal/config.dart';
import 'package:result_dart/result_dart.dart';

final _dio = Dio();

class CustomerCard {
  final String id;
  final String cardId;
  final String status;

  const CustomerCard({
    required this.id,
    required this.cardId,
    required this.status,
  });

  factory CustomerCard.fromJson(Map<String, dynamic> json) => CustomerCard(
    id: json['id'] as String,
    cardId: json['cardId'] as String,
    status: json['status'] as String,
  );
}

class CustomerInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String? birthdate;
  final double currentPoints;
  final CustomerCard card;

  const CustomerInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.birthdate,
    required this.currentPoints,
    required this.card,
  });

  String get fullName => '$firstName $lastName';

  factory CustomerInfo.fromJson(Map<String, dynamic> json) => CustomerInfo(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    birthdate: json['birthdate'] as String?,
    currentPoints: double.tryParse(json['currentPoints'].toString()) ?? 0.0,
    card: CustomerCard.fromJson(json['card'] as Map<String, dynamic>),
  );
}

AsyncResult<CustomerInfo> fetchCustomerByCard(String cardId) async {
  try {
    final response = await _dio.get(
      '$API_URL/terminal/customers/card/$cardId',
    );

    final data = response.data as Map<String, dynamic>;
    if (data['ok'] != true || data['customer'] == null) {
      return Exception('Customer not found').toFailure();
    }

    final customer = CustomerInfo.fromJson(
      data['customer'] as Map<String, dynamic>,
    );
    return customer.toSuccess();
  } catch (e) {
    debugPrint('POS ERROR (fetchCustomerByCard): $e');
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404) {
        return Exception('No customer found for this card').toFailure();
      }
      return Exception(
        e.response?.data?.toString() ?? e.message,
      ).toFailure();
    }
    return Exception(e.toString()).toFailure();
  }
}
