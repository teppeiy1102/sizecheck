import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 日時フォーマット用 (pubspec.yaml に intl: ^any を追加してください)
import '../procuctmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'brand_data.dart'; // ★★★ 追加: brand_data.dart をインポート ★★★

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

  // ResultsScreenからテーマカラーを拝借 (共通化推奨)
  final Color darkPrimaryColor = const Color.fromARGB(255, 193, 115, 196);
  final Color darkAccentColor = Colors.tealAccent[400]!;
  final Color darkBackgroundColor = Colors.grey[900]!;
  final Color darkCardColor = Colors.grey[850]!.withOpacity(0.85);
  final Color darkChipColor = Colors.grey[700]!;


  @override
  void initState() {
    super.initState();
    _loadSavedProducts();
  }

  Future<void> _loadSavedProducts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    _savedProducts = await _preferenceService.getSavedProducts();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('保存した商品', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          PopupMenuButton<SortCriteria>(
            surfaceTintColor: Colors.black87,
            color: Colors.black87,
            icon: const Icon(Icons.sort, color: Colors.white),
            tooltip: '並び替え',
            style: ButtonStyle(


            ),
            onSelected: (SortCriteria result) {
              if (mounted) {
                setState(() {
                  _currentSortCriteria = result;
                  _sortProducts();
                });
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortCriteria>>[
              const PopupMenuItem<SortCriteria>(
                value: SortCriteria.savedDateDesc,
                child: Text('保存が新しい順',style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<SortCriteria>(
                value: SortCriteria.savedDateAsc,
                child: Text('保存が古い順',style: TextStyle(color: Colors.white),),
              ),
              const PopupMenuItem<SortCriteria>(
                value: SortCriteria.nameAsc,
                child: Text('商品名 (昇順)',style: TextStyle(color: Colors.white),),
              ),
              const PopupMenuItem<SortCriteria>(
                value: SortCriteria.nameDesc,
                child: Text('商品名 (降順)',style: TextStyle(color: Colors.white ) ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent)))
          : _savedProducts.isEmpty
              ? Center(
                  child: Text(
                    '保存された商品はありません。',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _savedProducts.length,
                  itemBuilder: (context, index) {
                    final product = _savedProducts[index];
                    final brandTopPageUrl = BrandData.brandTopPageUrls[product.brand];

                    return Card(
                      color: darkCardColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${product.emoji ?? ''} ${product.productName}',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.redAccent[100]),
                                  tooltip: '削除する',
                                  onPressed: () => _showDeleteConfirmationDialog(product),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(product.brand, style: TextStyle(color: Colors.white.withOpacity(0.9))),
                              backgroundColor: darkChipColor.withOpacity(0.7),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            if (brandTopPageUrl != null && brandTopPageUrl.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
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
                                      Icon(Icons.public, size: 14, color: Colors.grey.shade400),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          brandTopPageUrl,
                                          style: TextStyle(
                                            color: Colors.blue[300],
                                            fontSize: 12,
                                            decoration: TextDecoration.underline,
                                            decorationColor: Colors.blue[300]?.withOpacity(0.7),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.straighten, size: 18, color: Colors.grey.shade400),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    product.size.toString(),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[300]),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (product.description.isNotEmpty)
                              Text(
                                product.description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (product.description.isNotEmpty) const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.bookmark_added_outlined, size: 16, color: Colors.grey.shade400),
                                const SizedBox(width: 8),
                                Text(
                                  '保存日時: ${_formatDateTime(product.savedAt)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // ★★★ 「商品ページを見る」をGoogle検索に変更 ★★★
                            InkWell(
                              onTap: () async {
                                final searchQuery = '${product.brand} ${product.productName}';
                                final Uri url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(searchQuery)}');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('検索ページを開けませんでした。'),
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
                                    Icon(Icons.search, size: 18, color: darkAccentColor), // アイコンを検索に変更
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Googleで検索する', // テキストを変更
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