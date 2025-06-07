// lib/screens/home_screen.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart'; // 追加
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMobパッケージをインポート
import 'procuctmodel.dart';
import 'results_screen.dart'; // 新しい画面をインポート

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _imageFile;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  // String _currentSearchType = ""; // "image" または "similar" を保持 // ボトムシート化により不要になる可能性

  final ImagePicker _picker = ImagePicker();

  // 選択可能なメーカーのリスト
  final List<String> _availableBrands = ['無印良品', 'イケア', 'ニトリ'];
  // 選択されたメーカーを管理するMap
  late Map<String, bool> _selectedBrands;

  // メーカーごとのトップページURL
  final Map<String, String> _brandTopPageUrls = {
    '無印良品': 'https://www.muji.com/jp/ja/store',
    'イケア': 'https://www.ikea.com/jp/ja/',
    'ニトリ': 'https://www.nitori-net.jp/ec/',
  };

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  // テスト用の広告ユニットID (実際のIDに置き換えてください)
  // Android: ca-app-pub-3940256099942544/6300978111
  // iOS: ca-app-pub-3940256099942544/2934735716
  final String _bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111' // AndroidのテストID
      : 'ca-app-pub-3940256099942544/2934735716'; // iOSのテストID

  @override
  void initState() {
    super.initState();
    // 初期状態で全てのメーカーを選択状態にする
    _selectedBrands = {for (var brand in _availableBrands) brand: true};
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

  // 選択されたメーカーに基づいてAPIプロンプトを動的に生成する関数
  String _generatePrompt(List<String> selectedBrands) {
    final brandListString = selectedBrands.map((b) => '- $b').join('\n');

    return """
あなたは、画像から家具や雑貨を特定する専門家です。
提供された画像の中に、以下のメーカーの商品があるか検索してください。

対象メーカー:
$brandListString

画像内に該当する商品が見つかった場合、その商品一つ一つについて、以下の情報を厳密なJSON形式でリストとして返してください。
複数の商品が該当する場合は、それぞれの商品情報をリストに含めてください。

出力形式のルール:
- ルート要素は `products` というキーを持つJSON配列（リスト）とします。
- 配列の各要素は、一つの商品を表すJSONオブジェクトです。
- 各商品オブジェクトは、以下のキーを含みます:
  - `product_name`: 商品名を文字列で指定します。
  - `brand`: メーカー名（「無印良品」、「イケア」、「ニトリ」のいずれか）を文字列で指定します。
  - `size`: サイズ情報を格納するJSONオブジェクトです。
    - `width`: 横幅をcm単位の数値で指定します。不明な場合は、類似商品から推測されるサイズを数値で指定してください。
    - `height`: 高さをcm単位の数値で指定します。不明な場合は、類似商品から推測されるサイズを数値で指定してください。
    - `depth`: 奥行きをcm単位の数値で指定します。不明な場合は、類似商品から推測されるサイズを数値で指定してください。
  - `description`: 商品の特徴や説明を文字列で指定します。
  - `product_url`: 商品の公式ページまたは販売ページのURLを文字列で指定します。不明な場合は空文字列 "" としてください。
- 画像内に該当する商品が一つも見つからなかった場合は、空の配列 `{"products": []}` を返してください。
- JSONの前後に、他の説明文や挨拶などを一切含めないでください。
""";
  }

  String _generateSimilarProductPrompt(Product originalProduct, List<String> selectedBrands) {
    final brandListString = selectedBrands.map((b) => '- $b').join('\n');
    return """
あなたは、家具や雑貨の類似商品を提案する専門家です。
以下の商品の情報と、指定されたメーカーのリストに基づいて、類似商品を提案してください。

元の商品情報:
- 商品名: ${originalProduct.productName}
- ブランド: ${originalProduct.brand}
- 説明: ${originalProduct.description}
- サイズ: 幅${originalProduct.size.width}cm x 高さ${originalProduct.size.height}cm x 奥行き${originalProduct.size.depth}cm

検索対象メーカー:
$brandListString

類似商品を、その商品一つ一つについて、以下の情報を厳密なJSON形式でリストとして返してください。
複数の商品が該当する場合は、それぞれの商品情報をリストに含めてください。
各メーカー5件ずつ提案してください。

出力形式のルール:
- ルート要素は `products` というキーを持つJSON配列（リスト）とします。
- 配列の各要素は、一つの商品を表すJSONオブジェクトです。
- 各商品オブジェクトは、以下のキーを含みます:
  - `product_name`: 商品名を文字列で指定します。
  - `brand`: メーカー名（検索対象メーカーのいずれか）を文字列で指定します。
  - `size`: サイズ情報を格納するJSONオブジェクトです。
    - `width`: 横幅をcm単位の数値で指定します。
    - `height`: 高さをcm単位の数値で指定します。
    - `depth`: 奥行きをcm単位の数値で指定します。
  - `description`: 商品の特徴や説明を文字列で指定します。
  - `product_url`: 商品の公式ページまたは販売ページのURLを文字列で指定します。不明な場合は空文字列 "" としてください。
- 該当する類似商品が一つも見つからなかった場合は、空の配列 `{"products": []}` を返してください。
- JSONの前後に、他の説明文や挨拶などを一切含めないでください。
""";
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _products = [];
        _errorMessage = null;
        // _currentSearchType = ""; // 不要になる可能性
      });
    }
  }

  Future<void> _resetImageSelection() async {
    setState(() {
      _imageFile = null;
      _products = [];
      _errorMessage = null;
    });
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _products = [];
      // _currentSearchType = "image"; // 不要になる可能性
    });

    try {
      final activeBrands = _selectedBrands.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (activeBrands.isEmpty) {
        throw Exception('検索対象のメーカーを1つ以上選択してください。');
      }
      
      final prompt = _generatePrompt(activeBrands);

      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null) {
        throw Exception('APIキーが設定されていません。');
      }

      final model = GenerativeModel(model: 'gemini-2.0-flash-lite', apiKey: apiKey);
      final Uint8List imageBytes = await _imageFile!.readAsBytes();
      final imagePart = DataPart('image/jpeg', imageBytes);
      final response = await model.generateContent([
        Content.multi([TextPart(prompt), imagePart])
      ]);

      List<Product> products = [];
      String? errorMessage;

      if (response.text != null) {
        final cleanedJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        final decodedJson = jsonDecode(cleanedJson);
        final List<dynamic> productListJson = decodedJson['products'];
        
        products = productListJson.map((itemJson) {
            final Map<String, dynamic> item = itemJson as Map<String, dynamic>;
            // product_urlの処理はボトムシート内の類似商品検索でも同様に必要
            return Product.fromJson(item);
          }).toList();
      } else {
         errorMessage = 'APIから有効なレスポンスがありませんでした。';
      }
      // 状態を更新してから画面遷移
      setState(() {
        _products = products;
        _errorMessage = errorMessage;
        _isLoading = false;
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              products: _products,
              errorMessage: _errorMessage,
              selectedBrands: _selectedBrands, // ResultsScreenに渡す
              brandTopPageUrls: _brandTopPageUrls, // ResultsScreenに渡す
              fetchSimilarProductsApiCallback: _fetchSimilarProductsApi, // ResultsScreenに渡す
            ),
          ),
        );
      }

    } catch (e) {
      setState(() {
        _errorMessage = 'エラーが発生しました: ${e.toString()}';
        _isLoading = false;
      });
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              products: [], // エラー時は空のリスト
              errorMessage: _errorMessage,
              selectedBrands: _selectedBrands,
              brandTopPageUrls: _brandTopPageUrls,
              fetchSimilarProductsApiCallback: _fetchSimilarProductsApi,
            ),
          ),
        );
      }
    }
    // finallyブロックは不要になるか、isLoadingの制御のみ残す
    // finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
  }

  // 画面全体の類似商品検索は削除または変更
  // Future<void> _searchSimilarProducts() async { ... } // このメソッドは不要になるか、ボトムシート用に変更

  Future<List<Product>> _fetchSimilarProductsApi(Product originalProduct, List<String> selectedBrands) async {
    final prompt = _generateSimilarProductPrompt(originalProduct, selectedBrands);
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('APIキーが設定されていません。');
    }

    // モデルはテキスト生成に適したものを使用してください (例: 'gemini-pro' や 'gemini-1.5-flash-latest' など)
    // 'gemini-2.0-flash-lite' がテキスト生成に最適化されているか確認してください。
    final model = GenerativeModel(model: 'gemini-2.0-flash-lite', apiKey: apiKey); // テキスト生成に適したモデルを推奨
    final response = await model.generateContent([
      Content.text(prompt)
    ]);

    // デバッグ用にAPIレスポンスを出力
    debugPrint('Gemini API Response for similar products: ${response.text}');

    if (response.text != null) {
      final cleanedJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
      if (cleanedJson.isEmpty) {
        // APIが空の文字列を返した場合、空のリストとして扱う
        debugPrint('API returned an empty string for similar products.');
        return [];
      }
      try {
        final decodedJson = jsonDecode(cleanedJson);
        // 'products' キーが存在し、かつリストであることを確認
        final dynamic productsData = decodedJson['products'];
        if (productsData is List) {
          final List<dynamic> productListJson = productsData;
          return productListJson.map((itemJson) {
            final Map<String, dynamic> item = itemJson as Map<String, dynamic>;
            String productUrl = item['product_url'] as String? ?? '';
            final String brand = item['brand'] as String? ?? '';

            // ボトムシート内でもURLが空の場合、ブランドトップページをフォールバック
            if (productUrl.isEmpty && brand.isNotEmpty && _brandTopPageUrls.containsKey(brand)) {
              productUrl = _brandTopPageUrls[brand]!;
            }
            
            final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(item);
            updatedItem['product_url'] = productUrl;
            
            return Product.fromJson(updatedItem);
          }).toList();
        } else {
          // 'products' がリストでない、または存在しない場合
          debugPrint("'products' key is not a list or not found in API response. Decoded JSON: $decodedJson");
          return []; // 空のリストを返す
        }
      } catch (e) {
        // JSONパースエラーの場合
        debugPrint('Error decoding JSON for similar products: $e');
        debugPrint('Problematic JSON string for similar products: $cleanedJson');
        throw Exception('類似商品のレスポンスJSONの解析に失敗しました。APIからの応答を確認してください。');
      }
    } else {
      throw Exception('APIから類似商品の有効なレスポンスがありませんでした (response.text is null)。');
    }
  }

