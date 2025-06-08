import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'procuctmodel.dart'; // Productモデルをインポート
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMobパッケージをインポート
import 'dart:io'; // Platform を使用するためにインポート
import 'dart:typed_data'; // Uint8Listのため
import 'dart:ui' as ui; // ui.Image, ui.Canvasのため


class ResultsScreen extends StatefulWidget {
  final List<Product> products;
  final String? errorMessage;
  final Map<String, bool> selectedBrands;
  final Map<String, String> brandTopPageUrls;
  final Future<List<Product>> Function(Product, List<String>) fetchSimilarProductsApiCallback;
  final File? originalImageFile; // ★★★ 追加: 元の画像ファイルを受け取る ★★★


  const ResultsScreen({
    super.key,
    required this.products,
    this.errorMessage,
    required this.selectedBrands,
    required this.brandTopPageUrls,
    required this.fetchSimilarProductsApiCallback,
    this.originalImageFile, // ★★★ 追加 ★★★
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  // ダークテーマ用のベースカラー (HomeScreenから移動または共通化)
  final Color darkPrimaryColor = const Color.fromARGB(255, 193, 115, 196)!; // メインの操作ボタンなど
  final Color darkAccentColor = Colors.tealAccent[400]!; // 強調したい部分や一部のボタン
  final Color darkBackgroundColor = Colors.grey[900]!;
  final Color darkCardColor = Colors.grey[850]!.withOpacity(0.85);
  final Color darkChipColor = Colors.grey[700]!;
  final Color darkBottomSheetBackgroundColorStart = Colors.grey[850]!;
  final Color darkBottomSheetBackgroundColorEnd = Colors.grey[900]!;

  late Map<String, bool> _selectedBrandsForSimilarSearch;

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  // テスト用の広告ユニットID (実際のIDに置き換えてください)
  final String _bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111' // AndroidのテストID
      : 'ca-app-pub-3940256099942544/2934735716'; // iOSのテストID


  @override
  void initState() {
    super.initState();
    // 初期状態でHomeScreenでの選択状態をコピー
    _selectedBrandsForSimilarSearch = Map<String, bool>.from(widget.selectedBrands);
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.largeBanner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('$BannerAd loaded.');
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => debugPrint('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => debugPrint('$BannerAd onAdClosed.'),
        onAdImpression: (Ad ad) => debugPrint('$BannerAd onAdImpression.'),
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        title: Text(widget.errorMessage != null ? 'エラー' : '解析結果', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[850],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column( // bodyをColumnでラップ
        children: [
          Expanded( // メインコンテンツをExpandedでラップ
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [darkBackgroundColor, Colors.grey[850]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildContent(),
              ),
            ),
          ),
          // バナー広告のコンテナ
          if (_bannerAd != null && _isBannerAdLoaded)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.errorMessage!,
            style: TextStyle(color: Colors.redAccent[100], fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (widget.products.isEmpty) {
      return Center(
        child: Text(
          '対象商品が見つかりませんでした。',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _buildResultsList(),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '類似商品を検索するメーカーを選択:',
            style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        _buildBrandSelectionForSimilarSearch(),
        const SizedBox(height: 8), // 必要に応じて下部のパディング調整
      ],
    );
  }

  Widget _buildBrandSelectionForSimilarSearch() {
    // HomeScreenのスタイルを参考に調整
    final Color chipBackgroundColor = Colors.grey[800]!;
    final Color chipSelectedColor = darkAccentColor.withOpacity(0.3); // darkAccentColorを使用
    final Color chipLabelColor = Colors.grey[300]!;
    final Color chipSelectedLabelColor = Colors.black;
    final Color chipBorderColor = Colors.grey[700]!;
    final Color chipSelectedBorderColor = darkAccentColor;

    // widget.selectedBrands.keys だと HomeScreen で定義された全ブランドリストになる
    // ここでは _selectedBrandsForSimilarSearch のキー（つまり HomeScreen で選択可能なブランド）を使う
    final availableBrandsForSimilar = _selectedBrandsForSimilarSearch.keys.toList();


    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.center,
      children: availableBrandsForSimilar.map((brand) {
        return FilterChip(
          label: Text(
            brand,
            style: TextStyle(color: _selectedBrandsForSimilarSearch[brand]! ? chipSelectedLabelColor : chipLabelColor),
          ),
          selected: _selectedBrandsForSimilarSearch[brand] ?? false,
          onSelected: (bool selected) {
            setState(() {
              _selectedBrandsForSimilarSearch[brand] = selected;
            });
          },
          backgroundColor: chipBackgroundColor,
          selectedColor: chipSelectedColor,
          checkmarkColor: chipSelectedLabelColor, // 選択時のチェックマークの色
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _selectedBrandsForSimilarSearch[brand]! ? chipSelectedBorderColor : chipBorderColor),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        final product = widget.products[index];
        return Card(
          color: darkCardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.originalImageFile != null && product.boundingBox != null)
                  FutureBuilder<ui.Image>(
                    future: _loadUiImage(widget.originalImageFile!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                        final ui.Image originalUiImage = snapshot.data!;
                        final BoundingBox bb = product.boundingBox!;
                        // バウンディングボックスの座標が画像の範囲内であることを確認
                        if (bb.x1 < originalUiImage.width && bb.y1 < originalUiImage.height &&
                            bb.x2 <= originalUiImage.width && bb.y2 <= originalUiImage.height &&
                            bb.x1 < bb.x2 && bb.y1 < bb.y2) {
                          return SizedBox(
                            width: bb.width.toDouble(), // 切り抜き後の表示幅
                            height: bb.height.toDouble(), // 切り抜き後の表示高さ
                            child: ClipRect( // ここでは単純なClipRectを使用。より高度な表示にはCustomPaintを推奨
                              child: CustomPaint(
                                painter: CroppedImagePainter(
                                  image: originalUiImage,
                                  cropRect: Rect.fromLTRB(
                                    bb.x1.toDouble(),
                                    bb.y1.toDouble(),
                                    bb.x2.toDouble(),
                                    bb.y2.toDouble(),
                                  ),
                                ),
                                child: Container(
                                  width: bb.width.toDouble(),
                                  height: bb.height.toDouble(),
                                ),
                              ),
                            ),
                          );
                        } else {
                           // バウンディングボックスが無効な場合はプレースホルダーなどを表示
                           return const SizedBox(height: 8, child: Text("座標エラー", style: TextStyle(color: Colors.redAccent)));
                        }
                      } else if (snapshot.hasError) {
                        return const SizedBox(height: 8, child: Text("画像読込エラー", style: TextStyle(color: Colors.redAccent)));
                      }
                      return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator())); // 画像読み込み中
                    },
                  ),
                if (widget.originalImageFile != null && product.boundingBox != null)
                  const SizedBox(height: 12),
                Text(product.productName, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Chip(
                  label: Text(product.brand, style: TextStyle(color: Colors.white.withOpacity(0.9))),
                  backgroundColor: darkChipColor.withOpacity(0.7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.straighten, size: 18, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Text(product.size.toString(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final searchQuery = '${product.brand} ${product.productName}';
                    final Uri url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(searchQuery)}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('URLを開けませんでした: ${url.toString()}'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 18, color: darkAccentColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '「${product.brand} ${product.productName}」をGoogleで検索',
                            style: TextStyle(
                              color: darkAccentColor,
                              decoration: TextDecoration.underline,
                              decorationColor: darkAccentColor.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.search_sharp),
                    label: const Text('類似商品を検索'),
                    onPressed: () {
                      _showSimilarProductsBottomSheet(context, product);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent[400],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSimilarProductsBottomSheet(BuildContext context, Product originalProduct) {
    bool isLoadingSimilar = true;
    List<Product> similarProducts = [];
    String? errorSimilarMessage;
    bool initialLoadStarted = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            Future<void> loadSimilarProducts() async {
              // isLoadingSimilar のチェックは呼び出し側で行うか、ここで再度確認
              // if (!isLoadingSimilar) return; // このチェックは initialLoadStarted で代替されている部分もある

              try {
                // ResultsScreenの状態で選択されたブランドを使用
                final activeBrands = _selectedBrandsForSimilarSearch.entries
                    .where((entry) => entry.value)
                    .map((entry) => entry.key)
                    .toList();
                if (activeBrands.isEmpty) {
                  setSheetState(() {
                    errorSimilarMessage = '検索対象のメーカーを1つ以上選択してください。';
                    isLoadingSimilar = false;
                  });
                  return;
                }
                // HomeScreenから渡されたコールバックを使用
                final products = await widget.fetchSimilarProductsApiCallback(originalProduct, activeBrands);
                setSheetState(() {
                  similarProducts = products; // 表示件数の制限を解除
                  isLoadingSimilar = false;
                });
              } catch (e) {
                setSheetState(() {
                  errorSimilarMessage = '類似商品の検索中にエラー: ${e.toString()}';
                  isLoadingSimilar = false;
                });
              }
            }

            if (isLoadingSimilar && similarProducts.isEmpty && errorSimilarMessage == null && !initialLoadStarted) {
              initialLoadStarted = true;
              loadSimilarProducts();
            }

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              builder: (_, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [darkBottomSheetBackgroundColorStart, darkBottomSheetBackgroundColorEnd],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Text(
                        '「${originalProduct.productName}」の類似商品',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      if (isLoadingSimilar)
                        Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(darkAccentColor))),
                      if (errorSimilarMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            errorSimilarMessage!,
                            style: TextStyle(color: Colors.redAccent[100], fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (!isLoadingSimilar && similarProducts.isEmpty && errorSimilarMessage == null)
                        Center(child: Text('類似商品が見つかりませんでした。', style: TextStyle(color: Colors.grey[400]))),
                      if (!isLoadingSimilar && similarProducts.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: similarProducts.length,
                            itemBuilder: (ctx, index) {
                              final product = similarProducts[index];
                              return Card(
                                color: Colors.grey[800]!.withOpacity(0.8),
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.productName, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                                      const SizedBox(height: 4),
                                      Chip(
                                        label: Text(product.brand, style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                        backgroundColor: Colors.grey[700]!.withOpacity(0.7),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.straighten, size: 16, color: Colors.grey.shade400),
                                          const SizedBox(width: 8),
                                          Text(product.size.toString(), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[300])),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        product.description,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      InkWell(
                                        onTap: () async {
                                          final searchQuery = '${product.brand} ${product.productName}';
                                          final Uri url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(searchQuery)}');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url);
                                          } else {
                                            if (sheetContext.mounted) { // Use sheetContext here
                                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                                SnackBar(content: Text('URLを開けませんでした: ${url.toString()}')),
                                              );
                                            }
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.search, size: 18, color: darkAccentColor),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '「${product.brand} ${product.productName}」をGoogleで検索',
                                                  style: TextStyle(
                                                    color: darkAccentColor,
                                                    decoration: TextDecoration.underline,
                                                    decorationColor: darkAccentColor.withOpacity(0.7),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<ui.Image> _loadUiImage(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}

// CustomPaintで画像の一部を描画するためのPainter
class CroppedImagePainter extends CustomPainter {
  final ui.Image image;
  final Rect cropRect;

  CroppedImagePainter({required this.image, required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    // canvas.drawImageRect(image, cropRect, Rect.fromLTWH(0, 0, size.width, size.height), paint);
    // 描画先のRectは、CustomPaintウィジェットのサイズに合わせる
    // また、cropRectのサイズと描画先のサイズのアスペクト比が異なる場合、画像が歪む可能性がある
    // ここでは、cropRectのサイズをそのまま描画先のサイズとして使うことを想定
    // 必要に応じて、size (CustomPaintのサイズ) と cropRect.size を比較して調整する
    
    // 元画像のcropRect部分を、Canvasの(0,0)からcropRectの幅・高さで描画
    canvas.drawImageRect(
        image,
        cropRect,
        Rect.fromLTWH(0, 0, cropRect.width, cropRect.height), // 描画先の矩形
        paint
    );
  }

  @override
  bool shouldRepaint(covariant CroppedImagePainter oldDelegate) {
    return image != oldDelegate.image || cropRect != oldDelegate.cropRect;
  }
}