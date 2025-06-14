// lib/models/product_model.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String _savedProductsKey = 'saved_products';

  Future<SharedPreferences> _getPrefs() async {
    return SharedPreferences.getInstance();
  }

  Future<List<Product>> getSavedProducts() async {
    final prefs = await _getPrefs();
    final String? productsJson = prefs.getString(_savedProductsKey);
    if (productsJson != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(productsJson) as List;
        return decodedList
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // JSONデコードエラーの場合は空リストを返すか、エラーをログに出力
        print('Error decoding saved products: $e');
        return [];
      }
    }
    return [];
  }

  Future<void> saveProduct(Product product) async {
    if (product.productUrl.isEmpty) return; // URLがない場合は保存しない

    final prefs = await _getPrefs();
    List<Product> products = await getSavedProducts();
    
    // 既に保存されているか確認 (productUrlで判定)
    final index = products.indexWhere((p) => p.productUrl == product.productUrl);
    if (index != -1) {
      // 既に存在する場合は更新 (保存日時を更新)
      product.savedAt = DateTime.now();
      products[index] = product;
    } else {
      // 新規追加
      product.savedAt = DateTime.now();
      products.add(product);
    }
    
    final String encodedData = jsonEncode(products.map((p) => p.toJson()).toList());
    await prefs.setString(_savedProductsKey, encodedData);
  }

  Future<void> removeProduct(String productUrl) async {
    if (productUrl.isEmpty) return;

    final prefs = await _getPrefs();
    List<Product> products = await getSavedProducts();
    products.removeWhere((p) => p.productUrl == productUrl);
    final String encodedData = jsonEncode(products.map((p) => p.toJson()).toList());
    await prefs.setString(_savedProductsKey, encodedData);
  }

  Future<bool> isProductSaved(String productUrl) async {
    if (productUrl.isEmpty) return false;
    List<Product> products = await getSavedProducts();
    return products.any((p) => p.productUrl == productUrl);
  }

  Future<Set<String>> getSavedProductUrls() async {
    final products = await getSavedProducts();
    return products.map((p) => p.productUrl).where((url) => url.isNotEmpty).toSet();
  }
}


class BoundingBox {
  final int x1;
  final int y1;
  final int x2;
  final int y2;

  BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  factory BoundingBox.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return BoundingBox(
        x1: json['x1'] as int? ?? 0,
        y1: json['y1'] as int? ?? 0,
        x2: json['x2'] as int? ?? 0,
        y2: json['y2'] as int? ?? 0,
      );
    } else {
      return BoundingBox(x1: 0, y1: 0, x2: 0, y2: 0);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'x1': x1,
      'y1': y1,
      'x2': x2,
      'y2': y2,
    };
  }

  int get width => (x2 - x1).abs();
  int get height => (y2 - y1).abs();
}

class Product {
  final String productName;
  final String brand;
  final ProductSize size;
  final String description;
  final String productUrl; // これをIDとして使用します
  final BoundingBox? boundingBox;
  final String? emoji;
  DateTime? savedAt; // ★★★ 追加: 保存日時 ★★★

  Product({
    required this.productName,
    required this.brand,
    required this.size,
    required this.description,
    required this.productUrl,
    this.boundingBox,
    this.emoji,
    this.savedAt, // ★★★ 追加 ★★★
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productName: json['product_name'] as String? ?? 'Unknown Product',
      brand: json['brand'] as String? ?? 'Unknown Brand',
      size: ProductSize.fromJson(json['size'] as Map<String, dynamic>), // 型キャストを明示
      description: json['description'] as String? ?? '',
      productUrl: json['product_url'] as String? ?? '',
      boundingBox: json['bounding_box'] != null
          ? BoundingBox.fromJson(json['bounding_box'])
          : null,
      emoji: json['emoji'] as String?,
      savedAt: json['saved_at'] != null // ★★★ 追加 ★★★
          ? DateTime.tryParse(json['saved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() { // ★★★ 追加 ★★★
    return {
      'product_name': productName,
      'brand': brand,
      'size': size.toJson(),
      'description': description,
      'product_url': productUrl,
      'bounding_box': boundingBox?.toJson(),
      'emoji': emoji,
      'saved_at': savedAt?.toIso8601String(),
    };
  }
}

class ProductSize {
  final num? width;
  final num? height;
  final num? depth;
  final double? volume;
  final String? apparelSize;

  ProductSize({
    this.width,
    this.height,
    this.depth,
    this.volume,
    this.apparelSize,
  });

  factory ProductSize.fromJson(Map<String, dynamic> json) {
    return ProductSize(
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      depth: (json['depth'] as num?)?.toDouble() ?? 0.0,
      volume: (json['volume'] as num?)?.toDouble(),
      apparelSize: json['apparel_size'] as String?,
    );
  }

  Map<String, dynamic> toJson() { // ★★★ 追加 ★★★
    return {
      'width': width,
      'height': height,
      'depth': depth,
      'volume': volume,
      'apparel_size': apparelSize,
    };
  }

  @override
  String toString() {
    final w = width != null && width! > 0 ? '横${width!.toStringAsFixed(1)}cm' : '';
    final h = height != null && height! > 0 ? '高${height!.toStringAsFixed(1)}cm' : '';
    final d = depth != null && depth! > 0 ? '奥${depth!.toStringAsFixed(1)}cm' : '';
    final v = volume != null && volume! > 0 ? '容量${volume!.toStringAsFixed(1)}L' : '';
    final a = apparelSize != null && apparelSize!.isNotEmpty ? 'サイズ:${apparelSize}' : '';
    final parts = [w, h, d, v, a].where((s) => s.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(' | ') : 'サイズ情報なし';
  }
}