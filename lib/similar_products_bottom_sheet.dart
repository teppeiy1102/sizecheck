import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'procuctmodel.dart';

class SimilarProductsBottomSheet extends StatefulWidget {
  final Product originalProduct;
  final Map<String, bool> selectedBrandsForSimilarSearch;
  final Future<List<Product>> Function(Product, List<String>)
      fetchSimilarProductsApiCallback;
  final Future<void> Function(List<Product>) openMapForSimilarBrands;
  final Set<String> savedProductUrls;
  final Future<void> Function(Product) toggleSaveProduct;
  final String Function(ProductSize) formatSize;
  final Color darkAccentColor;
  final Color darkChipColor;

  const SimilarProductsBottomSheet({
    super.key,
    required this.originalProduct,
    required this.selectedBrandsForSimilarSearch,
    required this.fetchSimilarProductsApiCallback,
    required this.openMapForSimilarBrands,
    required this.savedProductUrls,
    required this.toggleSaveProduct,
    required this.formatSize,
    required this.darkAccentColor,
    required this.darkChipColor,
  });

  @override
  State<SimilarProductsBottomSheet> createState() =>
      _SimilarProductsBottomSheetState();
}

class _SimilarProductsBottomSheetState extends State<SimilarProductsBottomSheet> {
  bool isLoadingSimilar = true;
  List<Product> similarProducts = [];
  String? errorSimilarMessage;
  WebViewController? _webViewControllerForSheet;
  PageController? _pageController;
  bool isWebViewExpanded = false;
  bool initialLoadStarted = false;
  late Set<String> _savedProductUrls;

  @override
  void initState() {
    super.initState();
    _savedProductUrls = widget.savedProductUrls;
    _pageController = PageController(viewportFraction: 0.9);
    if (!initialLoadStarted) {
      initialLoadStarted = true;
      _loadSimilarProducts();
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _loadSimilarProducts() async {
    // 検索処理中はインジケーターを表示
    if (mounted) {
      setState(() {
        isLoadingSimilar = true;
        errorSimilarMessage = null;
      });
    }

    try {
      final activeBrands = widget.selectedBrandsForSimilarSearch.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (activeBrands.isEmpty) {
        if (mounted) {
          setState(() {
            errorSimilarMessage = '検索対象のブランドが選択されていません。';
            isLoadingSimilar = false;
          });
        }
        return;
      }

      final products = await widget.fetchSimilarProductsApiCallback(
          widget.originalProduct, activeBrands);

      if (mounted) {
        setState(() {
          similarProducts = products;
          isLoadingSimilar = false;
          if (products.isNotEmpty) {
            _updateWebView(products.first, isInitialLoad: true);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorSimilarMessage = '類似商品の検索中にエラーが発生しました: $e';
          isLoadingSimilar = false;
        });
      }
    }
  }

  void _updateWebView(Product product, {bool isInitialLoad = false}) {
    final searchQuery = '${product.brand} ${product.productName}';
    final searchUrl =
        'https://www.google.com/search?q=${Uri.encodeComponent(searchQuery)}&tbm=isch';

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _webViewControllerForSheet?.runJavaScript('window.scrollTo(0, 150);');
          },
        ),
      )
      ..loadRequest(Uri.parse(searchUrl));

    setState(() {
      _webViewControllerForSheet = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.2,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[900]!.withOpacity(0.95),
                  Colors.black.withOpacity(0.95)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ニタモノ検索結果',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      if (!isLoadingSimilar && similarProducts.isNotEmpty)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.map_rounded, size: 16),
                          label: Text(
                            '${similarProducts.length}件を地図表示',
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () =>
                              widget.openMapForSimilarBrands(similarProducts),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(137, 49, 149, 195),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isLoadingSimilar)
                  const Expanded(
                      child: Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.pinkAccent)))),
                if (!isLoadingSimilar && errorSimilarMessage != null)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          errorSimilarMessage!,
                          style: TextStyle(
                              color: Colors.redAccent[100],
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                if (!isLoadingSimilar &&
                    similarProducts.isEmpty &&
                    errorSimilarMessage == null)
                  const Expanded(
                    child: Center(
                      child: Text(
                        '類似商品は見つかりませんでした。',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ),
                if (!isLoadingSimilar && similarProducts.isNotEmpty)
                  Expanded(
                    child: Column(
                      children: [
                        if (!isWebViewExpanded)
                          SizedBox(
                            height: 230,
                            child: PageView.builder(
                              itemCount: similarProducts.length,
                              controller: _pageController,
                              onPageChanged: (index) {
                                _updateWebView(similarProducts[index]);
                              },
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: _buildSingleSimilarProductItem(
                                      context, similarProducts[index]),
                                );
                              },
                            ),
                          ),
                        if (!isWebViewExpanded) const SizedBox(height: 8),
                        if (_webViewControllerForSheet != null)
                          Expanded(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: isWebViewExpanded
                                      ? BorderRadius.zero
                                      : const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                  child: WebViewWidget(
                                      controller: _webViewControllerForSheet!),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    color: Colors.black54,
                                    child: PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert,
                                          color: Colors.white),
                                      color: Colors.grey[800],
                                      onSelected: (value) {
                                        if (value == 'expand') {
                                          setState(() {
                                            isWebViewExpanded =
                                                !isWebViewExpanded;
                                          });
                                        }
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
                                        PopupMenuItem<String>(
                                          value: 'expand',
                                          child: Text(
                                              isWebViewExpanded
                                                  ? '画像を縮小'
                                                  : '画像を拡大',
                                              style: const TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_webViewControllerForSheet == null &&
                            errorSimilarMessage == null &&
                            similarProducts.isNotEmpty)
                          const Expanded(
                              child: Center(
                                  child: Text('画像表示エリアの準備中です...',
                                      style: TextStyle(
                                          color: Colors.orangeAccent,
                                          fontSize: 16)))),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSingleSimilarProductItem(BuildContext context, Product product) {
    final bool isSaved = _savedProductUrls.contains(product.productUrl);
    return Card(
      color: Colors.black38,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    product.productName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                if (product.productUrl.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      isSaved
                          ? Icons.bookmark_added
                          : Icons.bookmark_add_outlined,
                      color:
                          isSaved ? widget.darkAccentColor : Colors.white70,
                    ),
                    tooltip: isSaved ? '保存済みから削除' : '商品を保存',
                    onPressed: () async {
                      await widget.toggleSaveProduct(product);
                      setState(() {
                        if (isSaved) {
                          _savedProductUrls.remove(product.productUrl);
                        } else {
                          _savedProductUrls.add(product.productUrl);
                        }
                      });
                    },
                  ),
              ],
            ),
            //////////////const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Chip(
                  label: Text(product.brand,
                      style:
                          TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                  backgroundColor: widget.darkChipColor.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => widget.openMapForSimilarBrands([product]),
                  icon: const Icon(Icons.map_outlined,
                      color: Colors.lightBlueAccent),
                  tooltip: '店舗を地図で探す',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.straighten, size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Text(widget.formatSize(product.size),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[300])),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              product.description,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[400]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            InkWell(
              onTap: () async {
                final searchQuery = '${product.brand} ${product.productName}';
                final Uri url = Uri.parse(
                    'https://www.google.com/search?q=${Uri.encodeComponent(searchQuery)}');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 18, color: widget.darkAccentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '「${product.productName}」をGoogleで検索',
                        style: TextStyle(
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              widget.darkAccentColor.withOpacity(0.7),
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
  }
}