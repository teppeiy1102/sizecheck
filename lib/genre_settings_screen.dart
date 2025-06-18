import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'brand_data.dart';
import 'package:collection/collection.dart'; // ★ ListEquality と MapEquality のために追加
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ★★★ 追加 ★★★
import 'dart:io'; // ★★★ 追加 ★★★
import 'package:flutter/services.dart'; // 検索バーで必要なら

class GenreSettingsScreen extends StatefulWidget {
  final List<SearchGenre> currentGenreOrder;
  final Map<SearchGenre, bool> currentGenreVisibility;

  const GenreSettingsScreen({
    super.key,
    required this.currentGenreOrder,
    required this.currentGenreVisibility,
  });

  @override
  State<GenreSettingsScreen> createState() => _GenreSettingsScreenState();
}

class _GenreSettingsScreenState extends State<GenreSettingsScreen> {
  late List<SearchGenre> _editableGenreOrder;
  late Map<SearchGenre, bool> _editableGenreVisibility;

  late List<SearchGenre> _initialGenreOrder;
  late Map<SearchGenre, bool> _initialGenreVisibility;

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  final String _bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7148683667182672/9797170752'
      : 'ca-app-pub-7148683667182672/3020009417';

  final TextEditingController _genreSearchController = TextEditingController();
  final TextEditingController _brandSearchController = TextEditingController();
  String _genreSearchQuery = '';
  String _brandSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _editableGenreOrder = List.from(widget.currentGenreOrder);
    _editableGenreVisibility = Map.from(widget.currentGenreVisibility);

    _initialGenreOrder = List.from(widget.currentGenreOrder);
    _initialGenreVisibility = Map.from(widget.currentGenreVisibility);
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _genreSearchController.dispose();
    _brandSearchController.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.largeBanner, // サイズをAdSize.bannerに変更することも検討（スペースに応じて）
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

