import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sixam_mart/api/api_checker.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/common/models/error_response.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get.dart' hide Response, MultipartFile, FormData;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'connection_to_api_server_failed'.tr;
  final int timeoutInSeconds = 40;
  final Dio dio = Dio();

  String? token;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token);
    if (kDebugMode) {
      print('Token: $token');
    }
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(
          jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
    } catch (_) {}
    int? moduleID;
    if (GetPlatform.isWeb &&
        sharedPreferences.containsKey(AppConstants.moduleId)) {
      try {
        moduleID = ModuleModel.fromJson(
                jsonDecode(sharedPreferences.getString(AppConstants.moduleId)!))
            .id;
      } catch (_) {}
    }
    updateHeader(
        token,
        addressModel?.zoneIds,
        addressModel?.areaIds,
        sharedPreferences.getString(AppConstants.languageCode),
        moduleID,
        addressModel?.latitude,
        addressModel?.longitude);
  }

  Map<String, String> updateHeader(
      String? token,
      List<int>? zoneIDs,
      List<int>? operationIds,
      String? languageCode,
      int? moduleID,
      String? latitude,
      String? longitude,
      {bool setHeader = true}) {
    Map<String, String> header = {};

    if (moduleID != null ||
        sharedPreferences.getString(AppConstants.cacheModuleId) != null) {
      header.addAll({
        AppConstants.moduleId:
            '${moduleID ?? ModuleModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.cacheModuleId)!)).id}'
      });
    }
    header.addAll({
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.zoneId: zoneIDs != null ? jsonEncode(zoneIDs) : '',

      ///this will add in ride module
      // AppConstants.operationAreaId: operationIds != null ? jsonEncode(operationIds) : '',
      AppConstants.localizationKey:
          languageCode ?? AppConstants.languages[0].languageCode!,
      AppConstants.latitude: latitude != null ? jsonEncode(latitude) : '',
      AppConstants.longitude: longitude != null ? jsonEncode(longitude) : '',
      'Authorization': 'Bearer $token'
    });
    if (setHeader) {
      _mainHeaders = header;
    }
    return header;
  }

  Future<Response> getData(String uri,
      {Map<String, dynamic>? query,
      Map<String, String>? headers,
      bool handleError = true}) async {
    try {
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
      }
      final response = await dio.get(appBaseUrl + uri,
          options: Options(headers: headers ?? _mainHeaders));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      if (kDebugMode) {
        print('------------${e.toString()}');
      }
      return Response(
          requestOptions: RequestOptions(path: uri),
          statusCode: 1,
          statusMessage: noInternetMessage);
    }
  }

  Future<Response> postData(String uri, dynamic body,
      {Map<String, String>? headers,
      int? timeout,
      bool handleError = true}) async {
    try {
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
        print('====> API Body: $body');
      }
      final response = await dio
          .post(
            appBaseUrl + uri,
            data: body,
            options: Options(headers: headers ?? _mainHeaders),
          )
          .timeout(Duration(seconds: timeout ?? timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(
          requestOptions: RequestOptions(path: uri),
          statusCode: 1,
          statusMessage: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(
      String uri, Map<String, String> body, List<MultipartBody> multipartBody,
      {Map<String, String>? headers, bool handleError = true}) async {
    try {
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
        print('====> API Body: $body with ${multipartBody.length} picture');
      }
      final formData = FormData.fromMap(body);

      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null) {
          Uint8List list = await multipart.file!.readAsBytes();
          formData.files.add(MapEntry(
              multipart.key,
              MultipartFile.fromBytes(
                list,
                filename: multipart.file!.name,
              )));
        }
      }
      final response = await dio.post(appBaseUrl + uri,
          data: formData, options: Options(headers: headers ?? _mainHeaders));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(
          requestOptions: RequestOptions(path: uri),
          statusCode: 1,
          statusMessage: noInternetMessage);
    }
  }

  Future<Response> putData(String uri, dynamic body,
      {Map<String, String>? headers, bool handleError = true}) async {
    try {
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
        print('====> API Body: $body');
      }
      final response = await dio
          .put(
            appBaseUrl + uri,
            data: body,
            options: Options(headers: headers ?? _mainHeaders),
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(
          requestOptions: RequestOptions(path: uri),
          statusCode: 1,
          statusMessage: noInternetMessage);
    }
  }

  Future<Response> deleteData(String uri,
      {Map<String, String>? headers, bool handleError = true}) async {
    try {
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
      }
      final response = await dio
          .delete(
            appBaseUrl + uri,
            options: Options(headers: headers ?? _mainHeaders),
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(
          requestOptions: RequestOptions(path: uri),
          statusCode: 1,
          statusMessage: noInternetMessage);
    }
  }

  Response handleResponse(final response, String uri, bool handleError) {
    final dynamic body = response.data;
    Response response0 = Response(
      requestOptions: RequestOptions(
          headers: response.requestOptions.headers,
          method: response.requestOptions.method,
          path: response.requestOptions.path),
      data: body ?? response.data,
      headers: response.headers,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
    );
    if (response0.statusCode != 200 &&
        response0.data != null &&
        response0.data is! String) {
      if (response0.data.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response0.data);
        response0 = Response(
            requestOptions: response0.requestOptions,
            statusCode: response0.statusCode,
            data: response0.data,
            statusMessage: errorResponse.errors![0].message);
      } else if (response0.data.toString().startsWith('{message')) {
        response0 = Response(
            requestOptions: response0.requestOptions,
            statusCode: response0.statusCode,
            data: response0.data,
            statusMessage: response0.data['message']);
      }
    } else if (response0.statusCode != 200 && response0.data == null) {
      response0 = Response(
          requestOptions: response0.requestOptions,
          statusCode: 0,
          statusMessage: noInternetMessage);
    }
    if (kDebugMode) {
      print('====> API Response: [${response0.statusCode}] $uri');
      if (!ResponsiveHelper.isWeb() || response.statusCode != 500) {
        print('${response0.data}');
      }
    }
    if (handleError) {
      if (response0.statusCode == 200) {
        return response0;
      } else {
        ApiChecker.checkApi(response0);
        return Response(requestOptions: RequestOptions());
      }
    } else {
      return response0;
    }
  }
}

class MultipartBody {
  String key;
  XFile? file;

  MultipartBody(this.key, this.file);
}
