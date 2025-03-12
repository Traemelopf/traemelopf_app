import 'package:dio/dio.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/parcel/domain/models/parcel_category_model.dart';
import 'package:sixam_mart/features/parcel/domain/models/parcel_instruction_model.dart';
import 'package:sixam_mart/features/parcel/domain/models/video_content_model.dart';
import 'package:sixam_mart/features/parcel/domain/models/why_choose_model.dart';
import 'package:sixam_mart/features/parcel/domain/repositories/parcel_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class ParcelRepository implements ParcelRepositoryInterface {
  final ApiClient apiClient;
  ParcelRepository({required this.apiClient});

  @override
  Future<Response> getPlaceDetails(String? placeID) async {
    return await apiClient
        .getData('${AppConstants.placeDetailsUri}?placeid=$placeID');
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id, {bool isVideoDetails = true}) async {
    if (isVideoDetails) {
      return await _getVideoContentDetails();
    } else {
      return await _getWhyChooseDetails();
    }
  }

  Future<VideoContentModel?> _getVideoContentDetails() async {
    VideoContentModel? videoContentDetails;
    final response = await apiClient.getData(AppConstants.videoContentUri);
    if (response.statusCode == 200) {
      videoContentDetails = VideoContentModel.fromJson(response.data);
    }
    return videoContentDetails;
  }

  Future<WhyChooseModel?> _getWhyChooseDetails() async {
    WhyChooseModel? whyChooseDetails;
    final response = await apiClient.getData(AppConstants.whyChooseUri);
    if (response.statusCode == 200) {
      whyChooseDetails = WhyChooseModel.fromJson(response.data);
    }
    return whyChooseDetails;
  }

  @override
  Future getList({int? offset, bool parcelCategory = true}) async {
    if (parcelCategory) {
      return await _getParcelCategory();
    } else {
      return await _getParcelInstruction(offset!);
    }
  }

  Future<List<ParcelCategoryModel>?> _getParcelCategory() async {
    List<ParcelCategoryModel>? parcelCategoryList;
    final response = await apiClient.getData(AppConstants.parcelCategoryUri);
    if (response.statusCode == 200) {
      parcelCategoryList = [];
      response.data.forEach((parcel) =>
          parcelCategoryList!.add(ParcelCategoryModel.fromJson(parcel)));
    }
    return parcelCategoryList;
  }

  Future<List<Data>?> _getParcelInstruction(int offset) async {
    List<Data>? parcelInstructionList;
    final response = await apiClient.getData(
        '${AppConstants.parcelInstructionUri}?limit=10&offset=$offset');
    if (response.statusCode == 200) {
      parcelInstructionList = [];
      parcelInstructionList
          .addAll(ParcelInstructionModel.fromJson(response.data).data!);
    }
    return parcelInstructionList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