  bool _hasChanges() {
    const listEquality = ListEquality();
    const mapEquality = MapEquality();

    final orderChanged = !listEquality.equals(_editableGenreOrder, _initialGenreOrder);
    final visibilityChanged = !mapEquality.equals(_editableGenreVisibility, _initialGenreVisibility);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (orderChanged || visibilityChanged) != _isSaveButtonVisible) {
        setState(() {
          _isSaveButtonVisible = orderChanged || visibilityChanged;
        });
      } else if (mounted && !(orderChanged || visibilityChanged) && _isSaveButtonVisible) {
        setState(() {
          _isSaveButtonVisible = false;
        });
      }
    });
    return orderChanged || visibilityChanged;
  }

  Future<bool> _showExitConfirmDialog() async {
    if (!_hasChanges()) {
      return true; // 変更がなければそのまま閉じる
    }
    final bool? shouldPop = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // ダイアログ外タップで閉じない
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800], // ダークな背景色
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text('変更の確認', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('編集内容が保存されていません。\n変更を破棄して戻りますか？', style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(false); // ダイアログを閉じ、戻る操作をキャンセル
              },
            ),
            TextButton(
              child: const Text('変更を破棄', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.of(context).pop(true); // ダイアログを閉じ、戻る操作を許可
              },
            ),
          ],
        );
      },
    );
    return shouldPop ?? false; // ダイアログが予期せず閉じられた場合は戻らない
  }

  // ★ ハイライト用メソッド
  TextSpan _highlightText(String text, String query) {
    if (query.isEmpty) return TextSpan(text: text);
    final matches = RegExp(RegExp.escape(query), caseSensitive: false).allMatches(text);
    if (matches.isEmpty) return TextSpan(text: text);

    List<TextSpan> spans = [];
    int last = 0;
    for (final m in matches) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      spans.add(TextSpan(
        text: text.substring(m.start, m.end),
        style: const TextStyle(backgroundColor: Colors.yellow, color: Colors.black),
      ));
      last = m.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    return TextSpan(children: spans);
  }

  // ★ 全ジャンル横断ブランド検索ダイアログ
  Future<void> _showAllBrandSearchDialog(BuildContext context, String query) async {
    final allGenres = BrandData.getAllGenres();
    final Map<SearchGenre, List<String>> genreToBrands = {};

    // 検索クエリを正規化
    final q = query.trim().toLowerCase();

    for (final genre in allGenres) {
      final brands = BrandData.getBrandsForGenre(genre);
      final filtered = brands.where((brandName) {
        final desc = BrandData.brandDescriptions[brandName] ?? '';
        final url = BrandData.brandTopPageUrls[brandName] ?? '';
        // すべて小文字化して比較
        return brandName.toLowerCase().contains(q) ||
            desc.toLowerCase().contains(q) ||
            url.toLowerCase().contains(q);
      }).toList();
      if (filtered.isNotEmpty) {
        genreToBrands[genre] = filtered;
      }
    }

    if (genreToBrands.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('検索条件に一致するブランドはありません。', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.grey[800],
          ),
        );
      }
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(.0),
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(
            'ブランド横断検索結果',
            style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: genreToBrands.entries.map((entry) {
                final genre = entry.key;
                final brands = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        BrandData.getGenreDisplayName(genre),
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ...brands.map((brandName) {
                      final brandUrl = BrandData.brandTopPageUrls[brandName] ?? '';
                      final brandDescription = BrandData.brandDescriptions[brandName] ?? '説明はありません。';
                      return Card(
                        color: Colors.white12,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                _highlightText(brandName, query),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text.rich(
                                _highlightText(brandDescription, query),
                                style: TextStyle(color: Colors.white.withOpacity(0.8)),
                              ),
                              if (brandUrl.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                InkWell(
                                  child: Text.rich(
                                    _highlightText(brandUrl, query),
                                    style: TextStyle(
                                      color: Colors.blueAccent[100],
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.blueAccent[100],
                                    ),
                                  ),
                                  onTap: () async {
                                    final Uri url = Uri.parse(brandUrl);
                                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('URLを開けませんでした: $brandUrl', style: const TextStyle(color: Colors.white)),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('閉じる', style: TextStyle(color: Colors.lightBlueAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isSaveButtonVisible = false;

  @override
  Widget build(BuildContext context) {
    _hasChanges();

    // ジャンル名でフィルタ
    final filteredGenreOrder = _genreSearchQuery.isEmpty
        ? _editableGenreOrder
        : _editableGenreOrder.where((genre) {
            final name = BrandData.getGenreDisplayName(genre);
            return name.contains(_genreSearchQuery);
          }).toList();

    return WillPopScope(
      onWillPop: _showExitConfirmDialog,
      child: Scaffold(
        backgroundColor: const Color(0xFF2c2c2e),
        appBar: AppBar(
          title: const Text('検索ジャンル設定', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF3a3a3c), const Color(0xFF2c2c2e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(112),
            child: Column(
              children: [
                // ジャンル名検索欄
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _genreSearchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'ジャンル名で検索',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF3a3a3c),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _genreSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54),
                              onPressed: () {
                                setState(() {
                                  _genreSearchController.clear();
                                  _genreSearchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _genreSearchQuery = value;
                      });
                    },
                  ),
                ),
                // ブランド名・説明・URL検索欄
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _brandSearchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'ブランド名・説明・URLで検索',
                            hintStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.search, color: Colors.white54),
                            filled: true,
                            fillColor: const Color(0xFF3a3a3c),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: _brandSearchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.white54),
                                    onPressed: () {
                                      setState(() {
                                        _brandSearchController.clear();
                                        _brandSearchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _brandSearchQuery = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _brandSearchQuery.isEmpty
                            ? null
                            : () {
                                _showAllBrandSearchDialog(context, _brandSearchQuery);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('ブランド横断検索'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _isSaveButtonVisible
            ? SizedBox(
              height: 80,
              width: 150,
              child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.pop(context, {
                      'order': _editableGenreOrder,
                      'visibility': _editableGenreVisibility,
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  label: const Text('保存する', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  icon: const Icon(Icons.save),
                  backgroundColor: Colors.lightBlueAccent,
                  foregroundColor: Colors.white,
                ),
            )
            : null,
        bottomNavigationBar: _bannerAd != null && _isBannerAdLoaded
            ? Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              )
            : null, // バナーがない場合は何も表示しない
        body: ReorderableListView.builder(
          padding: EdgeInsets.only(
            top: 8.0,
            left: 8.0,
            right: 8.0,
            bottom: _isSaveButtonVisible ? 80.0 : 16.0,
          ),
          itemCount: filteredGenreOrder.length,
          itemBuilder: (context, index) {
            final genre = filteredGenreOrder[index];
            return SwitchListTile(
              key: ValueKey(genre),
              tileColor: const Color(0xFF2c2c2e),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              title: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.white70),
                    tooltip: 'ブランド情報',
                    onPressed: () {
                      _showBrandInfoDialog(context, genre);
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      BrandData.getGenreDisplayName(genre),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              value: _editableGenreVisibility[genre] ?? true,
              onChanged: (bool value) {
                setState(() {
                  _editableGenreVisibility[genre] = value;
                  _hasChanges();
                });
              },
              activeColor: Colors.lightBlueAccent,
              inactiveTrackColor: Colors.grey[700],
              secondary: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle, color: Colors.white54),
                  ),
                ],
              ),
            );
          },
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final SearchGenre item = _editableGenreOrder.removeAt(oldIndex);
              _editableGenreOrder.insert(newIndex, item);
              _hasChanges();
            });
          },
        ),
      ),
    );
  }

  // ★ ブランド情報ダイアログ
  Future<void> _showBrandInfoDialog(BuildContext context, SearchGenre genre) async {
    final brands = BrandData.getBrandsForGenre(genre);
    final genreName = BrandData.getGenreDisplayName(genre);

    // ★ 検索クエリでブランド名・説明・URLをフィルタ
    final filteredBrands = _brandSearchQuery.isEmpty
        ? brands
        : brands.where((brandName) {
            final desc = BrandData.brandDescriptions[brandName] ?? '';
            final url = BrandData.brandTopPageUrls[brandName] ?? '';
            final q = _brandSearchQuery.toLowerCase();
            return brandName.toLowerCase().contains(q) ||
                desc.toLowerCase().contains(q) ||
                url.toLowerCase().contains(q);
          }).toList();

    if (filteredBrands.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('検索条件に一致するブランドはありません。', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.grey[800],
          ),
        );
      }
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(.0),
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(
            '$genreName のブランド情報',
            style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredBrands.length,
              itemBuilder: (BuildContext context, int index) {
                final brandName = filteredBrands[index];
                final brandUrl = BrandData.brandTopPageUrls[brandName] ?? '';
                final brandDescription = BrandData.brandDescriptions[brandName] ?? '説明はありません。';

                return Card(
                  color: Colors.white12,
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ブランド名ハイライト
                        Text.rich(
                          _highlightText(brandName, _brandSearchQuery),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // 説明文ハイライト
                        Text.rich(
                          _highlightText(brandDescription, _brandSearchQuery),
                          style: TextStyle(color: Colors.white.withOpacity(0.8)),
                        ),
                        if (brandUrl.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          InkWell(
                            child: Text.rich(
                              _highlightText(brandUrl, _brandSearchQuery),
                              style: TextStyle(
                                color: Colors.blueAccent[100],
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blueAccent[100],
                              ),
                            ),
                            onTap: () async {
                              final Uri url = Uri.parse(brandUrl);
                              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('URLを開けませんでした: $brandUrl', style: const TextStyle(color: Colors.white)),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('閉じる', style: TextStyle(color: Colors.lightBlueAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}