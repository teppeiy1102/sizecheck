// lib/models/product_model.dart

class Product {
  final String productName;
  final String brand;
  final ProductSize size;
  final String description;
  final String productUrl; // 追加

  Product({
    required this.productName,
    required this.brand,
    required this.size,
    required this.description,
    required this.productUrl, // 追加
  });

  // JSONからProductオブジェクトを生成するファクトリコンストラクタ
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productName: json['product_name'] as String,
      brand: json['brand'] as String,
      size: ProductSize.fromJson(json['size'] as Map<String, dynamic>),
      description: json['description'] as String,
      productUrl: json['product_url'] as String? ?? '', // 追加 (nullの場合空文字)
    );
  }
}

class ProductSize {
  final num? width;
  final num? height;
  final num? depth;

  ProductSize({required this.width, required this.height, required this.depth});

  // JSONからProductSizeオブジェクトを生成するファクトリコンストラクタ
  factory ProductSize.fromJson(Map<String, dynamic> json) {
    return ProductSize(
      width: json['width'] as num?,
      height: json['height'] as num?,
      depth: json['depth'] as num?,
    );
  }

  @override
  String toString() {
    final w = width != null ? '横${width}cm' : '';
    final h = height != null ? '高${height}cm' : '';
    final d = depth != null ? '奥${depth}cm' : '';
    final parts = [w, h, d].where((s) => s.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(' x ') : 'サイズ情報なし';
  }
}