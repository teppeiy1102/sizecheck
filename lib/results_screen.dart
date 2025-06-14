import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'procuctmodel.dart'; // Productモデルをインポート
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMobパッケージをインポート
import 'dart:io'; // Platform を使用するためにインポート
import 'dart:typed_data'; // Uint8Listのため
import 'dart:ui' as ui; // ui.Image, ui.Canvasのため
import 'package:webview_flutter/webview_flutter.dart'; // ★★★ WebViewパッケージをインポート ★★★
import 'package:flutter/gestures.dart'; // ★★★ gestureRecognizers のために追加 ★★★
import 'brand_data.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ★★★ 追加 ★★★
import 'dart:convert'; // ★★★ 追加 ★★★
import 'saved_products_screen.dart'; // ★★★ 追加: 後で作成するファイル ★★★
import 'dart:ui'; // ImageFilter.blur を使用するために必要

class ResultsScreen extends StatefulWidget {
  final List<Product> products;
  final String? errorMessage;
  final Map<String, bool> selectedBrands;
  final Map<String, String> brandTopPageUrls;
  final Future<List<Product>> Function(Product, List<String>) fetchSimilarProductsApiCallback;
  final File? originalImageFile; // ★★★ 変更前にも存在 ★★★
  final SearchGenre selectedGenre; // ★★★ 追加 ★★★


