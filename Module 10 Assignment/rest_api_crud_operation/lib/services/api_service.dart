import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl =
      'https://crud-api-ostad-live.onrender.com/api/v1';

  // GET - Read all products
  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ReadProduct'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      List<dynamic> data;

      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        data = decoded['data'];
      } else {
        throw Exception('Invalid API response');
      }

      return data
          .map((item) => Product.fromJson(item))
          .toList();
    }

    throw Exception(
      'Failed to load products: ${response.statusCode}',
    );
  }

  // GET - Read product by ID
  Future<Product> getProductById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ReadProductById/$id'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded['data'] is Map) {
        return Product.fromJson(decoded['data']);
      }

      return Product.fromJson(decoded);
    }

    throw Exception(
      'Failed to load product: ${response.statusCode}',
    );
  }

  // POST - Create product
  Future<bool> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/CreateProduct'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(product.toJson()),
    );

    return response.statusCode >= 200 &&
        response.statusCode < 300;
  }

  // POST - Update product
  Future<bool> updateProduct(
      String id,
      Product product,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/UpdateProduct/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(product.toJson()),
    );

    return response.statusCode >= 200 &&
        response.statusCode < 300;
  }

  // GET - Delete product
  Future<bool> deleteProduct(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/DeleteProduct/$id'),
    );

    return response.statusCode >= 200 &&
        response.statusCode < 300;
  }
}