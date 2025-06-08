// lib/models/product_model.dart

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

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x1: json['x1'] as int? ?? 0,
      y1: json['y1'] as int? ?? 0,
      x2: json['x2'] as int? ?? 0,
      y2: json['y2'] as int? ?? 0,
    );
  }

  // 必要に応じて width, height を計算するゲッター
  int get width => (x2 - x1).abs();
  int get height => (y2 - y1).abs();
}

class Product {
  final String productName;
  final String brand;
  final ProductSize size;
  final String description;
  final String productUrl;
  final BoundingBox? boundingBox; // 追加

  Product({
    required this.productName,
    required this.brand,
    required this.size,
    required this.description,
    required this.productUrl,
    this.boundingBox, // 追加
  });

  // JSONからProductオブジェクトを生成するファクトリコンストラクタ
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productName: json['product_name'] as String,
      brand: json['brand'] as String,
      size: ProductSize.fromJson(json['size'] as Map<String, dynamic>),
      description: json['description'] as String,
      productUrl: json['product_url'] as String? ?? '',
      boundingBox: json['bounding_box'] != null
          ? BoundingBox.fromJson(json['bounding_box'] as Map<String, dynamic>)
          : null, // 追加
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