@override
  Widget build(BuildContext context) {
    // ダークテーマ用のベースカラー
    final Color darkPrimaryColor = const Color.fromARGB(255, 193, 115, 196)!;
    final Color darkBackgroundColor = Colors.grey[900]!;
    final Color darkCardColor = Colors.grey[850]!.withOpacity(0.9);
    final Color darkChipColor = Colors.grey[700]!;

    return Scaffold(
      backgroundColor: darkBackgroundColor, // 背景色をダークに
      appBar: AppBar(
        title: const Text('イエノモノ', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[850], // AppBarの背景色
        elevation: 0, // AppBarの影を消してフラットに
      ),
      body: Column( // bodyをColumnでラップ
        children: [
          Expanded( // メインコンテンツをExpandedでラップして残りのスペースを埋める
            child: Container( // 全体にグラデーション背景を適用
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [darkBackgroundColor, Colors.grey[850]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade800.withOpacity(0.5), // 少し透明に
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.file(_imageFile!, fit: BoxFit.cover),
                              )
                            : Center(child: Text('画像を選択してください', style: TextStyle(color: Colors.grey[400]))),
                      ),
                      const SizedBox(height: 16),
                      
                      if (_imageFile == null)
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('1. 画像を選択'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkPrimaryColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _resetImageSelection,
                          icon: const Icon(Icons.refresh),
                          label: const Text('画像を再選択',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            shadowColor: Colors.transparent,
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      const SizedBox(height: 16),
                      
                      Text('2. 検索対象のメーカーを選択', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[300])),
                      const SizedBox(height: 8),
                      _buildBrandSelection(), // スタイルはメソッド内で調整
                      const SizedBox(height: 16),
                      
                      ElevatedButton.icon(
                        onPressed: _imageFile == null || _isLoading ? null : _analyzeImage,
                        icon: const Icon(Icons.analytics),
                        label: const Text('3. この画像を解析'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[400],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),

                      const SizedBox(height: 24),
                      //Divider(color: Colors.grey[700]),

                      if (_isLoading)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(darkPrimaryColor)),
                                const SizedBox(height: 10),
                                Text('AIが画像を解析中です...', style: TextStyle(color: Colors.grey[400])),
                              ],
                            ),
                          ),
                        ),
                      // _errorMessage と _products の表示ロジックは ResultsScreen に移動したため削除
                      // if (_errorMessage != null) ...
                      // if (!_isLoading && _products.isNotEmpty) ...
                      // if (!_isLoading && _products.isEmpty && _imageFile != null && _errorMessage == null) ...
                    ],
                  ),
                ),
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

  Widget _buildBrandSelection() {
    final Color darkPrimaryColor = Colors.tealAccent[400]!;
    final Color darkChipBackgroundColor = Colors.grey[800]!;
    final Color darkChipSelectedColor = darkPrimaryColor.withOpacity(0.3);

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _availableBrands.map((brand) {
        return FilterChip(
          label: Text(brand, style: TextStyle(color: _selectedBrands[brand]! ? Colors.black : Colors.grey[300])),
          selected: _selectedBrands[brand] ?? false,
          onSelected: (bool selected) {
            setState(() {
              _selectedBrands[brand] = selected;
            });
          },
          backgroundColor: darkChipBackgroundColor,
          selectedColor: darkChipSelectedColor,
          checkmarkColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _selectedBrands[brand]! ? darkPrimaryColor : Colors.grey[700]!),
          ),
        );
      }).toList(),
    );
  }

  // _buildResultsList メソッドは ResultsScreen に移動したため削除
  // Widget _buildResultsList() { ... }

  // _showSimilarProductsBottomSheet メソッドは ResultsScreen に移動したため削除
  // void _showSimilarProductsBottomSheet(BuildContext context, Product originalProduct) { ... }
}