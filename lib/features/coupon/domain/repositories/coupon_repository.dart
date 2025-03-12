import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/coupon/domain/models/coupon_model.dart';
import 'package:sixam_mart/features/coupon/domain/repositories/coupon_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class CouponRepository implements CouponRepositoryInterface {
  final ApiClient apiClient;
  CouponRepository({required this.apiClient});

  @override
  Future getList(
      {int? offset,
      bool couponList = false,
      bool taxiCouponList = false}) async {
    if (couponList) {
      return await _getCouponList();
    } else if (taxiCouponList) {
      return await _getTaxiCouponList();
    }
  }

  Future<List<CouponModel>?> _getCouponList() async {
    List<CouponModel>? couponList;
    final response = await apiClient.getData(AppConstants.couponUri);
    if (response.statusCode == 200) {
      couponList = [];
      response.data.forEach((category) {
        CouponModel coupon = CouponModel.fromJson(category);
        coupon.toolTip = JustTheController();
        couponList!.add(coupon);
      });
    }
    return couponList;
  }

  Future<List<CouponModel>?> _getTaxiCouponList() async {
    List<CouponModel>? taxiCouponList;
    final response = await apiClient.getData(AppConstants.taxiCouponUri);
    if (response.statusCode == 200) {
      taxiCouponList = [];
      response.data.forEach(
          (category) => taxiCouponList!.add(CouponModel.fromJson(category)));
    }
    return taxiCouponList;
  }

  @override
  Future<CouponModel?> applyCoupon(String couponCode, int? storeID) async {
    CouponModel? couponModel;
    final response = await apiClient
        .getData('${AppConstants.couponApplyUri}$couponCode&store_id=$storeID');
    if (response.statusCode == 200) {
      couponModel = CouponModel.fromJson(response.data);
    }
    return couponModel;
  }

  @override
  Future<CouponModel?> applyTaxiCoupon(
      String couponCode, int? providerId) async {
    CouponModel? taxiCouponModel;
    final response = await apiClient.getData(
        '${AppConstants.taxiCouponApplyUri}$couponCode&provider_id=$providerId');
    if (response.statusCode == 200) {
      taxiCouponModel = CouponModel.fromJson(response.data);
    }
    return taxiCouponModel;
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
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
