import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiService {
  late final Dio _dio;
  final Connectivity _connectivity = Connectivity();
  
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-Key': AppConstants.apiKey,
        },
      ),
    );
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check connectivity
          final connectivityResult = await _connectivity.checkConnectivity();
          if (connectivityResult == ConnectivityResult.none) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'No internet connection',
                type: DioExceptionType.connectionError,
              ),
            );
          }
          
          // Add auth token if available
          final token = await _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Handle unauthorized - refresh token or logout
            await _handleUnauthorized();
          }
          return handler.next(error);
        },
      ),
    );
  }
  
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.keyUserToken);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> _handleUnauthorized() async {
    try {
      // Clear stored token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyUserToken);
      await prefs.remove(AppConstants.keyUserId);
      // Navigate to login screen would be handled by the app state
    } catch (e) {
      // Handle error silently
    }
  }
  
  // Generic GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic POST request
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic PUT request
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic DELETE request
  Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } catch (e) {
      rethrow;
    }
  }
  
  // Upload image
  Future<Response> uploadImage(String endpoint, String filePath) async {
    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });
      return await _dio.post(endpoint, data: formData);
    } catch (e) {
      rethrow;
    }
  }
  
  // Disease diagnosis
  Future<Map<String, dynamic>> diagnoseCrop(String imagePath) async {
    try {
      final response = await uploadImage('/diagnosis/analyze', imagePath);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get weather data
  Future<Map<String, dynamic>> getWeather(double latitude, double longitude) async {
    try {
      final response = await get('/weather', queryParameters: {
        'lat': latitude,
        'lon': longitude,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get market prices
  Future<List<dynamic>> getMarketPrices(String? cropType) async {
    try {
      final response = await get('/market/prices', queryParameters: {
        if (cropType != null) 'crop': cropType,
      });
      return response.data as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }
  
  // Send chat message
  Future<Map<String, dynamic>> sendMessage(String message, {String? imageUrl}) async {
    try {
      final response = await post('/chat/message', data: {
        'message': message,
        if (imageUrl != null) 'image_url': imageUrl,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
