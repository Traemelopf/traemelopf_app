import 'package:dio/dio.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class LoyaltyRepositoryInterface extends RepositoryInterface {
  Future<Response> pointToWallet({int? point});
}
