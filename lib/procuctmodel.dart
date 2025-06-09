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

  factory BoundingBox.fromJson(dynamic json) { // Changed from Map<String, dynamic> to dynamic
    if (json is Map<String, dynamic>) {
      return BoundingBox(
        x1: json['x1'] as int? ?? 0,
        y1: json['y1'] as int? ?? 0,
        x2: json['x2'] as int? ?? 0,
        y2: json['y2'] as int? ?? 0,
      );
    } else {
      // Handle unexpected format, e.g., return a default or throw a specific error
      // For now, returning a default BoundingBox with all zeros.
      return BoundingBox(x1: 0, y1: 0, x2: 0, y2: 0);
    }
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
  final BoundingBox? boundingBox;
  final String? emoji; // 追加

  Product({
    required this.productName,
    required this.brand,
    required this.size,
    required this.description,
    required this.productUrl,
    this.boundingBox,
    this.emoji, // 追加
  });

  // JSONからProductオブジェクトを生成するファクトリコンストラクタ
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productName: json['product_name'] as String? ?? 'Unknown Product',
      brand: json['brand'] as String? ?? 'Unknown Brand',
      size: ProductSize.fromJson(json['size']), // Removed 'as Map<String, dynamic>'
      description: json['description'] as String? ?? '',
      productUrl: json['product_url'] as String? ?? '',
      boundingBox: json['bounding_box'] != null
          ? BoundingBox.fromJson(json['bounding_box']) // Removed 'as Map<String, dynamic>'
          : null,
      emoji: json['emoji'] as String?,
    );
  }
}

class ProductSize {
  final num? width;
  final num? height;
  final num? depth;
  final double? volume; // 容量 (L単位など)
  final String? apparelSize; // S/M/L/Freeなど

  ProductSize({
    this.width,
    this.height,
    this.depth,
    this.volume,
    this.apparelSize,
  });

  // JSONからProductSizeオブジェクトを生成するファクトリコンストラクタ
  factory ProductSize.fromJson(Map<String, dynamic> json) {
    return ProductSize(
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      depth: (json['depth'] as num?)?.toDouble() ?? 0.0,
      volume: (json['volume'] as num?)?.toDouble(), // volumeを追加
      apparelSize: json['apparel_size'] as String?, // apparel_sizeを追加
    );
  }

  @override
  String toString() {
    final w = width != null ? '横${width}cm' : '';
    final h = height != null ? '高${height}cm' : '';
    final d = depth != null ? '奥${depth}cm' : '';
    final v = volume != null ? '容量${volume}L' : ''; // 追加
    final a = apparelSize != null ? 'サイズ:${apparelSize}' : ''; // 追加
    final parts = [w, h, d, v, a].where((s) => s.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(' | ') : 'サイズ情報なし';
  }
}