import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 日時フォーマット用 (pubspec.yaml に intl: ^any を追加してください)
import '../procuctmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'brand_data.dart'; // ★★★ 追加: brand_data.dart をインポート ★★★
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ★★★ 追加 ★★★
import 'dart:io'; // ★★★ 追加 ★★★
import 'similar_products_bottom_sheet.dart'; // ★★★ 追加 ★★★
import 'home_screen.dart'; // ★★★ 追加 ★★★

enum SortCriteria {
  savedDateDesc,
  savedDateAsc,
  nameAsc,
  nameDesc,
}

class SavedProductsScreen extends StatefulWidget {
  const SavedProductsScreen({super.key});

  @override
  State<SavedProductsScreen> createState() => _SavedProductsScreenState();
}

class _SavedProductsScreenState extends State<SavedProductsScreen> {
  final PreferenceService _preferenceService = PreferenceService();
  List<Product> _savedProducts = [];
  bool _isLoading = true;
  SortCriteria _currentSortCriteria = SortCriteria.savedDateDesc;
  Set<String> _savedProductUrls = {}; // ★★★ 追加 ★★★

  // ★★★ Apple風デザインのためのカラーパレット ★★★
  final Color appBarColor = Colors.black; // AppBarの背景色 (濃いグレー)
  final Color scaffoldStartColor = Colors.black; // グラデーションの始点はやや明るいグレー
  final Color scaffoldEndColor = Colors.black87; // グラデーションの終点は濃いグレー
  final Color cardBackgroundColor = const Color.fromRGBO(44, 44, 46, 0.85); // カード背景 (半透明の濃いグレー)
  final Color chipBackgroundColor = const Color.fromRGBO(60, 60, 62, 0.8); // チップ背景 (半透明のやや明るいグレー)
  final Color primaryTextColor = Colors.white.withOpacity(0.9);
  final Color secondaryTextColor = Colors.white.withOpacity(0.65);
  final Color tertiaryTextColor = Colors.white.withOpacity(0.5);
  final Color accentColor = const Color(0xFF0A84FF); // Apple風ブルー (リンクやアクセントに)
  final Color deleteButtonColor = Colors.redAccent[100]!.withOpacity(0.85);

  // ★★★ バナー広告関連の変数 ★★★
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  final String _bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7148683667182672/9797170752' // AndroidのテストID
      : 'ca-app-pub-7148683667182672/3020009417'; // iOSのテストID

  // ★★★★★ ここから追加 ★★★★★
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  final String _interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7148683667182672/5564236103' // AndroidのテストID (Google提供)
      : 'ca-app-pub-7148683667182672/2770551808'; // iOSのテストID (Google提供)
  // ★★★★★ ここまで追加 ★★★★★

  @override
  void initState() {
    super.initState();
    _loadSavedProducts();
    _loadBannerAd(); // ★★★ バナー広告をロード ★★★
    _loadInterstitialAd(); // ★★★★★ 追加 ★★★★★
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // ★★★ バナー広告を破棄 ★★★
    _interstitialAd?.dispose(); // ★★★★★ 追加 ★★★★★
    super.dispose();
  }

