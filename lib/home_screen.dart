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

enum SearchGenre { lifestyle, apparel, outdoor, bag, sports, sneakers }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  final List<String> _availableLifestyleBrands = ['無印良品', 'イケア', 'ニトリ','seria','Francfranc','LOWYA','ベルメゾン','LOFT','東急ハンズ'];
  final List<String> _availableApparelBrands = ['ユニクロ', 'GU', 'ZARA', 'H&M', 'BEAMS', 'しまむら', 'Right-on', 'GAP', 'アーバンリサーチ', 'ユナイテッドアローズ', 'ナノユニバース', 'ジャーナルスタンダード']; // アパレルブランドの例
  final List<String> _availableOutdoorBrands = [
    'コールマン', 'スノーピーク', 'ロゴス', 'モンベル', 'パタゴニア', 'ザ・ノース・フェイス',
    'キャプテンスタッグ', 'DOD', 'ヘリノックス', 'チャムス', 'マムート', 'ミレー'
  ]; // アウトドアブランドの例
  final List<String> _availableBagBrands = [
    'ポーター', 'マンハッタンポーテージ', 'グレゴリー', 'アークテリクス', 'ミステリーランチ',
    'ケルティ', 'オスプレー', 'カリマー', 'ブリーフィング', 'トゥミ'
  ]; // バッグブランドの例
  final List<String> _availableSportsBrands = [
    'ナイキ', 'アディダス', 'プーマ', 'アシックス', 'ミズノ',
    'アンダーアーマー', 'ニューバランス', 'デサント', 'ルコックスポルティフ', 'ヨネックス'
  ]; // スポーツブランドの例
  final List<String> _availableSneakersBrands = [
    'ナイキ', 'アディダス', 'ニューバランス', 'コンバース', 'バンズ',
    'リーボック', 'プーマ', 'アシックス', 'オニツカタイガー', 'サッカニー'
  ]; // スニーカーブランドの例
  late List<String> _currentAvailableBrands; // 現在選択中のジャンルのブランドリスト
  late Map<String, bool> _selectedBrands;

  final Map<String, String> _brandTopPageUrls = {
    // 生活雑貨
    '無印良品': 'https://www.muji.com/jp/ja/store',
    'イケア': 'https://www.ikea.com/jp/ja/',
    'ニトリ': 'https://www.nitori-net.jp/ec/',
    'seria': 'https://www.seria-group.com/',
    'Francfranc': 'https://francfranc.com/',
    'LOWYA': 'https://www.low-ya.com/',
    'ベルメゾン': 'https://www.bellemaison.jp/',
    'LOFT': 'https://www.loft.co.jp/store/',
    '東急ハンズ': 'https://hands.net/',
    // アパレル
    'ユニクロ': 'https://www.uniqlo.com/jp/ja/',
    'GU': 'https://www.gu-global.com/jp/ja/',
    'ZARA': 'https://www.zara.com/jp/',
    'H&M': 'https://www2.hm.com/ja_jp/index.html',
    'BEAMS': 'https://www.beams.co.jp/',
    'しまむら': 'https://www.shimamura.gr.jp/shimamura/',
    'Right-on': 'https://right-on.co.jp/',
    'GAP': 'https://www.gap.co.jp/',
    'アーバンリサーチ': 'https://www.urban-research.jp/',
    'ユナイテッドアローズ': 'https://store.united-arrows.co.jp/',
    'ナノユニバース': 'https://store.nanouniverse.jp/',
    'ジャーナルスタンダード': 'https://baycrews.jp/brand/detail/journalstandard',
    // アウトドア
    'コールマン': 'https://www.coleman.co.jp/',
    'スノーピーク': 'https://www.snowpeak.co.jp/',
    'ロゴス': 'https://www.logos.ne.jp/',
    'モンベル': 'https://www.montbell.jp/',
    'パタゴニア': 'https://www.patagonia.jp/',
    'ザ・ノース・フェイス': 'https://www.goldwin.co.jp/tnf/',
    'キャプテンスタッグ': 'https://www.captainstag.net/',
    'DOD': 'https://www.dod.camp/',
    'ヘリノックス': 'https://www.helinox.jp/',
    'チャムス': 'https://www.chums.jp/',
    'マムート': 'https://www.mammut.jp/',
    'ミレー': 'https://www.millet.jp/',
    // バッグ
    'ポーター': 'https://www.yoshidakaban.com/product/search_result.html?p_series=&p_lisence_id=1&p_keywd=', // PORTER (吉田カバン)
    'マンハッタンポーテージ': 'https://www.manhattanportage.co.jp/',
    'グレゴリー': 'https://www.gregory.jp/',
    'アークテリクス': 'https://arcteryx.jp/',
    'ミステリーランチ': 'https://www.mysteryranch.jp/',
    'ケルティ': 'https://www.kelty.co.jp/',
    'オスプレー': 'https://www.osprey.com/jp/ja/',
    'カリマー': 'https://www.karrimor.jp/',
    'ブリーフィング': 'https://www.briefing-usa.com/',
    'トゥミ': 'https://www.tumi.co.jp/',
    // スポーツ
    'ナイキ': 'https://www.nike.com/jp/',
    'アディダス': 'https://shop.adidas.jp/',
    'プーマ': 'https://jp.puma.com/',
    'アシックス': 'https://www.asics.com/jp/ja-jp/',
    'ミズノ': 'https://jpn.mizuno.com/',
    'アンダーアーマー': 'https://www.underarmour.co.jp/',
    'ニューバランス': 'https://shop.newbalance.jp/',
    'デサント': 'https://store.descente.co.jp/',
    'ルコックスポルティフ': 'https://store.descente.co.jp/lecoqsportif/',
    'ヨネックス': 'https://www.yonex.co.jp/',
    // スニーカー
    'コンバース': 'https://converse.co.jp/',
    'バンズ': 'https://www.vans.co.jp/',
    'リーボック': 'https://reebok.jp/',
    'オニツカタイガー': 'https://www.onitsukatiger.com/jp/ja-jp/',
    'サッカニー': 'https://www.saucony-japan.com/',
    // ナイキ、アディダス、ニューバランス、プーマ、アシックスはスポーツと重複するため、URLは共通
  };

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  final String _bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7148683667182672/9797170752' // AndroidのテストID
      : 'ca-app-pub-7148683667182672/3020009417'; // iOSのテストID

  @override
  void initState() {
    super.initState();
    _updateBrandSelectionForGenre(_selectedGenre);
    _loadBannerAd();
  }

  void _updateBrandSelectionForGenre(SearchGenre genre) {
    setState(() {
      _selectedGenre = genre;
      if (_selectedGenre == SearchGenre.lifestyle) {
        _currentAvailableBrands = List.from(_availableLifestyleBrands);
      } else if (_selectedGenre == SearchGenre.apparel) {
        _currentAvailableBrands = List.from(_availableApparelBrands);
      } else if (_selectedGenre == SearchGenre.outdoor) {
        _currentAvailableBrands = List.from(_availableOutdoorBrands);
      } else if (_selectedGenre == SearchGenre.bag) {
        _currentAvailableBrands = List.from(_availableBagBrands);
      } else if (_selectedGenre == SearchGenre.sports) {
        _currentAvailableBrands = List.from(_availableSportsBrands);
      } else if (_selectedGenre == SearchGenre.sneakers) {
        _currentAvailableBrands = List.from(_availableSneakersBrands);
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

  @override
  void dispose() {
    _bannerAd?.dispose();
    _displayedUiImage?.dispose(); // ui.Imageをdispose
    super.dispose();
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
              title: const Text('AIに送信する画像'),
              content: SingleChildScrollView( // 画像が大きい場合にスクロール可能にする
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.memory(imageBytesWithRectangle),
                    const SizedBox(height: 10),
                    const Text("この画像でAI解析を実行しますか？"),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('キャンセル'),
                  onPressed: () {
                    Navigator.of(context).pop(false); // 解析をキャンセル
                  },
                ),
                TextButton(
                  child: const Text('OK'),
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
              brandTopPageUrls: _brandTopPageUrls,
              fetchSimilarProductsApiCallback: _fetchSimilarProductsApi,
              originalImageFile: _imageFile,
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
              brandTopPageUrls: _brandTopPageUrls,
              fetchSimilarProductsApiCallback: _fetchSimilarProductsApi,
              originalImageFile: _imageFile,
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
            if (productUrl.isEmpty && brand.isNotEmpty && _brandTopPageUrls.containsKey(brand)) {
              productUrl = _brandTopPageUrls[brand]!;
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
        backgroundColor: Colors.grey[850],
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
                      colors: [darkBackgroundColor, Colors.grey[850]!],
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
                            '商品をタッチして囲んでください:',
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
                                      child: CustomPaint(
                                        key: _customPaintKey,
                                        painter: ImageDrawingPainter(
                                          image: _displayedUiImage!,
                                          rectToDraw: _drawnRect,
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
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: darkCardColor,
                            borderRadius: BorderRadius.circular(12),
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
                              Wrap( // Rowの代わりにWrapを使用して、画面幅に応じて折り返すようにする
                                spacing: 8.0, // 各チップ間の水平スペース
                                runSpacing: 8.0, // 行間の垂直スペース
                                children: [
                                  ChoiceChip(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                    label: Text('生活雑貨', style: TextStyle(color: _selectedGenre == SearchGenre.lifestyle ? Colors.black : Colors.grey[300])),
                                    selected: _selectedGenre == SearchGenre.lifestyle,
                                    onSelected: (selected) {
                                      if (selected) _updateBrandSelectionForGenre(SearchGenre.lifestyle);
                                    },
                                    selectedColor: darkPrimaryColor.withOpacity(0.7),
                                    backgroundColor: Colors.grey[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: BorderSide(color: _selectedGenre == SearchGenre.lifestyle ? darkPrimaryColor : Colors.grey[700]!),
                                    ),
                                  ),
                                  ChoiceChip(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                    label: Text('アパレル', style: TextStyle(color: _selectedGenre == SearchGenre.apparel ? Colors.black : Colors.grey[300])),
                                    selected: _selectedGenre == SearchGenre.apparel,
                                    onSelected: (selected) {
                                      if (selected) _updateBrandSelectionForGenre(SearchGenre.apparel);
                                    },
                                    selectedColor: darkPrimaryColor.withOpacity(0.7),
                                    backgroundColor: Colors.grey[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: BorderSide(color: _selectedGenre == SearchGenre.apparel ? darkPrimaryColor : Colors.grey[700]!),
                                    ),
                                  ),
                                  ChoiceChip(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                    label: Text('アウトドア', style: TextStyle(color: _selectedGenre == SearchGenre.outdoor ? Colors.black : Colors.grey[300])),
                                    selected: _selectedGenre == SearchGenre.outdoor,
                                    onSelected: (selected) {
                                      if (selected) _updateBrandSelectionForGenre(SearchGenre.outdoor);
                                    },
                                    selectedColor: darkPrimaryColor.withOpacity(0.7),
                                    backgroundColor: Colors.grey[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: BorderSide(color: _selectedGenre == SearchGenre.outdoor ? darkPrimaryColor : Colors.grey[700]!),
                                    ),
                                  ),
                                  ChoiceChip(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                    label: Text('バッグ', style: TextStyle(color: _selectedGenre == SearchGenre.bag ? Colors.black : Colors.grey[300])),
                                    selected: _selectedGenre == SearchGenre.bag,
                                    onSelected: (selected) {
                                      if (selected) _updateBrandSelectionForGenre(SearchGenre.bag);
                                    },
                                    selectedColor: darkPrimaryColor.withOpacity(0.7),
                                    backgroundColor: Colors.grey[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: BorderSide(color: _selectedGenre == SearchGenre.bag ? darkPrimaryColor : Colors.grey[700]!),
                                    ),
                                  ),
                                  ChoiceChip(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                    label: Text('スポーツ', style: TextStyle(color: _selectedGenre == SearchGenre.sports ? Colors.black : Colors.grey[300])),
                                    selected: _selectedGenre == SearchGenre.sports,
                                    onSelected: (selected) {
                                      if (selected) _updateBrandSelectionForGenre(SearchGenre.sports);
                                    },
                                    selectedColor: darkPrimaryColor.withOpacity(0.7),
                                    backgroundColor: Colors.grey[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: BorderSide(color: _selectedGenre == SearchGenre.sports ? darkPrimaryColor : Colors.grey[700]!),
                                    ),
                                  ),
                                  ChoiceChip(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                    label: Text('スニーカー', style: TextStyle(color: _selectedGenre == SearchGenre.sneakers ? Colors.black : Colors.grey[300])),
                                    selected: _selectedGenre == SearchGenre.sneakers,
                                    onSelected: (selected) {
                                      if (selected) _updateBrandSelectionForGenre(SearchGenre.sneakers);
                                    },
                                    selectedColor: darkPrimaryColor.withOpacity(0.7),
                                    backgroundColor: Colors.grey[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: BorderSide(color: _selectedGenre == SearchGenre.sneakers ? darkPrimaryColor : Colors.grey[700]!),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // ブランド選択エリア
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: darkCardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '検索対象メーカー (${_getGenreDisplayName(_selectedGenre)}):',
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

// Helper function to get display name for genre
String _getGenreDisplayName(SearchGenre genre) {
  switch (genre) {
    case SearchGenre.lifestyle:
      return "生活雑貨";
    case SearchGenre.apparel:
      return "アパレル";
    case SearchGenre.outdoor:
      return "アウトドア";
    case SearchGenre.bag:
      return "バッグ";
    case SearchGenre.sports:
      return "スポーツ";
    case SearchGenre.sneakers:
      return "スニーカー";
    default:
      return "";
  }
}