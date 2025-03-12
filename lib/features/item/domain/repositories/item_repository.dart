import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/item/domain/models/basic_medicine_model.dart';
import 'package:sixam_mart/features/item/domain/models/common_condition_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/item/domain/repositories/item_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class ItemRepository implements ItemRepositoryInterface {
  final ApiClient apiClient;
  ItemRepository({required this.apiClient});

  @override
  Future<BasicMedicineModel?> getBasicMedicine() async {
    BasicMedicineModel? basicMedicineModel;
    final response = await apiClient
        .getData('${AppConstants.basicMedicineUri}?offset=1&limit=50');
    if (response.statusCode == 200) {
      basicMedicineModel = BasicMedicineModel.fromJson(response.data);
    }
    return basicMedicineModel;
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
  Future get(String? id, {bool isConditionWiseItem = false}) async {
    if (isConditionWiseItem) {
      return await _getConditionsWiseItems(int.parse(id!));
    } else {
      return await _getItemDetails(int.parse(id!));
    }
  }

  Future<Item?> _getItemDetails(int? itemID) async {
    Item? item;
    final response =
        await apiClient.getData('${AppConstants.itemDetailsUri}$itemID');
    if (response.statusCode == 200) {
      item = Item.fromJson(response.data);
    }
    return item;
  }

  Future<List<Item>?> _getConditionsWiseItems(int id) async {
    List<Item>? conditionWiseProduct;
    final response = await apiClient
        .getData('${AppConstants.conditionWiseItemUri}$id?limit=15&offset=1');
    if (response.statusCode == 200) {
      conditionWiseProduct = [];
      conditionWiseProduct.addAll(ItemModel.fromJson(response.data).items!);
    }
    return conditionWiseProduct;
  }

  @override
  Future getList(
      {int? offset,
      String? type,
      bool isPopularItem = false,
      bool isReviewedItem = false,
      bool isFeaturedCategoryItems = false,
      bool isRecommendedItems = false,
      bool isCommonConditions = false,
      bool isDiscountedItems = false}) async {
    if (isPopularItem) {
      return await _getPopularItemList(type!);
    } else if (isReviewedItem) {
      return await _getReviewedItemList(type!);
    } else if (isFeaturedCategoryItems) {
      return await _getFeaturedCategoriesItemList();
    } else if (isRecommendedItems) {
      return await _getRecommendedItemList(type!);
    } else if (isCommonConditions) {
      return await _getCommonConditions();
    } else if (isDiscountedItems) {
      return await _getDiscountedItemList(type!);
    }
  }

  Future<List<Item>?> _getPopularItemList(String type) async {
    List<Item>? popularItemList;
    final response =
        await apiClient.getData('${AppConstants.popularItemUri}?type=$type');
    if (response.statusCode == 200) {
      popularItemList = [];
      popularItemList.addAll(ItemModel.fromJson(response.data).items!);
    }
    return popularItemList;
  }

  Future<ItemModel?> _getReviewedItemList(String type) async {
    ItemModel? itemModel;
    final response =
        await apiClient.getData('${AppConstants.reviewedItemUri}?type=$type');
    if (response.statusCode == 200) {
      itemModel = ItemModel.fromJson(response.data);
    }
    return itemModel;
  }

  Future<ItemModel?> _getFeaturedCategoriesItemList() async {
    ItemModel? featuredCategoriesItem;
    final response = await apiClient.getData(
        '${AppConstants.featuredCategoriesItemsUri}?limit=30&offset=1');
    if (response.statusCode == 200) {
      featuredCategoriesItem = ItemModel.fromJson(response.data);
    }
    return featuredCategoriesItem;
  }

  Future<List<Item>?> _getRecommendedItemList(String type) async {
    List<Item>? recommendedItemList;
    final response = await apiClient
        .getData('${AppConstants.recommendedItemsUri}$type&limit=30');
    if (response.statusCode == 200) {
      recommendedItemList = [];
      recommendedItemList.addAll(ItemModel.fromJson(response.data).items!);
    }
    return recommendedItemList;
  }

  Future<List<CommonConditionModel>?> _getCommonConditions() async {
    List<CommonConditionModel>? commonConditions;
    final response = await apiClient.getData(AppConstants.commonConditionUri);
    if (response.statusCode == 200) {
      commonConditions = [];
      response.data.forEach((condition) =>
          commonConditions!.add(CommonConditionModel.fromJson(condition)));
    }
    return commonConditions;
  }

  Future<List<Item>?> _getDiscountedItemList(String type) async {
    List<Item>? discountedItemList;
    final response = await apiClient.getData(
        '${AppConstants.discountedItemsUri}?type=$type&offset=1&limit=50');
    if (response.statusCode == 200) {
      discountedItemList = [];
      discountedItemList.addAll(ItemModel.fromJson(response.data).items!);
    }
    return discountedItemList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
