import 'package:dio/dio.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class ParcelRepositoryInterface<T> implements RepositoryInterface {
  @override
  Future get(String? id, {bool isVideoDetails = true});
  @override
  Future getList({int? offset, bool parcelCategory = true});
  Future<Response> getPlaceDetails(String? placeID);
}
