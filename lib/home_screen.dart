// lib/screens/home_screen.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart'; // 追加
import 'procuctmodel.dart';

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

  @override
  void initState() {
    super.initState();
    // 初期状態で全てのメーカーを選択状態にする
    _selectedBrands = {for (var brand in _availableBrands) brand: true};
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
最大3つの類似商品を提案してください。

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

      if (response.text != null) {
        final cleanedJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        final decodedJson = jsonDecode(cleanedJson);
        final List<dynamic> productListJson = decodedJson['products'];
        
        setState(() {
          _products = productListJson.map((itemJson) {
            final Map<String, dynamic> item = itemJson as Map<String, dynamic>;
            // product_urlの処理はボトムシート内の類似商品検索でも同様に必要
            return Product.fromJson(item);
          }).toList();
        });
      } else {
         throw Exception('APIから有効なレスポンスがありませんでした。');
      }

    } catch (e) {
      setState(() {
        _errorMessage = 'エラーが発生しました: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  void _showSimilarProductsBottomSheet(BuildContext context, Product originalProduct) {
    // 状態変数を StatefulBuilder の外に移動
    bool isLoadingSimilar = true;
    List<Product> similarProducts = [];
    String? errorSimilarMessage;
    bool initialLoadStarted = false; // 初回ロードが開始されたかを追跡するフラグ

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 内容が多くなる可能性があるのでtrue
      builder: (BuildContext sheetContext) {
        // loadSimilarProducts 関数も StatefulBuilder の外に移動するか、
        // StatefulBuilder の中で定義し、外の変数をキャプチャするようにする。
        // ここでは StatefulBuilder の中で定義し、外の変数を更新するようにします。

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            // この builder が呼ばれるたびに loadSimilarProducts が再定義されるが、
            // 中で参照する isLoadingSimilar などは外側のスコープのものになる。

            Future<void> loadSimilarProducts() async {
              // isLoadingSimilar は外側のスコープのものを参照・更新
              // initialLoadStarted も同様
              if (!isLoadingSimilar) return; // すでにロード完了または進行中なら何もしない

              try {
                final activeBrands = _selectedBrands.entries
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
                final products = await _fetchSimilarProductsApi(originalProduct, activeBrands);
                setSheetState(() {
                  if (products.length > 3) {
                    similarProducts = products.sublist(0, 3);
                  } else {
                    similarProducts = products;
                  }
                  isLoadingSimilar = false;
                });
              } catch (e) {
                setSheetState(() {
                  errorSimilarMessage = '類似商品の検索中にエラー: ${e.toString()}';
                  isLoadingSimilar = false;
                });
              }
            }

            // ボトムシート表示時にデータを1回だけ読み込む
            if (isLoadingSimilar && similarProducts.isEmpty && errorSimilarMessage == null && !initialLoadStarted) {
               initialLoadStarted = true; // ロード開始をマーク
               loadSimilarProducts();
            }
            
            return DraggableScrollableSheet(
              expand: false, // falseでコンテンツの高さに合わせる
              initialChildSize: 0.6, // 初期表示の高さ（画面の60%）
              minChildSize: 0.3,     // 最小の高さ
              maxChildSize: 0.9,     // 最大の高さ
              builder: (_, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '「${originalProduct.productName}」の類似商品',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (isLoadingSimilar)
                        const Center(child: CircularProgressIndicator()),
                      if (errorSimilarMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            errorSimilarMessage!,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (!isLoadingSimilar && similarProducts.isEmpty && errorSimilarMessage == null)
                        const Center(child: Text('類似商品が見つかりませんでした。')),
                      if (!isLoadingSimilar && similarProducts.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController, // DraggableScrollableSheetと連携
                            itemCount: similarProducts.length,
                            itemBuilder: (ctx, index) {
                              final product = similarProducts[index];
                              // 類似商品リストのアイテム表示 (メインリストと同様のCardを使用可能)
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.productName, style: Theme.of(context).textTheme.titleLarge),
                                      const SizedBox(height: 4),
                                      Chip(
                                        label: Text(product.brand),
                                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.straighten, size: 18, color: Colors.grey.shade700),
                                          const SizedBox(width: 8),
                                          Text(product.size.toString(), style: Theme.of(context).textTheme.bodyMedium),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        product.description,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade800),
                                      ),
                                      const SizedBox(height: 12),
                                      InkWell(
                                        onTap: () async {
                                          // 類似商品の商品名でGoogle検索
                                          final Uri url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(product.productName)}');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url);
                                          } else {
                                            if (sheetContext.mounted) { // use sheetContext for ScaffoldMessenger
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
                                              Icon(Icons.search, size: 18, color: Theme.of(context).colorScheme.primary),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '「${product.productName}」をGoogleで検索',
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    decoration: TextDecoration.underline,
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('画像から商品を検索 (AI)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : const Center(child: Text('画像を選択してください')),
              ),
              const SizedBox(height: 16),
              
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('1. 画像を選択'),
              ),
              const SizedBox(height: 16),
              
              const Text('2. 検索対象のメーカーを選択', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildBrandSelection(),
              const SizedBox(height: 16),
              
              ElevatedButton.icon(
                onPressed: _imageFile == null || _isLoading ? null : _analyzeImage,
                icon: const Icon(Icons.analytics),
                label: const Text('3. この画像を解析'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12)
                ),
              ),
              // const SizedBox(height: 8), // ボタン間のスペース // 元の類似商品検索ボタンは削除
              // ElevatedButton.icon( // 元の類似商品検索ボタンは削除
              //   onPressed: _products.isEmpty || _isLoading ? null : _searchSimilarProducts,
              //   icon: const Icon(Icons.search_sharp),
              //   label: const Text('類似商品を検索'),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.orange,
              //     foregroundColor: Colors.white,
              //     padding: const EdgeInsets.symmetric(vertical: 12)
              //   ),
              // ),

              const SizedBox(height: 24),
              const Divider(),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('AIが画像を解析中です...'),
                      ],
                    ),
                  ),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _errorMessage!, 
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              if (!_isLoading && _products.isNotEmpty)
                _buildResultsList(),
              
              if (!_isLoading && _products.isEmpty && _imageFile != null && _errorMessage == null) // _currentSearchTypeによる分岐は簡略化
                const Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('解析が完了しました。対象商品が見つかりませんでした。'),
                )),
              // if (!_isLoading && _products.isEmpty && _currentSearchType == "similar" && _errorMessage == null) // この分岐は不要に
              //    Center(child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Text('類似商品が見つかりませんでした。'),
              //   ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSelection() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _availableBrands.map((brand) {
        return FilterChip(
          label: Text(brand),
          selected: _selectedBrands[brand] ?? false,
          onSelected: (bool selected) {
            setState(() {
              _selectedBrands[brand] = selected;
            });
          },
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.productName, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Chip(
                  label: Text(product.brand),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.straighten, size: 18, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Text(product.size.toString(), style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade800),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    // 商品名とメーカー名でGoogle検索
                    final searchQuery = '${product.brand} ${product.productName}';
                    final Uri url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(searchQuery)}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('URLを開けませんでした: ${url.toString()}')),
                        );
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 18, color: Theme.of(context).colorScheme.primary), // アイコンを検索に変更
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '「${product.brand} ${product.productName}」をGoogleで検索', // テキストを変更
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
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
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
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
}