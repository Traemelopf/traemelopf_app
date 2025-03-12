import 'package:get/get_utils/get_utils.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/address/domain/repositories/address_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class AddressRepository implements AddressRepositoryInterface<AddressModel> {
  final ApiClient apiClient;

  AddressRepository({required this.apiClient});

  @override
  Future add(AddressModel addressModel) async {
    return await _addAddress(addressModel);
  }

  Future<ResponseModel> _addAddress(AddressModel addressModel) async {
    final response = await apiClient.postData(
        AppConstants.addAddressUri, addressModel.toJson(),
        handleError: false);
    if (response.statusCode == 200) {
      String? message = response.data["message"];
      List<int> zoneIds = [];
      response.data['zone_ids'].forEach((z) => zoneIds.add(z));
      return ResponseModel(true, message, zoneIds: zoneIds);
    } else {
      return ResponseModel(
          false,
          response.statusMessage == 'Out of coverage!'
              ? 'service_not_available_in_this_area'.tr
              : response.statusMessage);
    }
  }

  @override
  Future delete(int? id) async {
    return await _removeAddressByID(id);
  }

  Future<ResponseModel> _removeAddressByID(int? id) async {
    final response = await apiClient.postData(
        '${AppConstants.removeAddressUri}$id', {"_method": "delete"},
        handleError: false);
    if (response.statusCode == 200) {
      return ResponseModel(true, response.data['message']);
    } else {
      return ResponseModel(false, response.statusMessage);
    }
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) async {
    return await _getAllAddress();
  }

  Future<List<AddressModel>?> _getAllAddress() async {
    List<AddressModel>? addressList;
    final response = await apiClient.getData(AppConstants.addressListUri);
    if (response.statusCode == 200) {
      addressList = [];
      response.data['addresses'].forEach((address) {
        addressList!.add(AddressModel.fromJson(address));
      });
    }
    return addressList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) async {
    return await _updateAddress(body, id);
  }

  Future<ResponseModel> _updateAddress(
      Map<String, dynamic> addressBody, int? addressId) async {
    final response = await apiClient.putData(
        '${AppConstants.updateAddressUri}$addressId', addressBody);
    if (response.statusCode == 200) {
      return ResponseModel(true, response.data["message"]);
    } else {
      return ResponseModel(false, response.statusMessage);
    }
  }
}