  const ResultsScreen({
    super.key,
    required this.products,
    this.errorMessage,
    required this.selectedBrands,
    required this.brandTopPageUrls,
    required this.fetchSimilarProductsApiCallback,
    this.originalImageFile, // ★★★ 変更前にも存在 ★★★
    required this.selectedGenre, // ★★★ 追加 ★★
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
? 'ca-app-pub-7148683667182672/9797170752' // AndroidのテストID
      : 'ca-app-pub-7148683667182672/3020009417'; // iOSのテストID


  final PreferenceService _preferenceService = PreferenceService(); // ★★★ 追加 ★★★
  Set<String> _savedProductUrls = {}; // ★★★ 追加 ★★★

  @override
  void initState() {
    super.initState();
    // 初期状態でHomeScreenでの選択状態をコピー
    _selectedBrandsForSimilarSearch = Map<String, bool>.from(widget.selectedBrands);
    _loadBannerAd();
    _loadSavedProductUrls(); // ★★★ 追加 ★★★
  }

  Future<void> _loadSavedProductUrls() async { // ★★★ 追加 ★★★
    _savedProductUrls = await _preferenceService.getSavedProductUrls();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleSaveProduct(Product product) async { // ★★★ 追加 ★★★
    if (product.productUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('商品URLがないため保存できません。'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    final isCurrentlySaved = _savedProductUrls.contains(product.productUrl);
    if (isCurrentlySaved) {
      await _preferenceService.removeProduct(product.productUrl);
      _savedProductUrls.remove(product.productUrl);
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「${product.productName}」を保存済みから削除しました。'), backgroundColor: Colors.grey[700]),
        );
      }
    } else {
      await _preferenceService.saveProduct(product);
      _savedProductUrls.add(product.productUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「${product.productName}」を保存しました。'), backgroundColor: darkAccentColor),
        );
      }
    }
    if (mounted) {
      setState(() {});
    }
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
        title: Text(widget.errorMessage != null ? 'エラー' : '特定結果', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [ // ★★★ AppBarにアクションを追加 ★★★
          IconButton(
            icon: const Icon(Icons.library_books), // 保存済みリストのアイコン
            tooltip: '保存した商品を見る',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavedProductsScreen()),
              ).then((_) => _loadSavedProductUrls()); // 戻ってきたときにリストを再読み込み
            },
          ),
        ],
      ),
      body: Column( // bodyをColumnでラップ
        children: [
          Expanded( // メインコンテンツをExpandedでラップ
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.transparent,],
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
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'ニタモノ商品を検索するメーカーを選択:',
            style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(
            maxHeight: 250, // メーカー選択部分の最大高さを設定 (この値は調整可能です)
          ),
          child: SingleChildScrollView( // 内容が最大高さを超える場合にスクロール可能にする
            child: _buildBrandSelectionForSimilarSearch(),
          ),
        ),
        //const SizedBox(height: 8), // 必要に応じて下部のパディング調整
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
      spacing: 5.0,
      runSpacing: 5.0,
      alignment: WrapAlignment.center,
      children: availableBrandsForSimilar.map((brand) {
        return FilterChip(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 12), // パディングを調整
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
        final bool isSaved = _savedProductUrls.contains(product.productUrl); // ★★★ 追加 ★★★
        return Card(
          color: Colors.white12,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.originalImageFile != null && product.boundingBox != null)
                //  FutureBuilder<ui.Image>(
                //    future: _loadUiImage(widget.originalImageFile!),
                //    builder: (context, snapshot) {
                //      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                //        final ui.Image originalUiImage = snapshot.data!;
                //        final BoundingBox bb = product.boundingBox!;
                //        // バウンディングボックスの座標が画像の範囲内であることを確認
                //        if (bb.x1 < originalUiImage.width && bb.y1 < originalUiImage.height &&
                //            bb.x2 <= originalUiImage.width && bb.y2 <= originalUiImage.height &&
                //            bb.x1 < bb.x2 && bb.y1 < bb.y2) {
                //          return SizedBox(
                //            width: bb.width.toDouble(), // 切り抜き後の表示幅
                //            height: bb.height.toDouble(), // 切り抜き後の表示高さ
                //            child: ClipRect( // ここでは単純なClipRectを使用。より高度な表示にはCustomPaintを推奨
                //              child: CustomPaint(
                //                painter: CroppedImagePainter(
                //                  image: originalUiImage,
                //                  cropRect: Rect.fromLTRB(
                //                    bb.x1.toDouble(),
                //                    bb.y1.toDouble(),
                //                    bb.x2.toDouble(),
                //                    bb.y2.toDouble(),
                //                  ),
                //                ),
                //                child: Container(
                //                  width: bb.width.toDouble(),
                //                  height: bb.height.toDouble(),
                //                ),
                //              ),
                //            ),
                //          );
                //        } else {
                //           // バウンディングボックスが無効な場合はプレースホルダーなどを表示
                //           return const SizedBox(height: 8, child: Text("座標エラー", style: TextStyle(color: Colors.redAccent)));
                //        }
                //      } else if (snapshot.hasError) {
                //        return const SizedBox(height: 8, child: Text("画像読込エラー", style: TextStyle(color: Colors.redAccent)));
                //      }
                //      return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator())); // 画像読み込み中
                //    },
                //  ),
                if (widget.originalImageFile != null && product.boundingBox != null)
                  const SizedBox(height: 2),
                  Row(children: [
Expanded(
  child: Text(
  
                    '${product.productName}', // 絵文字を表示
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)
                  ),
),
                SizedBox(width: 30,),
                Text(
                  '${product.emoji ?? ''}', // 絵文字を表示
                  style:TextStyle(
                    fontSize: 40,
                    color: Colors.white.withOpacity(0.9),) 
                ),
 

                  ],),
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
                    Text(_formatSize(product.size), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[300])),
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
                            '「${product.productName}」をGoogleで検索',
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
                    label: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: const Text('ニタモノ商品を検索'),
                    ),
                    onPressed: () {
                      _showSimilarProductsBottomSheet(context, product);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  // ★★★ 類似商品アイテムを1つ表示するためのヘルパーウィジェット ★★★
  Widget _buildSingleSimilarProductItem(BuildContext context, Product product, BuildContext sheetContext, StateSetter setSheetState) { // ★★★ setSheetState を引数に追加 ★★★
    final bool isSaved = _savedProductUrls.contains(product.productUrl); // ★★★ 追加 ★★★
    return Card(
      color: Colors.white12,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row( // ★★★ Rowで囲む ★★★
              children: [
                Expanded(
                  child: Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    '${product.emoji ?? ''} ${product.productName}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)
                  ),
                ),
                if (product.productUrl.isNotEmpty) // ★★★ URLがある場合のみ保存ボタン表示 ★★★
                  IconButton( // ★★★ 保存ボタン ★★★
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? darkAccentColor : Colors.grey[300],
                      size: 24, // 少し小さく
                    ),
                    tooltip: isSaved ? '保存済み (タップして解除)' : '保存する',
                    onPressed: () async {
                      await _toggleSaveProduct(product);
                      // ボトムシート内の状態も更新するために setSheetState を呼ぶ
                      // また、メイン画面の _savedProductUrls も更新されているので、
                      // ボトムシートを閉じて再度開いたときにも正しい状態が反映される
                      if (sheetContext.mounted) {
                        setSheetState(() {}); // ボトムシート内のUIを更新
                      }
                    },
                  ),
              ],
            ),
            Chip(
              label: Text(product.brand, style: TextStyle(color: Colors.white.withOpacity(0.9))),
              backgroundColor: Colors.grey[700]!.withOpacity(0.7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            Row(
              children: [
                Icon(Icons.straighten, size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Text(_formatSize(product.size), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[300])),
              ],
            ),
            Text(
              product.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Google検索ボタン (WebViewがあるので、これは削除または変更しても良いかもしれません)
            InkWell(
              onTap: () async {
                final searchQuery = '${product.brand} ${product.productName}';
                final Uri url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(searchQuery)}');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  if (sheetContext.mounted) {
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
                    Icon(Icons.open_in_new, size: 18, color: darkAccentColor), // アイコン変更
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '「${product.brand} ${product.productName}」をブラウザで検索', // テキスト変更
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
      ));
  }

  void _showSimilarProductsBottomSheet(BuildContext context, Product originalProduct) {
    bool isLoadingSimilar = true;
    List<Product> similarProducts = [];
    String? errorSimilarMessage;
    // bool initialLoadStarted = false; // StatefulBuilder内で初期化されると再ビルド時にリセットされるため外に移動
    WebViewController? _webViewControllerForSheet;
    int currentSimilarProductIndex = 0;
    PageController? _pageController; // PageViewのコントローラー
    bool isWebViewExpanded = false;

    bool initialLoadStarted = false; // ここで初期化

    // updateWebView 関数のシグネチャに BuildContext sheetContext を追加
    void updateWebView(Product product, StateSetter setSheetState, BuildContext sheetContext, {bool isInitialLoad = false}) {
      final searchQuery = '${product.brand} ${product.productName}';
      final searchUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(searchQuery)}&tbm=isch';

      if (_webViewControllerForSheet == null || isInitialLoad) {
        _webViewControllerForSheet = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {},
              onPageStarted: (String url) {},
              onPageFinished: (String url) {
                _webViewControllerForSheet?.runJavaScript('window.scrollTo(0, 150);');
              },
              onWebResourceError: (WebResourceError error) {
                // エラーハンドリング
              },
            ),
          )
          ..loadRequest(Uri.parse(searchUrl));
      } else {
        _webViewControllerForSheet!.loadRequest(Uri.parse(searchUrl));
      }
      if (!isInitialLoad) {
          // ここで引数として渡された sheetContext を使用
          if (mounted && sheetContext.mounted) {
            setSheetState(() {});
          }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 背景を透明にする
      enableDrag: false,
      builder: (BuildContext sheetContext) { // この sheetContext を updateWebView に渡す
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            Future<void> loadSimilarProducts() async {
              try {
                final activeBrands = _selectedBrandsForSimilarSearch.entries
                    .where((entry) => entry.value)
                    .map((entry) => entry.key)
                    .toList();
                if (activeBrands.isEmpty) {
                  if (sheetContext.mounted) { // マウント確認
                    setSheetState(() {
                      errorSimilarMessage = '検索対象のメーカーを1つ以上選択してください。';
                      isLoadingSimilar = false;
                    });
                  }
                  return;
                }
                if (!sheetContext.mounted) return;// API呼び出し前に確認

                final products = await widget.fetchSimilarProductsApiCallback(originalProduct, activeBrands);
                
                if (sheetContext.mounted) { // API呼び出し後に再度マウント確認
                  setSheetState(() {
                    similarProducts = products;
                    isLoadingSimilar = false;
                    if (similarProducts.isNotEmpty) {
                      currentSimilarProductIndex = 0;
                      _pageController = PageController(initialPage: currentSimilarProductIndex, viewportFraction: 0.9);
                      // updateWebView の呼び出し箇所で sheetContext を渡す
                      updateWebView(similarProducts.first, setSheetState, sheetContext, isInitialLoad: true);
                    } else {
                      _webViewControllerForSheet = null;
                    }
                  });
                }
              } catch (e) {
                if (sheetContext.mounted) { // マウント確認
                  setSheetState(() {
                    errorSimilarMessage = 'ニタモノ商品の検索中にエラー: ${e.toString()}';
                    isLoadingSimilar = false;
                    _webViewControllerForSheet = null; 
                  });
                }
              }
            }

            if (isLoadingSimilar && similarProducts.isEmpty && errorSimilarMessage == null && !initialLoadStarted) {
              initialLoadStarted = true;
              loadSimilarProducts();
            }

            return BackdropFilter( // すりガラス効果のためにBackdropFilterを追加
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // ぼかしの強度を調整
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.9,
                minChildSize: 0.2,
                maxChildSize: 0.95,
                builder: (_, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient( // グラデーションの色を半透明に調整
                        colors: [
                          darkBottomSheetBackgroundColorStart.withOpacity(0.85), // 半透明度を調整
                          darkBottomSheetBackgroundColorEnd.withOpacity(0.95),   // 半透明度を調整
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    padding: const EdgeInsets.only(top:8.0, left:16.0, right:16.0, bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(child: SizedBox()),
                           IconButton(
                              icon: Icon(Icons.close, color: Colors.grey[400]),
                              onPressed: () {
                                _pageController?.dispose(); 
                                Navigator.of(sheetContext).pop();
                              },
                            ),
                          ],
                        ),
                                              if (!isLoadingSimilar && similarProducts.isEmpty && errorSimilarMessage == null)
                          Expanded(child: Center(child: Text('ニタモノ商品が見つかりませんでした。', style: TextStyle(color: Colors.grey[400], fontSize: 16)))),
                        if (!isWebViewExpanded) // ★★★ WebViewが拡大されていない時だけ表示 ★★★
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              '${originalProduct.emoji ?? ''} 「${originalProduct.productName}」のニタモノ商品',
                              style:TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isWebViewExpanded && !isLoadingSimilar && similarProducts.isNotEmpty) // ★★★ WebViewが拡大されていない時だけ表示 ★★★
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0), // 少し詰める
                              child: Text(
                                '${similarProducts.length} 件の候補', // 表示変更
                                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                              ),
                            ),
                          if (isLoadingSimilar)
                            const Expanded(child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent)))),
                          if (!isLoadingSimilar && errorSimilarMessage != null)
                            Expanded(
child: Center(
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Text(
      errorSimilarMessage!,
      style: TextStyle(color: Colors.redAccent[100], fontWeight: FontWeight.bold, fontSize: 16),
      textAlign: TextAlign.center,
    ),
  ),
),
                            ),
                        if (!isLoadingSimilar && similarProducts.isNotEmpty)
                          Expanded(
                            child: Column(
                              children: [
                                if (!isWebViewExpanded) // ★★★ 拡大されていない時だけ表示 ★★★
                                  SizedBox(
                                    height: 230, // PageViewの高さを調整
                                    child: PageView.builder(
                                      itemCount: similarProducts.length,
                                      controller: _pageController,
                                      onPageChanged: (index) {
                                        if (sheetContext.mounted) { // マウント確認
                                          // updateWebView の呼び出し箇所で sheetContext を渡す
                                          updateWebView(similarProducts[index], setSheetState, sheetContext); 
                                          setSheetState(() { 
                                             currentSimilarProductIndex = index;
                                          });
                                        }
                                      },
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          // ★★★ setSheetState を渡す ★★★
                                          child: _buildSingleSimilarProductItem(context, similarProducts[index], sheetContext, setSheetState),
                                        );
                                      },
                                    ),
                                  ),
                                // ナビゲーションボタンとインジケーターを削除
                                // if (similarProducts.length > 1) 
                                //   Padding(
                                //     ...
                                //   ),
                                if (!isWebViewExpanded) // ★★★ 拡大されていない時だけ表示 ★★★
                                  const SizedBox(height: 8),
                                if (_webViewControllerForSheet != null)
                                  Expanded(
                                    child: Stack( // WebViewとPopupMenuButtonを重ねるためにStackを使用
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(30),
                                          child: WebViewWidget(
                                            controller: _webViewControllerForSheet!,
                                          ),
                                        ),
                                        Positioned( // ★★★ 拡大ボタンを追加 ★★★
                                          top: 8.0,
                                          right: 8.0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                isWebViewExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                                                color: Colors.white,
                                              ),
                                              tooltip: isWebViewExpanded ? '縮小する' : '拡大する',
                                              onPressed: () {
                                                if (sheetContext.mounted) { // マウント確認
                                                  setSheetState(() {
                                                    isWebViewExpanded = !isWebViewExpanded;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        if (similarProducts.length > 1) 
                                          Positioned(
                                            right: 16.0,
                                            bottom: 30.0,
                                            child: Container(
                                                                         padding: const EdgeInsets.all(8.0), 
                                              decoration: BoxDecoration(
                                                color: darkAccentColor.withOpacity(0.85),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.3),
                                                    spreadRadius: 1,
                                                    blurRadius: 3,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              child: PopupMenuButton<int>(
                                                icon: const Icon(Icons.list, color: Colors.black),
                                                tooltip: 'ニタモノ商品を選択',
                                                onSelected: (int index) {
                                                  if (!isWebViewExpanded) {
                                                    _pageController?.jumpToPage(index); 
                                                  }
                                                  if (sheetContext.mounted) { // マウント確認
                                                    // updateWebView の呼び出し箇所で sheetContext を渡す
                                                    updateWebView(similarProducts[index], setSheetState, sheetContext); 
                                                    setSheetState(() {
                                                      currentSimilarProductIndex = index;
                                                    });
                                                  }
                                                },
                                                itemBuilder: (BuildContext context) {
                                                  return List.generate(similarProducts.length, (index) {
                                                    final product = similarProducts[index];
                                                    return PopupMenuItem<int>(
                                                      value: index,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            product.brand, // メーカー名
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey[600],
                                                              fontWeight: FontWeight.normal,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${index + 1}. ${product.productName}',
                                                            style: TextStyle(
                                                              color: currentSimilarProductIndex == index ? darkAccentColor : Colors.black87,
                                                              fontWeight: currentSimilarProductIndex == index ? FontWeight.bold : FontWeight.normal,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 2, // 商品名を2行まで表示可能にする
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                 if (_webViewControllerForSheet == null && errorSimilarMessage == null && similarProducts.isNotEmpty)
                                   const Expanded(child: Center(child: Text('画像表示エリアの準備中です...', style: TextStyle(color: Colors.orangeAccent, fontSize: 16)))),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  String _formatSize(ProductSize size) {
    List<String> parts = [];
    if (size.width != null && size.width! > 0) {
      parts.add('幅: ${size.width!.toStringAsFixed(1)}cm');
    }
    if (size.height != null && size.height! > 0) {
      parts.add('高さ: ${size.height!.toStringAsFixed(1)}cm');
    }
    if (size.depth != null && size.depth! > 0) {
      parts.add('奥行: ${size.depth!.toStringAsFixed(1)}cm');
    }
    if (size.volume != null && size.volume! > 0) {
      parts.add('容量: ${size.volume!.toStringAsFixed(1)}L');
    }
    if (size.apparelSize != null && size.apparelSize!.isNotEmpty) {
      parts.add('サイズ: ${size.apparelSize}');
    }

    if (parts.isEmpty) {
      return 'サイズ情報なし';
    }
    return parts.join(' / ');
  }

  Future<ui.Image> _loadUiImage(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  void _showFrostedModalBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent, // 背景を透明にする
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // ぼかし効果を適用
        child: Container(
          // ここでコンテンツの背景色を半透明に設定できます
          // 例: Colors.white.withOpacity(0.3)
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: const Center(
            child: Text(
              'すりガラス風のBottomSheet',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      );
    },
  );
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