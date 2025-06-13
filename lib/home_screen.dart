import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui; // RectとImageのためにインポート
import 'package:flutter/gestures.dart'; // この行を追加
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'procuctmodel.dart';
import 'results_screen.dart';
import 'brand_data.dart'; // ★ 追加

// enum SearchGenre { lifestyle, apparel, outdoor, bag, sports, sneakers } // ★ brand_data.dart に移動

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver { // WidgetsBindingObserver をミックスイン
  File? _imageFile;
  ui.Image? _displayedUiImage; // CustomPainterで描画するためのデコード済み画像
  Rect? _drawnRect; // ユーザーが描画した矩形
  bool _isDrawing = false; // 描画中かどうかのフラグ
  Offset? _panStartOffset; // ドラッグ開始位置
  Offset? _panCurrentOffset; // ドラッグ中の現在位置
  GlobalKey _customPaintKey = GlobalKey(); // CustomPaintのキー

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  final ImagePicker _picker = ImagePicker();

  SearchGenre _selectedGenre = SearchGenre.lifestyle; // 初期ジャンル

  
  late List<String> _currentAvailableBrands; // 現在選択中のジャンルのブランドリスト
  late Map<String, bool> _selectedBrands;

  

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  final String _bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7148683667182672/9797170752' // AndroidのテストID
      : 'ca-app-pub-7148683667182672/3020009417'; // iOSのテストID

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  final String _interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7148683667182672/5564236103' // AndroidのテストID (Google提供)
      : 'ca-app-pub-7148683667182672/2770551808'; // iOSのテストID (Google提供)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ライフサイクル監視を開始
    _updateBrandSelectionForGenre(_selectedGenre);
    _loadBannerAd();
    _loadInterstitialAd(); // インタースティシャル広告をロード
    // initStateではすぐに表示せず、didChangeAppLifecycleStateで最初のresume時や、
    // _loadInterstitialAdの完了時に表示を試みる
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ライフサイクル監視を終了
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _displayedUiImage?.dispose(); // ui.Imageをdispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // アプリがフォアグラウンドに戻ったときに広告表示を試みる
      //_showInterstitialAdIfNeeded(isAppLaunch: false);
    }
  }

  void _updateBrandSelectionForGenre(SearchGenre genre) {
    setState(() {
      _selectedGenre = genre;
      if (_selectedGenre == SearchGenre.lifestyle) {
        _currentAvailableBrands = List.from(BrandData.availableLifestyleBrands); // ★ 変更
      } else if (_selectedGenre == SearchGenre.apparel) {
        _currentAvailableBrands = List.from(BrandData.availableApparelBrands); // ★ 変更
      } else if (_selectedGenre == SearchGenre.outdoor) {
        _currentAvailableBrands = List.from(BrandData.availableOutdoorBrands); // ★ 変更
      } else if (_selectedGenre == SearchGenre.bag) {
        _currentAvailableBrands = List.from(BrandData.availableBagBrands); // ★ 変更
      } else if (_selectedGenre == SearchGenre.sports) {
        _currentAvailableBrands = List.from(BrandData.availableSportsBrands); // ★ 変更
      } else if (_selectedGenre == SearchGenre.sneakers) {
        _currentAvailableBrands = List.from(BrandData.availableSneakersBrands); // ★ 変更
      }
      // 常にすべてのブランドを選択状態にする
      _selectedBrands = {for (var brand in _currentAvailableBrands) brand: true};
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

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('$ad loaded');
          _interstitialAd?.dispose(); // 既存の広告があれば破棄
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;

          // アプリ起動時（最初のresume前）にロード完了した場合も考慮
          // ただし、解析フローの広告表示と競合しないように注意が必要
          // ここでは、didChangeAppLifecycleStateの初回resumeで表示することを期待する
          // もしくは、特定の条件下（例：初回起動時のみ）で表示するロジックを追加

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) =>
                debugPrint('$ad onAdShowedFullScreenContent.'),
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              debugPrint('$ad onAdDismissedFullScreenContent.');
              ad.dispose();
              _isInterstitialAdLoaded = false; // 表示後はロードされていない状態に戻す
              _loadInterstitialAd(); // 次の広告をロード
              // _proceedWithAnalysis(); // ★広告が閉じられた後に解析を続行 - これは解析フロー専用
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
              ad.dispose();
              _isInterstitialAdLoaded = false;
              _loadInterstitialAd(); // 次の広告をロード
              // _proceedWithAnalysis(); // ★表示失敗時も解析を続行 - これは解析フロー専用
            },
          );
          // アプリ起動時に広告を表示するフラグが立っていれば表示
          // if (_shouldShowAdOnAppLaunch) {
          //   _showInterstitialAdIfNeeded(isAppLaunch: true);
          //   _shouldShowAdOnAppLaunch = false; // 表示後はフラグを下ろす
          // }
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error.');
          _isInterstitialAdLoaded = false;
          // 必要であればリトライ処理などをここに追加
        },
      ));
  }

  // 解析フローとは別にインタースティシャル広告を表示するメソッド
  Future<void> _showInterstitialAdIfNeeded({bool isAppLaunch = false}) async {
    // _isLoading は解析中のローディングであり、アプリ起動時の広告表示とは直接関係ない場合がある
    // 解析ボタン押下時の広告表示(_showInterstitialAdAndAnalyze)と区別する
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      // 解析処理(_proceedWithAnalysis)を伴わない広告表示
      // 他の広告表示ロジック（例：解析前広告）と競合しないように注意
      // ここでは、単純に広告を表示するだけ
      await _interstitialAd!.show();
      // 表示後は _isInterstitialAdLoaded を false にし、_loadInterstitialAd を呼んでおくのが一般的
      // onAdDismissedFullScreenContent で再ロードしているのでここでは不要かもしれないが、
      // show() が成功した時点で次の広告を準備し始めるのが安全
    } else {
      debugPrint('Interstitial ad not ready for showing (isAppLaunch: $isAppLaunch).');
      if (!_isInterstitialAdLoaded) {
        _loadInterstitialAd(); // ロードされていなければロードを試みる
      }
    }
  }

  bool _shouldShowAdOnAppLaunch = false; // アプリ起動時に広告を表示すべきかどうかのフラグ

  Future<void> _showInterstitialAdAndAnalyze() async {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      // このメソッドは解析前に広告を表示するためのもの
      // 広告表示後に _proceedWithAnalysis が呼ばれるように fullScreenContentCallback が設定されている前提
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) =>
                debugPrint('$ad onAdShowedFullScreenContent (during analysis flow).'),
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              debugPrint('$ad onAdDismissedFullScreenContent (during analysis flow).');
              ad.dispose();
              _isInterstitialAdLoaded = false;
              _loadInterstitialAd(); // 次の広告をロード
              _proceedWithAnalysis(); // ★広告が閉じられた後に解析を続行
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              debugPrint('$ad onAdFailedToShowFullScreenContent: $error (during analysis flow).');
              ad.dispose();
              _isInterstitialAdLoaded = false;
              _loadInterstitialAd(); // 次の広告をロード
              _proceedWithAnalysis(); // ★表示失敗時も解析を続行
            },
          );
      await _interstitialAd!.show();
    } else {
      debugPrint('Interstitial ad not ready for analysis flow, proceeding with analysis directly.');
      _proceedWithAnalysis();
    }
  }

  // ユーザーが指定した領域を解析するためのプロンプト（調整が必要）
  String _generatePromptForRegion(List<String> selectedBrands /*, Rect imageRegion, Size originalImageSize */) {
    final brandListString = selectedBrands.map((b) => '- $b').join('\n');
    // 矩形が描画された画像を渡すため、座標のテキスト情報は削除
    String genreSpecificPromptPart;
    switch (_selectedGenre) {
      case SearchGenre.lifestyle:
        genreSpecificPromptPart = "提供された画像に赤い枠で示されている領域にある生活雑貨（家具、インテリア小物、キッチン用品、収納グッズなど）に似ている商品や、関連する商品を対象メーカーから探し出してください。";
        break;
      case SearchGenre.apparel:
        genreSpecificPromptPart = "提供された画像に赤い枠で示されている領域にある衣料品（トップス、ボトムス、アウター、ワンピース、ファッション小物など）に似ている商品や、関連する商品を対象メーカーから探し出してください。";
        break;
      case SearchGenre.outdoor:
        genreSpecificPromptPart = "提供された画像に赤い枠で示されている領域にあるアウトドア用品（テント、寝袋、ランタン、チェア、クーラーボックス、登山用品など）に似ている商品や、関連する商品を対象メーカーから探し出してください。";
        break;
      case SearchGenre.bag:
        genreSpecificPromptPart = "提供された画像に赤い枠で示されている領域にあるバッグ類（リュックサック、トートバッグ、ショルダーバッグ、ウエストポーチなど）に似ている商品や、関連する商品を対象メーカーから探し出してください。";
        break;
      case SearchGenre.sports:
        genreSpecificPromptPart = "提供された画像に赤い枠で示されている領域にあるスポーツ用品（ウェア、シューズ、ボール、ラケット、トレーニング器具など）に似ている商品や、関連する商品を対象メーカーから探し出してください。";
        break;
      case SearchGenre.sneakers:
        genreSpecificPromptPart = "提供された画像に赤い枠で示されている領域にあるスニーカーに似ている商品や、関連する商品を対象メーカーから探し出してください。";
        break;
    }

    return """
あなたは、画像から商品を特定する専門家です。
$genreSpecificPromptPart
赤い枠内の商品のみを対象とし、指定されたメーカーの製品を探してください。
特定する際は、サイズなど赤い枠外の情報も参考にしてください。
もっとも適切と思われる商品1つだけでいいですが、同じメーカーであれば複数でも構いません。

対象メーカー:
$brandListString

その商品一つ一つについて、以下の情報を厳密なJSON形式でリストとして返してください。
複数の商品が該当する場合は、それぞれの商品情報をリストに含めてください。

出力形式のルール:
- ルート要素は `products` というキーを持つJSON配列（リスト）とします。
- 配列の各要素は、一つの商品を表すJSONオブジェクトです。
- 各商品オブジェクトは、以下のキーを含みます:
  - `product_name`: 商品名を文字列で指定します。そのメーカーの呼称を使用してください。
  - `brand`: メーカー名（対象メーカーのいずれか）を文字列で指定します。
  - `size`: サイズ情報を格納するJSONオブジェクト（width, height, depthをcm単位の数値で、アパレルの場合はS/M/L/Freeや数値、バッグの場合は容量(L)や寸法、または該当しない場合は空オブジェクト {}）。
  - `description`: 商品の特徴や説明を文字列で指定します。
  - `product_url`: 商品の公式ページまたは販売ページのURLを文字列で指定します。不明な場合は空文字列 ""。
  - `bounding_box`: 商品が画像内で占める領域を示すバウンディングボックス情報（x1, y1, x2, y2を整数で）。**これは元画像全体における絶対座標で返してください。**
  - `emoji`: その商品を最もよく表す絵文字を1つ文字列で指定します。
- 画像内に該当する商品が一つも見つからなかった場合は、空の配列 `{"products": []}` を返してください。
- JSONの前後に、他の説明文や挨拶などを一切含めないでください。
""";
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frameInfo = await codec.getNextFrame();

      setState(() {
        _imageFile = File(pickedFile.path);
        _displayedUiImage?.dispose(); // 古い画像をdispose
        _displayedUiImage = frameInfo.image;
        _products = [];
        _errorMessage = null;
        _drawnRect = null; // 描画された矩形をリセット
        _panStartOffset = null;
        _panCurrentOffset = null;
      });
    }
  }

  Future<void> _resetImageSelection() async {
    setState(() {
      _imageFile = null;
      _displayedUiImage?.dispose();
      _displayedUiImage = null;
      _products = [];
      _errorMessage = null;
      _drawnRect = null;
      _panStartOffset = null;
      _panCurrentOffset = null;
    });
  }

  Future<Uint8List> _generateImageWithRectangle(ui.Image originalImage, Rect rectToDraw) async {
    final recorder = ui.PictureRecorder();
    // Canvasのコンストラクタには、描画範囲を示すcullRectを指定します。
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble()));

    // 元画像を描画
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble()),
      image: originalImage,
      fit: BoxFit.fill, // 元の画像のサイズで描画
    );

    // 矩形を描画
    final Paint rectPaint = Paint()
      ..color = Colors.red // AIが認識しやすい色
      ..style = PaintingStyle.stroke
      // 線の太さを画像の幅に応じて調整（例：画像の幅の0.5%、最小2px、最大10px）
      ..strokeWidth = (originalImage.width * 0.005).clamp(2.0, 10.0);

    final Paint fillPaint = Paint()
      ..color = Colors.red.withOpacity(0.1) // わずかに塗りつぶし
      ..style = PaintingStyle.fill;

    // rectToDrawは既に元画像のピクセル座標系に変換されているものを使用
    canvas.drawRect(rectToDraw, fillPaint);
    canvas.drawRect(rectToDraw, rectPaint);

    final picture = recorder.endRecording();
    // toImage には元画像のサイズを渡す
    final img = await picture.toImage(originalImage.width, originalImage.height);
    // PNG形式でバイトデータを取得（JPEGも可: ui.ImageByteFormat.jpeg）
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose(); // 生成したui.Imageをdispose

    if (byteData == null) {
      throw Exception("矩形付き画像のバイトデータ生成に失敗しました。");
    }
    return byteData.buffer.asUint8List();
  }

  Future<void> _analyzeMarkedRegion() async {
    if (_imageFile == null || _drawnRect == null || _displayedUiImage == null) {
      setState(() {
        _errorMessage = _imageFile == null
            ? 'まず画像を選択してください。'
            : '商品を囲んで指定してください。';
      });
      return;
    }

    // インタースティシャル広告を表示し、その後解析処理を呼び出す
    await _showInterstitialAdAndAnalyze();
  }

  // AI解析処理を実際に行う部分を別のメソッドに分離
  Future<void> _proceedWithAnalysis() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _products = [];
    });

    try {
      final activeBrands = _selectedBrands.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (activeBrands.isEmpty) {
        throw Exception('検索対象のメーカーを1つ以上選択してください。');
      }

      // CustomPaintのサイズを取得して座標変換
      final RenderBox? renderBox = _customPaintKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        throw Exception('描画エリアの情報を取得できませんでした。');
      }
      
      final Size painterSize = renderBox.size;
      final Size imageOriginalSize = Size(_displayedUiImage!.width.toDouble(), _displayedUiImage!.height.toDouble());
      
      // ローカル座標を元画像のピクセル座標に変換
      final Rect? regionInImagePixels = _convertLocalRectToImageRect(_drawnRect!, painterSize, imageOriginalSize);
      
      if (regionInImagePixels == null) {
        throw Exception('座標変換に失敗しました。');
      }

      // ★ 矩形付き画像を生成
      final Uint8List imageBytesWithRectangle = await _generateImageWithRectangle(_displayedUiImage!, regionInImagePixels);

      // 生成された矩形付き画像を表示する（確認用）
      if (mounted) {
        final bool? continueAnalysis = await showDialog<bool>(
          context: context,
          barrierDismissible: false, // ダイアログ外タップで閉じないようにする
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              content: SingleChildScrollView( // 画像が大きい場合にスクロール可能にする
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.memory(imageBytesWithRectangle)),
                    const SizedBox(height: 10),
              Text('${BrandData.getGenreDisplayName(_selectedGenre)}', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)), // ★ 変更
                    const Text("AI解析を実行しますか？",
                      style: TextStyle(fontSize: 16,),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('キャンセル',style: TextStyle(color: Colors.black54,fontSize: 14),),
                  
                  onPressed: () {
                    Navigator.of(context).pop(false); // 解析をキャンセル
                  },
                ),
                TextButton(
                  child: const Text('OK',style: TextStyle(color: Colors.red,fontSize: 18),),
                  onPressed: () {
                    Navigator.of(context).pop(true); // 解析を続行
                  },
                ),
              ],
            );
          },
        );

        // ユーザーがキャンセルした場合、またはダイアログが予期せず閉じられた場合
        if (continueAnalysis == null || !continueAnalysis) {
          setState(() {
            _isLoading = false;
          });
          return; // 解析処理を中断
        }
      }


      final prompt = _generatePromptForRegion(
        activeBrands,
        // imageRegion, // プロンプトから座標指定を削除したため不要
        // imageOriginalSize, // プロンプトから座標指定を削除したため不要
      );

      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null) {
        throw Exception('APIキーが設定されていません。');
      }

      final model = GenerativeModel(model: 'gemini-2.0-flash-lite', apiKey: apiKey);
      // final Uint8List imageBytes = await _imageFile!.readAsBytes(); // 元の画像バイトは使用しない
      final imagePart = DataPart('image/png', imageBytesWithRectangle); // ★ 矩形付き画像バイトに変更
      final response = await model.generateContent([
        Content.multi([TextPart(prompt), imagePart])
      ]);

      List<Product> products = [];
      String? errorMessage;

      if (response.text != null) {
        final cleanedJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        final decodedJson = jsonDecode(cleanedJson);
        final List<dynamic> productListJson = decodedJson['products'];
        products = productListJson.map((itemJson) => Product.fromJson(itemJson as Map<String, dynamic>)).toList();
      } else {
         errorMessage = 'APIから有効なレスポンスがありませんでした。';
      }

      setState(() {
        _products = products;
        _errorMessage = errorMessage;
      });

      if (mounted && (_products.isNotEmpty || _errorMessage != null)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              products: _products,
              errorMessage: _errorMessage,
              selectedBrands: _selectedBrands,
              brandTopPageUrls: BrandData.brandTopPageUrls, // ★ 変更
              fetchSimilarProductsApiCallback: _fetchSimilarProductsApi,
              originalImageFile: _imageFile,
              selectedGenre: _selectedGenre, // ★★★ 追加 ★★★
            ),
          ),
        );
      } else if (mounted && _products.isEmpty && _errorMessage == null) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('指定された領域に該当する商品が見つかりませんでした。')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'エラーが発生しました: ${e.toString()}';
      });
       if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              products: [],
              errorMessage: _errorMessage,
              selectedBrands: _selectedBrands,
              brandTopPageUrls: BrandData.brandTopPageUrls, // ★ 変更
              fetchSimilarProductsApiCallback: _fetchSimilarProductsApi,
              originalImageFile: _imageFile,
              selectedGenre: _selectedGenre, // ★★★ 追加 ★★★
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Rect _convertLocalRectToImageRect(
  Rect localRect,
  Size displayedSize,
  Size originalImageSize,
) {
  // 表示サイズ → 実画像サイズ へのスケール
  final scaleX = originalImageSize.width  / displayedSize.width;
  final scaleY = originalImageSize.height / displayedSize.height;
  return Rect.fromLTRB(
    localRect.left   * scaleX,
    localRect.top    * scaleY,
    localRect.right  * scaleX,
    localRect.bottom * scaleY,
  );
}

  Future<List<Product>> _fetchSimilarProductsApi(Product originalProduct, List<String> selectedBrands) async {
    // ... (既存の _fetchSimilarProductsApi の実装)
    final prompt = _generateSimilarProductPrompt(originalProduct, selectedBrands);
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('APIキーが設定されていません。');
    }
    final model = GenerativeModel(model: 'gemini-2.0-flash-lite', apiKey: apiKey);
    final response = await model.generateContent([Content.text(prompt)]);
    if (response.text != null) {
      final cleanedJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
      if (cleanedJson.isEmpty) return [];
      try {
        final decodedJson = jsonDecode(cleanedJson);
        final dynamic productsData = decodedJson['products'];
        if (productsData is List) {
          return productsData.map((itemJson) {
            final Map<String, dynamic> item = itemJson as Map<String, dynamic>;
            String productUrl = item['product_url'] as String? ?? '';
            final String brand = item['brand'] as String? ?? '';
            if (productUrl.isEmpty && brand.isNotEmpty && BrandData.brandTopPageUrls.containsKey(brand)) { // ★ 変更
              productUrl = BrandData.brandTopPageUrls[brand]!; // ★ 変更
            }
            final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(item);
            updatedItem['product_url'] = productUrl;
            return Product.fromJson(updatedItem);
          }).toList();
        } else {
          return [];
        }
      } catch (e) {
        throw Exception('類似商品のレスポンスJSONの解析に失敗しました。');
      }
    } else {
      throw Exception('APIから類似商品の有効なレスポンスがありませんでした。');
    }
  }
    // _generateSimilarProductPrompt は変更なし
  String _generateSimilarProductPrompt(Product originalProduct, List<String> selectedBrands) {
    final brandListString = selectedBrands.map((b) => '- $b').join('\n');
    String genreSpecificPromptPart;
    String sizeInfo;

    switch (_selectedGenre) {
      case SearchGenre.lifestyle:
        genreSpecificPromptPart = "以下の生活雑貨（家具、インテリア小物、キッチン用品、収納グッズなど）の情報と、指定されたメーカーのリストに基づいて、類似商品を提案してください。";
        sizeInfo = (originalProduct.size.width! > 0 && originalProduct.size.height! > 0)
            ? "- サイズ: 幅${originalProduct.size.width}cm x 高さ${originalProduct.size.height}cm x 奥行き${originalProduct.size.depth}cm"
            : (originalProduct.size.width! > 0 || originalProduct.size.height! > 0 || originalProduct.size.depth! > 0)
                ? "- サイズ: ${originalProduct.size.toString()}"
                : "- サイズ: 情報なし";
        break;
      case SearchGenre.apparel:
        genreSpecificPromptPart = "以下の衣料品（トップス、ボトムス、アウター、ワンピース、ファッション小物など）の情報と、指定されたメーカーのリストに基づいて、類似商品を提案してください。";
        sizeInfo = originalProduct.size.apparelSize != null && originalProduct.size.apparelSize!.isNotEmpty
            ? "- サイズ: ${originalProduct.size.apparelSize}"
            : (originalProduct.size.width! > 0 || originalProduct.size.height! > 0 || originalProduct.size.depth! > 0)
                ? "- サイズ: ${originalProduct.size.toString()}" // フォールバックとして
                : "- サイズ: 情報なし";
        break;
      case SearchGenre.outdoor:
        genreSpecificPromptPart = "以下のアウトドア用品（テント、寝袋、ランタン、チェア、クーラーボックス、登山用品など）の情報と、指定されたメーカーのリストに基づいて、類似商品を提案してください。";
        // アウトドア用品のサイズ情報は多様なので、descriptionに含めるか、専用のフィールドをProductSizeに追加することを検討
        sizeInfo = (originalProduct.size.width! > 0 && originalProduct.size.height! > 0) // 例: テントや大型ギア
            ? "- サイズ: 幅${originalProduct.size.width}cm x 高さ${originalProduct.size.height}cm x 奥行き${originalProduct.size.depth}cm"
            : (originalProduct.size.volume != null && originalProduct.size.volume! > 0) // 例: バックパックの容量
                ? "- 容量: ${originalProduct.size.volume}L"
                : "- サイズ: ${originalProduct.description.contains('サイズ') ? '商品説明参照' : '情報なし'}"; // descriptionにサイズ情報があれば参照
        break;
      case SearchGenre.bag:
        genreSpecificPromptPart = "以下のバッグ類（リュックサック、トートバッグ、ショルダーバッグ、ウエストポーチなど）の情報と、指定されたメーカーのリストに基づいて、類似商品を提案してください。";
        sizeInfo = (originalProduct.size.volume != null && originalProduct.size.volume! > 0)
            ? "- 容量: ${originalProduct.size.volume}L"
            : (originalProduct.size.width! > 0 && originalProduct.size.height! > 0)
                ? "- サイズ: 幅${originalProduct.size.width}cm x 高さ${originalProduct.size.height}cm x 奥行き${originalProduct.size.depth}cm"
                : "- サイズ: 情報なし";
        break;
      case SearchGenre.sports:
        genreSpecificPromptPart = "以下のスポーツ用品（ウェア、シューズ、ボール、ラケット、トレーニング器具など）の情報と、指定されたメーカーのリストに基づいて、類似商品を提案してください。";
        // スポーツ用品のサイズは多岐にわたるため、ウェアならapparelSize、シューズなら数値、用具なら寸法など
        sizeInfo = originalProduct.size.apparelSize != null && originalProduct.size.apparelSize!.isNotEmpty
            ? "- サイズ: ${originalProduct.size.apparelSize}" // ウェアの場合
            : (originalProduct.size.width! > 0 && originalProduct.size.height! > 0) // シューズや用具の寸法
                ? "- サイズ: 幅${originalProduct.size.width}cm x 高さ${originalProduct.size.height}cm x 奥行き${originalProduct.size.depth}cm"
                : (originalProduct.size.volume != null && originalProduct.size.volume! > 0) // ボールなどの容量や、特定の数値サイズ
                    ? "- サイズ/容量: ${originalProduct.size.volume}" // volumeを汎用的な数値サイズとしても使う
                    : "- サイズ: 情報なし";
        break;
      case SearchGenre.sneakers:
        genreSpecificPromptPart = "以下のスニーカーの情報と、指定されたメーカーのリストに基づいて、類似商品を提案してください。";
        // スニーカーのサイズは数値 (cm or US/UK/EU size)
        sizeInfo = (originalProduct.size.width! > 0) // width を靴のサイズとして代用 (cm)
            ? "- サイズ: ${originalProduct.size.width}cm"
            : (originalProduct.size.apparelSize != null && originalProduct.size.apparelSize!.isNotEmpty) // apparel_size をUS/UK/EUサイズとして代用
                ? "- サイズ: ${originalProduct.size.apparelSize}"
                : "- サイズ: 情報なし";
        break;
    }


    return """
あなたは、家具や雑貨、アパレル、アウトドア用品、バッグの類似商品を提案する専門家です。
$genreSpecificPromptPart

元の商品情報:
- 商品名: ${originalProduct.productName}
- ブランド: ${originalProduct.brand}
- 説明: ${originalProduct.description}
$sizeInfo

検索対象メーカー:
$brandListString

類似商品を、その商品一つ一つについて、以下の情報を厳密なJSON形式でリストとして返してください。
複数の商品が該当する場合は、それぞれの商品情報をリストに含めてください。
各メーカー1件ずつ提案してください。


出力形式のルール:
- ルート要素は `products` というキーを持つJSON配列（リスト）とします。
- 配列の各要素は、一つの商品を表すJSONオブジェクトです。
- 各商品オブジェクトは、以下のキーを含みます:
  - `product_name`: 商品名を文字列で指定します。
  - `brand`: メーカー名（検索対象メーカーのいずれか）を文字列で指定します。
  - `size`: サイズ情報を格納するJSONオブジェクトです（生活雑貨の場合はwidth, height, depthをcm単位の数値で、アパレルの場合はS/M/L/Freeや数値、アウトドア用品やバッグの場合は容量(L)や寸法、または該当しない場合は空オブジェクト {}）。
    - `width`: 横幅をcm単位の数値で指定します。(該当しなければ 0 または省略)
    - `height`: 高さをcm単位の数値で指定します。(該当しなければ 0 または省略)
    - `depth`: 奥行きをcm単位の数値で指定します。(該当しなければ 0 または省略)
    - `apparel_size`: (アパレルの場合) S/M/L/Freeなどの文字列、または数値。該当しない場合は省略可。
    - `volume`: (バッグや一部アウトドア用品の場合) 容量をL(リットル)単位の数値で指定します。該当しない場合は省略可。
  - `description`: 商品の特徴や説明を文字列で指定します。
  - `product_url`: 商品の公式ページまたは販売ページのURLを文字列で指定します。不明な場合は空文字列 "" としてください。
  - `emoji`: その商品を最もよく表す絵文字を1つ文字列で指定します。例: "🛋️", "👕", "⛺", "🎒", "⚽", "👟"。適切な絵文字が見つからない場合は空文字列 "" としてください。
- 該当する類似商品が一つも見つからなかった場合は、空の配列 `{"products": []}` を返してください。
- JSONの前後に、他の説明文や挨拶などを一切含めないでください。
""";
  }


  @override
  Widget build(BuildContext context) {
    final Color darkPrimaryColor = const Color.fromARGB(255, 193, 115, 196)!;
    final Color darkBackgroundColor = Colors.grey[900]!;
    final Color darkCardColor = Colors.grey[850]!.withOpacity(0.9);

    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('ニタモノ検索', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black54,
                       Colors.grey[800]!
                       ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: _isDrawing 
                        ? const NeverScrollableScrollPhysics() 
                        : const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: CrossAxisAlignment.stretch,
                       children: <Widget>[
                        const SizedBox(height: 20),
                        if (_imageFile == null) ...[
                          // 画像選択前の表示
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[600]!, width: 2, style: BorderStyle.solid),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined, size: 80, color: Colors.grey[500]),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.image_search),
                                    label: const Text('画像を選択'),
                                    onPressed: () => _showImageSourceDialog(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: darkPrimaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                                      textStyle: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          // 画像選択後の表示
                          Text(
                            '画像をドラッグして特定する商品を囲んでください。先に横方向にドラッグする必要があります。',
                            style: TextStyle(color: Colors.grey[300], fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          
                          // 画像表示エリア
                          if (_displayedUiImage != null)
                            AspectRatio(
                              aspectRatio: _displayedUiImage!.width / _displayedUiImage!.height,
                              child: LayoutBuilder(builder: (context, cons) {
                                final imageAspect = _displayedUiImage!.width / _displayedUiImage!.height;
                                final widgetAspect = cons.maxWidth / cons.maxHeight;
                                double dispW, dispH;
                                if (widgetAspect > imageAspect) {
                                  dispH = cons.maxHeight;
                                  dispW = dispH * imageAspect;
                                } else {
                                  dispW = cons.maxWidth;
                                  dispH = dispW / imageAspect;
                                }
                                final offsetX = (cons.maxWidth - dispW) / 2;
                                final offsetY = (cons.maxHeight - dispH) / 2;

                                return Padding(
                                  padding: EdgeInsets.only(left: offsetX, top: offsetY),
                                  child: SizedBox(
                                    width: dispW,
                                    height: dispH,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      dragStartBehavior: DragStartBehavior.down, // この行を追加
                                      onPanStart: (d) {
                                        setState(() {
                                          _isDrawing = true;
                                          _panStartOffset = d.localPosition;
                                          _panCurrentOffset = d.localPosition;
                                        });
                                      },
                                      onPanUpdate: (d) {
                                        setState(() {
                                          _panCurrentOffset = d.localPosition;
                                          _drawnRect = Rect.fromPoints(
                                            _panStartOffset!, _panCurrentOffset!);
                                        });
                                      },
                                      onPanEnd: (_) {
                                        setState(() {
                                          _isDrawing = false;          // 追加
                                          _drawnRect = Rect.fromLTRB(
                                            min(_panStartOffset!.dx, _panCurrentOffset!.dx),
                                            min(_panStartOffset!.dy, _panCurrentOffset!.dy),
                                            max(_panStartOffset!.dx, _panCurrentOffset!.dx),
                                            max(_panStartOffset!.dy, _panCurrentOffset!.dy),
                                          );
                                          _panStartOffset = _panCurrentOffset = null;
                                        });
                                      },
                                      onPanCancel: () {
                                        setState(() {
                                          _isDrawing = false;          // 追加
                                          _panStartOffset = _panCurrentOffset = null;
                                        });
                                      },
                                      child: ClipRRect( // ClipRRectでラップ
                                        borderRadius: BorderRadius.circular(24.0), // 角丸の半径を指定
                                        child: CustomPaint(
                                          key: _customPaintKey,
                                          painter: ImageDrawingPainter(
                                            image: _displayedUiImage!,
                                            rectToDraw: _drawnRect,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                                }),
                            ),
                          
                          const SizedBox(height: 15),
                          
                          // 選択範囲の情報表示
                          if (_drawnRect != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[800]!.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '選択範囲: 左${_drawnRect!.left.toInt()}, 上${_drawnRect!.top.toInt()}, 幅${_drawnRect!.width.toInt()}, 高さ${_drawnRect!.height.toInt()}',
                                style: TextStyle(color: Colors.grey[300], fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          
                          const SizedBox(height: 15),
                          
                          // ボタン類
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('画像をクリア'),
                                  onPressed: _resetImageSelection,
                                  style: ElevatedButton.styleFrom(

                                    backgroundColor: Colors.grey[700],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.science_outlined),
                                  label: const Text('AIで商品を特定'),
                                  onPressed: (_isLoading || _drawnRect == null) ? null : _analyzeMarkedRegion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: (_drawnRect != null) ? darkPrimaryColor : Colors.grey[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        const SizedBox(height: 30),
                        
                        // ジャンル選択エリア
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: Colors.white24, width: 0.5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '検索ジャンル:',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: SearchGenre.values.map((genre) { // ★ SearchGenre.valuesから動的に生成
                                    bool isSelected = _selectedGenre == genre;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: ChoiceChip(
                                        label: Text(BrandData.getGenreDisplayName(genre)), // ★ 表示名を取得
                                        selected: isSelected,
                                        onSelected: (bool selected) {
                                          if (selected) {
                                            _updateBrandSelectionForGenre(genre);
                                          }
                                        },
                                        backgroundColor: Colors.grey[800],
                                        selectedColor: Colors.white.withOpacity(0.2),
                                        labelStyle: TextStyle(
                                          color: isSelected ? Colors.black : Colors.white,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                          side: BorderSide(
                                            color: isSelected ? Colors.transparent : Colors.transparent,
                                            width: 1.5,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20), // ★ パディングを調整
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // ブランド選択エリア
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24, width: .5, style: BorderStyle.solid),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '検索対象メーカー (${BrandData.getGenreDisplayName(_selectedGenre)}):', // ★ 変更
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildBrandSelection(),
                            ],
                          ),
                        ),
                        
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 100), // 広告のためのスペース
                       ],
                      ),
                    ),
                  ),
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(darkPrimaryColor)),
                    const SizedBox(height: 20),
                    Text('AIが画像を解析中です...', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('画像ソースを選択'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('ギャラリーから選択'),
                  ),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                GestureDetector(
                  child: const ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('カメラで撮影'),
                  ),
                  onTap: () {
                    _pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandSelection() {
    final Color darkPrimaryColor = Colors.transparent;
    final Color darkChipSelectedColor = darkPrimaryColor.withOpacity(0.7); // 選択されているチップの背景色
    final Color darkChipSelectedLabelColor = Colors.black; // 選択されているチップのラベル色
    final Color darkChipSelectedBorderColor = darkPrimaryColor; // 選択されているチップの枠線色

    if (_currentAvailableBrands.isEmpty) {
      return Text('このジャンルには登録されているブランドがありません。', style: TextStyle(color: Colors.grey[400]));
    }

    return Wrap(
      spacing: 5.0,
      runSpacing: .0,
      children: _currentAvailableBrands.map((brand) {
        // 常に選択状態なので、selectedは常にtrue
        bool isSelected = true; 

        return AbsorbPointer( // タップイベントを吸収して操作不可にする
          absorbing: true, // trueで操作不可
          child: FilterChip(
            label: Text(
              brand,
              style: TextStyle(
                color: Colors.white, // 常に選択状態のラベル色
              ),
            ),
            selected: isSelected,
            onSelected: null, // 操作できないようにnullを設定
            backgroundColor: Colors.grey[800], // 非選択時の背景色は使用されないが念のため
            selectedColor: darkChipSelectedColor, // 常に選択状態の背景色
            checkmarkColor: Colors.transparent, // チェックマークは不要なので透明に
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: darkChipSelectedBorderColor, // 常に選択状態の枠線色
                width: 1.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// 画像と矩形を描画するためのCustomPainter
class ImageDrawingPainter extends CustomPainter {
  final ui.Image image;
  final Rect? rectToDraw;
  final Offset? currentPanStart;
  final Offset? currentPanEnd;

  ImageDrawingPainter({
    required this.image,
    this.rectToDraw,
    this.currentPanStart,
    this.currentPanEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 画像をCustomPaintの領域に合わせて描画 (アスペクト比を維持、中央揃え)
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      image: image,
      fit: BoxFit.contain,
      alignment: Alignment.center,
    );

    final Paint rectPaint = Paint()
      ..color = Colors.red.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Paint fillPaint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // 確定した矩形を描画
    if (rectToDraw != null) {
      canvas.drawRect(rectToDraw!, fillPaint);
      canvas.drawRect(rectToDraw!, rectPaint);
    }

    // 描画中の矩形をフィードバックとして描画
    if (currentPanStart != null && currentPanEnd != null) {
      final Paint drawingFeedbackPaint = Paint()
        ..color = Colors.blue.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      final Paint drawingFeedbackFillPaint = Paint()
        ..color = Colors.blue.withOpacity(0.1)
        ..style = PaintingStyle.fill;
      
      final Rect drawingRect = Rect.fromPoints(currentPanStart!, currentPanEnd!);
      canvas.drawRect(drawingRect, drawingFeedbackFillPaint);
      canvas.drawRect(drawingRect, drawingFeedbackPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ImageDrawingPainter oldDelegate) {
    return oldDelegate.image != image ||
           oldDelegate.rectToDraw != rectToDraw ||
           oldDelegate.currentPanStart != currentPanStart ||
           oldDelegate.currentPanEnd != currentPanEnd;
  }
}