  // ★★★ バナー広告をロードするメソッド ★★★
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.largeBanner, // 通常のバナーサイズ。largeBannerも可
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          debugPrint('BannerAd failed to load: $error');
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = false;
            });
          }
        },
      ),
    )..load();
  }

  // ★★★★★ ここから追加 ★★★★★
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }
  // ★★★★★ ここまで追加 ★★★★★

  Future<void> _loadSavedProducts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    _savedProducts = await _preferenceService.getSavedProducts();
    _savedProductUrls = await _preferenceService.getSavedProductUrls(); // ★★★ 追加 ★★★
    _sortProducts(); // 初期ソート
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sortProducts() {
    switch (_currentSortCriteria) {
      case SortCriteria.savedDateDesc:
        _savedProducts.sort((a, b) => (b.savedAt ?? DateTime(0)).compareTo(a.savedAt ?? DateTime(0)));
        break;
      case SortCriteria.savedDateAsc:
        _savedProducts.sort((a, b) => (a.savedAt ?? DateTime(0)).compareTo(b.savedAt ?? DateTime(0)));
        break;
      case SortCriteria.nameAsc:
        _savedProducts.sort((a, b) => a.productName.toLowerCase().compareTo(b.productName.toLowerCase()));
        break;
      case SortCriteria.nameDesc:
        _savedProducts.sort((a, b) => b.productName.toLowerCase().compareTo(a.productName.toLowerCase()));
        break;
    }
  }

  Future<void> _removeProduct(Product product) async {
    await _preferenceService.removeProduct(product.productUrl);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('「${product.productName}」を削除しました。'), backgroundColor: Colors.grey[700]),
    );
    _loadSavedProducts(); // リストを再読み込みして更新
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '日時不明';
    return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
  }

  // ★★★★★ ここから追加 ★★★★★

  /// 類似商品を検索するためのボトムシートを表示する
  void _showSimilarProductsBottomSheet(BuildContext context, Product originalProduct) {
    // ★★★★★ ここから変更 ★★★★★
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _loadInterstitialAd(); // 次の広告を事前にロード
          _showGenreSelectionDialog(context, originalProduct); // ★★★ 変更: ジャンル選択ダイアログを表示
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _loadInterstitialAd(); // 次の広告を事前にロード
          _showGenreSelectionDialog(context, originalProduct); // ★★★ 変更: ジャンル選択ダイアログを表示
        },
      );
      _interstitialAd!.show();
    } else {
      _loadInterstitialAd(); // 次回のために広告をロードしておく
      _showGenreSelectionDialog(context, originalProduct); // ★★★ 変更: ジャンル選択ダイアログを表示
    }
    // ★★★★★ ここまで変更 ★★★★★
  }

  // ★★★★★ ここから追加 ★★★★★
  /// ジャンル選択ダイアログを表示する
  Future<void> _showGenreSelectionDialog(BuildContext context, Product originalProduct) async {
    final selectedGenre = await showDialog<SearchGenre>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: cardBackgroundColor,
          title: Text('検索ジャンルを選択', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: SearchGenre.values.length,
              itemBuilder: (BuildContext context, int index) {
                final genre = SearchGenre.values[index];
                return ListTile(
                  title: Text(
                    BrandData.getGenreDisplayName(genre),
                    style: TextStyle(color: primaryTextColor),
                  ),
                  onTap: () {
                    Navigator.of(dialogContext).pop(genre);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('キャンセル', style: TextStyle(color: accentColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );

    if (selectedGenre != null) {
      _openSimilarProductsSheet(context, originalProduct, selectedGenre);
    }
  }

  void _openSimilarProductsSheet(BuildContext context, Product originalProduct, SearchGenre genre) {
    // ★★★★★ ここまで変更 ★★★★★

    // 推測したジャンルに属するすべてのブランドを検索対象とする
    final brandsForGenre = BrandData.getBrandNamesForGenre(genre);
    final selectedBrands = {for (var brand in brandsForGenre) brand: true};

    // `fetchSimilarProductsApi` にジャンルを渡すためのラッパー関数
    Future<List<Product>> fetchApiCallback(Product p, List<String> brands) {
      return fetchSimilarProductsApi(p, brands, genre);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      builder: (BuildContext sheetContext) {
        return SimilarProductsBottomSheet(
          originalProduct: originalProduct,
          selectedBrandsForSimilarSearch: selectedBrands,
          fetchSimilarProductsApiCallback: fetchApiCallback,
          openMapForSimilarBrands: _openMapForSimilarBrands,
          savedProductUrls: _savedProductUrls,
          toggleSaveProduct: _toggleSaveProduct,
          formatSize: _formatSize,
          darkAccentColor: accentColor,
          darkChipColor: chipBackgroundColor,
        );
      },
    ).then((_) {
      // ボトムシートが閉じた後に、保存済みリストを再読み込みする
      _loadSavedProducts();
    });
  }
  // ★★★★★ ここまで追加 ★★★★★

  /// 複数の類似商品のブランド店舗をまとめて地図で検索するメソッド
  Future<void> _openMapForSimilarBrands(List<Product> products) async {
    if (!mounted) return;

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('地図で表示する商品がありません。')),
      );
      return;
    }

    final brandNames = products.map((p) => p.brand).toSet();
    if (brandNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('店舗を検索するブランド名がありません。')),
      );
      return;
    }

    final searchQuery = brandNames.map((brand) => '"$brand 店舗"').join(' OR ');
    final query = Uri.encodeComponent(searchQuery);

    final Uri mapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (!await launchUrl(mapUri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('地図アプリを開けませんでした。')),
        );
      }
    }
  }

  /// 商品の保存状態を切り替えるメソッド
  Future<void> _toggleSaveProduct(Product product) async {
    if (product.productUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('この商品のURLは保存できません。'), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }
    final isCurrentlySaved = _savedProductUrls.contains(product.productUrl);
    if (isCurrentlySaved) {
      await _preferenceService.removeProduct(product.productUrl);
      _savedProductUrls.remove(product.productUrl);
      _savedProducts.removeWhere((p) => p.productUrl == product.productUrl);
    } else {
      await _preferenceService.saveProduct(product);
      _savedProductUrls.add(product.productUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「${product.productName}」を保存しました。'), backgroundColor: Colors.green),
        );
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  /// ProductSizeオブジェクトを整形された文字列に変換する
  String _formatSize(ProductSize size) {
    List<String> parts = [];
    if (size.width != null && size.width! > 0) {
      parts.add('幅: ${size.width}cm');
    }
    if (size.height != null && size.height! > 0) {
      parts.add('高さ: ${size.height}cm');
    }
    if (size.depth != null && size.depth! > 0) {
      parts.add('奥行: ${size.depth}cm');
    }
    if (size.volume != null && size.volume! > 0) {
      parts.add('容量: ${size.volume}L');
    }
    if (size.apparelSize != null && size.apparelSize!.isNotEmpty) {
      parts.add('サイズ: ${size.apparelSize}');
    }

    if (parts.isEmpty) {
      return 'サイズ情報なし';
    }
    return parts.join(' / ');
  }

  // ★★★★★ ここまで追加 ★★★★★

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black87, // グラデーションで設定するため削除
      appBar: AppBar(
        title: Text('保存した商品', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600, fontSize: 17)),
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: primaryTextColor),
        elevation: 0,
        actions: [
          PopupMenuButton<SortCriteria>(
            surfaceTintColor: appBarColor,
            color: appBarColor, // ドロップダウンメニューの背景
            icon: Icon(Icons.sort, color: primaryTextColor),
            tooltip: '並び替え',
            // style: ButtonStyle( // 不要な場合が多い
            // ),
            onSelected: (SortCriteria result) {
              if (mounted) {
                setState(() {
                  _currentSortCriteria = result;
                  _sortProducts();
                });
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortCriteria>>[
              PopupMenuItem<SortCriteria>(
                value: SortCriteria.savedDateDesc,
                child: Text('保存が新しい順',style: TextStyle(color: primaryTextColor, fontSize: 14)),
              ),
              PopupMenuItem<SortCriteria>(
                value: SortCriteria.savedDateAsc,
                child: Text('保存が古い順',style: TextStyle(color: primaryTextColor, fontSize: 14)),
              ),
              PopupMenuItem<SortCriteria>(
                value: SortCriteria.nameAsc,
                child: Text('商品名 (昇順)',style: TextStyle(color: primaryTextColor, fontSize: 14)),
              ),
              PopupMenuItem<SortCriteria>(
                value: SortCriteria.nameDesc,
                child: Text('商品名 (降順)',style: TextStyle(color: primaryTextColor, fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
      body: Container( // ★★★ 背景グラデーションコンテナ ★★★
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scaffoldStartColor,
              scaffoldEndColor,
            ],
            stops: const [0.0, 0.7], // グラデーションの割合を調整
          ),
        ),
        child: Column( // ★★★ ListViewと広告を縦に並べるためにColumnを追加 ★★★
          children: [
            Expanded( // ★★★ ListView.builderをExpandedでラップ ★★★
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentColor)))
                  : _savedProducts.isEmpty
                      ? Center(
                          child: Text(
                            '保存された商品はありません。',
                            style: TextStyle(color: secondaryTextColor, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // パディング調整
                          itemCount: _savedProducts.length,
                          itemBuilder: (context, index) {
                            final product = _savedProducts[index];
                            final brandTopPageUrl = BrandData.brandTopPageUrls[product.brand];

                            return Card(
                              color: cardBackgroundColor, // ★★★ カード背景色変更 ★★★
                              elevation: 0, // Apple風デザインでは影は控えめか無し
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), // 角丸調整
                              margin: const EdgeInsets.symmetric(vertical: 10.0), // マージン調整
                              child: Padding(
                                padding: const EdgeInsets.all(18.0), // カード内パディング調整
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${product.emoji ?? ''} ${product.productName}',
                                            style: TextStyle(color: primaryTextColor, fontSize: 18, fontWeight: FontWeight.w600, height: 1.3), // ★★★ テキストスタイル調整 ★★★
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline, color: deleteButtonColor), // 色調整
                                          tooltip: '削除する',
                                          padding: EdgeInsets.zero, // IconButtonのデフォルトパディングを削除
                                          constraints: const BoxConstraints(), // IconButtonの最小サイズ制約を削除
                                          onPressed: () => _showDeleteConfirmationDialog(product),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap( // Chipが複数行になる場合も考慮
                                      spacing: 8.0,
                                      runSpacing: 4.0,
                                      children: [
                                        Chip(
                                          label: Text(product.brand, style: TextStyle(color: primaryTextColor.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w500)),
                                          backgroundColor: chipBackgroundColor, // ★★★ チップ背景色変更 ★★★
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0), // Chipパディング調整
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // タップ領域を最小化
                                        ),
                                      ],
                                    ),
                                    if (brandTopPageUrl != null && brandTopPageUrl.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12.0),
                                        child: InkWell(
                                          onTap: () async {
                                            final Uri url = Uri.parse(brandTopPageUrl);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url, mode: LaunchMode.externalApplication);
                                            } else {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('URLを開けませんでした: $brandTopPageUrl'),
                                                    backgroundColor: Colors.redAccent,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.public, size: 16, color: secondaryTextColor),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  brandTopPageUrl,
                                                  style: TextStyle(
                                                    color: accentColor, // ★★★ アクセントカラー使用 ★★★
                                                    fontSize: 13,
                                                    decoration: TextDecoration.underline,
                                                    decorationColor: accentColor.withOpacity(0.7),
                                                    decorationThickness: 1.5,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        Icon(Icons.straighten, size: 18, color: secondaryTextColor),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            product.size.toString(),
                                            style: TextStyle(color: secondaryTextColor, fontSize: 14, fontWeight: FontWeight.w500), // ★★★ テキストスタイル調整 ★★★
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    if (product.description.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 14.0),
                                        child: Text(
                                          product.description,
                                          style: TextStyle(color: secondaryTextColor.withOpacity(0.95), fontSize: 13.5, height: 1.45, letterSpacing: 0.1), // ★★★ テキストスタイル調整 ★★★
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    Row(
                                      children: [
                                        Icon(Icons.bookmark_added_outlined, size: 16, color: tertiaryTextColor),
                                        const SizedBox(width: 8),
                                        Text(
                                          '保存日時: ${_formatDateTime(product.savedAt)}',
                                          style: TextStyle(color: tertiaryTextColor, fontSize: 12), // ★★★ テキストスタイル調整 ★★★
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            final searchQuery = '${product.brand} ${product.productName}';
                                            final Uri url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(searchQuery)}');
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url, mode: LaunchMode.externalApplication);
                                            } else {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('検索ページを開けませんでした。'),
                                                    backgroundColor: Colors.redAccent,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0), // タップ領域調整
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min, // Rowの幅をコンテンツに合わせる
                                              children: [
                                                Icon(Icons.search, size: 18, color: accentColor), // ★★★ アクセントカラー使用 ★★★
                                                const SizedBox(width: 8),
                                                Text( // Expandedを削除し、テキストが短くてもアイコンに寄るように
                                                  'Googleで検索する',
                                                  style: TextStyle(
                                                    color: accentColor, // ★★★ アクセントカラー使用 ★★★
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  // overflow: TextOverflow.ellipsis, // 不要
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // ★★★★★ ここから変更 ★★★★★
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.search_sharp, size: 16),
                                          label: const Text('ニタモノを探す'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: accentColor.withOpacity(0.15),
                                            foregroundColor: accentColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                              side: BorderSide(color: accentColor.withOpacity(0.5)),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            elevation: 0,
                                          ),
                                          onPressed: () {
                                            _showSimilarProductsBottomSheet(context, product);
                                          },
                                        ),
                                        // ★★★★★ ここまで変更 ★★★★★
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            // ★★★ バナー広告表示エリア ★★★
            if (_bannerAd != null && _isBannerAdLoaded)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(Product product) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // ユーザーはダイアログ外をタップして閉じられない
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text('確認', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('「${product.productName}」を保存済みリストから削除しますか？', style: TextStyle(color: Colors.grey[300])),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル', style: TextStyle(color: Colors.grey[400])),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('削除', style: TextStyle(color: Colors.redAccent[100])),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _removeProduct(product);
              },
            ),
          ],
        );
      },
    );
  }
}