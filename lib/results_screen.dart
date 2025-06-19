import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'procuctmodel.dart'; // Productモデルをインポート
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMobパッケージをインポート
import 'dart:io'; // Platform を使用するためにインポート
import 'dart:ui' as ui; // ui.Image, ui.Canvasのため
import 'brand_data.dart'; // ジャンル・ブランドデータ
import 'saved_products_screen.dart'; // ★★★ 追加: 後で作成するファイル ★★★
import 'dart:ui'; // ImageFilter.blur を使用するために必要
import 'similar_products_bottom_sheet.dart'; // ★★★ 新しいファイルをインポート ★★★

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

  // --- ジャンル関連の状態変数 ---
  late SearchGenre _selectedGenre;
  final List<SearchGenre> _orderedSearchGenres = SearchGenre.values.toList();
  final Map<SearchGenre, bool> _genreVisibility = {
    for (var genre in SearchGenre.values) genre: true,
  };

  @override
  void initState() {
    super.initState();
    _selectedGenre = widget.selectedGenre;

    // ★★★ 修正: 選択されたジャンルに基づいてブランドリストを初期化 ★★★
    final initialBrands = BrandData.getBrandNamesForGenre(_selectedGenre);
    _selectedBrandsForSimilarSearch = {for (var brand in initialBrands) brand: true};

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

  // ★★★ 追加: ジャンル変更時にブランドリストを更新するメソッド ★★★
  void _updateBrandSelectionForGenre(SearchGenre genre) {
    setState(() {
      _selectedGenre = genre;
      // ジャンルに対応するブランドリストを取得
      final newBrands = BrandData.getBrandNamesForGenre(genre);
      // ブランド選択状態をリセット（すべて選択状態にする）
      _selectedBrandsForSimilarSearch = {for (var brand in newBrands) brand: true};
    });
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

  // ▼▼▼▼▼ ここからが変更箇所 (地図検索メソッドの追加) ▼▼▼▼▼
  /// 地図アプリを起動してブランド店舗を検索するメソッド
  Future<void> _openMapForBrand(Product product) async {
    // ブランド名に「店舗」を加えて検索クエリを作成し、URLエンコードする
    final query = Uri.encodeComponent('${product.brand} 店舗');

    // プラットフォームに応じて適切な地図URLを生成
    final Uri mapUri;
    if (Platform.isIOS) {
      // iOSの場合はApple MapsのURLスキームを使用
      mapUri = Uri.parse('https://maps.apple.com/?q=$query');
    } else {
      // Androidやその他のプラットフォームではGoogle MapsのWeb URLを使用
      mapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    }

    // URLを外部アプリケーションで開く試行
    if (!await launchUrl(mapUri, mode: LaunchMode.externalApplication)) {
      // 失敗した場合、ユーザーに通知
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('地図アプリを開けませんでした。', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// 複数の類似商品のブランド店舗をまとめて地図で検索するメソッド
  Future<void> _openMapForSimilarBrands(List<Product> products) async {
    if (!mounted) return;

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('対象の商品がありません。')),
      );
      return;
    }

    // 重複を除いたブランド名のリストを作成
    final brandNames = products.map((p) => p.brand).toSet();
    if (brandNames.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('検索対象のブランドがありません。')),
        );
        return;
    }

    // 検索クエリを作成 ('"ブランドA 店舗" OR "ブランドB 店舗"')
    final searchQuery = brandNames.map((brand) => '"$brand 店舗"').join(' OR ');
    final query = Uri.encodeComponent(searchQuery);

    // プラットフォームに関わらずGoogle MapsのURLを使用する
    final Uri mapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (!await launchUrl(mapUri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('地図アプリを開けませんでした。'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
  // ▲▲▲▲▲ ここまでが変更箇所 ▲▲▲▲▲

   // ...existing code...
    // ★★★★★ 修正: HomeScreenのデザインを適用 ★★★★★
    Widget _buildGenreSelection() {
      // HomeScreenからデザインの定義を引用
      final Color darkCardColor = Colors.grey[850]!.withOpacity(0.85);
  
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // パディングを調整
        decoration: BoxDecoration(
          //color: darkCardColor,
          borderRadius: BorderRadius.circular(0)
         // border: Border.all(color: Colors.white12, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                'ニタモノ検索するジャンルを選択', // コンテナ内のタイトル
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            // ドロップダウンメニューに変更
            DropdownButtonFormField<SearchGenre>(
              value: _selectedGenre,
              items: _orderedSearchGenres
                  .where((g) => _genreVisibility[g] ?? true)
                  .map((SearchGenre genre) {
                return DropdownMenuItem<SearchGenre>(
                  value: genre,
                  child: Text(
                    BrandData.getGenreDisplayName(genre),
                  ),
                );
              }).toList(),
              onChanged: (SearchGenre? newValue) {
                if (newValue != null) {
                  _updateBrandSelectionForGenre(newValue);
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900], // ドロップダウンの背景色
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.cyan, width: 2),
                ),
                prefixIcon: const Icon(Icons.category_outlined, color: Colors.white70), // アイコンを追加
              ),
              dropdownColor: Colors.grey[900], // ドロップダウンメニューの背景色
              style: const TextStyle( // 選択された項目のスタイル
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 16
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white), // ドロップダウンアイコンの色
            ),
          ],
        ),
      );
    }
  
    @override
  // 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
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
      // ★★★ 修正: bodyの実装をシンプルにし、コンテンツの責務を_buildContentに集約 ★★★
      body: Column( 
        children: [
          Expanded( 
            child: Padding(
              padding: const EdgeInsets.fromLTRB(.0, 0, .0, 20.0), // 上のpaddingを0に
              child: _buildContent(),
            ),
          ),
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

    // ★★★★★ 修正: UIの順序とレイアウトを調整 ★★★★★
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black87,
                Colors.black87,
                Colors.white10,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildResultsList(),
            ),
            // --- ジャンル選択 ---
            Divider(
              color: Colors.grey[700],
              thickness: 1,
              height: 1,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                //border: Border.all(color: Colors.white12, width: 1), // 枠線を追加
         //       gradient: LinearGradient(
         //         colors: [
         //           Colors.white10,
         //           Colors.black
         //         ],
         //         begin: Alignment.topCenter,
         //         end: Alignment.bottomLeft,
         //       ),
              ),
              child: Column(children: [
         _buildGenreSelection(), // ← タイトルを削除し、これだけにする
            const SizedBox(height: 6),
            // --- メーカー選択 ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'メーカーを選択:',
                style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(
                maxHeight: 150, // メーカー選択部分の最大高さを設定
              ),
              child: SingleChildScrollView( 
                child: _buildBrandSelectionForSimilarSearch(),
              ),
            ),
              ],),
            ),
           
          ],
        ),
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
      runSpacing: 10.0,
      alignment: WrapAlignment.center,
      children: availableBrandsForSimilar.map((brand) {
        return FilterChip(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5), // パディングを調整
          label: Text(
            brand,
            style: TextStyle(color: _selectedBrandsForSimilarSearch[brand]! ? chipSelectedLabelColor : chipLabelColor, fontWeight: FontWeight.bold,fontSize: 12),
          ),
          selected: _selectedBrandsForSimilarSearch[brand] ?? false,
          onSelected: (bool selected) {
            setState(() {
              _selectedBrandsForSimilarSearch[brand] = selected;
            });
          },
          showCheckmark: true,
          backgroundColor: Colors.black87,
          selectedColor: const Color.fromARGB(127, 0, 187, 212),
          checkmarkColor: chipSelectedLabelColor, // 選択時のチェックマークの色
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(color: _selectedBrandsForSimilarSearch[brand]! ? Colors.transparent : Colors.transparent),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.originalImageFile != null && product.boundingBox != null)
             
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
               // ▼▼▼▼▼ ここからが変更箇所 (地図アイコンの追加) ▼▼▼▼▼
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Chip(
                      label: Text(product.brand, style: TextStyle(color: Colors.white.withOpacity(0.9))),
                      backgroundColor: darkChipColor.withOpacity(0.7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    Expanded(child: const SizedBox(width: 8)),
                    IconButton(
                      onPressed: () => _openMapForBrand(product),
                      icon: const Icon(Icons.map_outlined, color: Colors.lightBlueAccent),
                      tooltip: '店舗を地図で探す',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                // ▲▲▲▲▲ ここまでが変更箇所 ▲▲▲▲▲
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

  // ★★★ 類似商品アイテムを表示するヘルパーウィジェットは新しいファイルに移動したため削除 ★★★

  void _showSimilarProductsBottomSheet(BuildContext context, Product originalProduct) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 背景を透明にする
      enableDrag: false,
      builder: (BuildContext sheetContext) {
        return SimilarProductsBottomSheet(
          originalProduct: originalProduct,
          selectedBrandsForSimilarSearch: _selectedBrandsForSimilarSearch,
          fetchSimilarProductsApiCallback: widget.fetchSimilarProductsApiCallback,
          openMapForSimilarBrands: _openMapForSimilarBrands,
          savedProductUrls: _savedProductUrls,
          toggleSaveProduct: _toggleSaveProduct,
          formatSize: _formatSize,
          darkAccentColor: darkAccentColor,
          darkChipColor: darkChipColor,
        );
      },
    ).then((_) {
      // ボトムシートが閉じた後に保存状態を再読み込みしてUIに反映させる
      _loadSavedProductUrls();
    });
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