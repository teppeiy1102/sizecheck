// genre_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'brand_data.dart';
import 'package:collection/collection.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

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

class _GenreSettingsScreenState extends State<GenreSettingsScreen> with SingleTickerProviderStateMixin {
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

  bool _isSaveButtonVisible = false;

  // 絞り込み条件を保持するState変数
  Set<int> _selectedDecades = {};
  Set<String> _selectedCountries = {};
  final TextEditingController _founderFilterController = TextEditingController();
  final TextEditingController _cityFilterController = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _editableGenreOrder = List.from(widget.currentGenreOrder);
    _editableGenreVisibility = Map.from(widget.currentGenreVisibility);
    _initialGenreOrder = List.from(widget.currentGenreOrder);
    _initialGenreVisibility = Map.from(widget.currentGenreVisibility);
    _loadBannerAd();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted && !_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _genreSearchController.dispose();
    _brandSearchController.dispose();
    _founderFilterController.dispose();
    _cityFilterController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.largeBanner,
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
      if (!mounted) return;
      final bool shouldBeVisible = orderChanged || visibilityChanged;
      if (_isSaveButtonVisible != shouldBeVisible) {
        setState(() {
          _isSaveButtonVisible = shouldBeVisible;
        });
      }
    });
    return orderChanged || visibilityChanged;
  }

  Future<bool> _showExitConfirmDialog() async {
    if (_tabController.index != 0 || !_hasChanges()) return true;

    final bool? shouldPop = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text('変更の確認', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('編集内容が保存されていません。\n変更を破棄して戻りますか？', style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('変更を破棄', style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    return shouldPop ?? false;
  }

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

  bool _isFilterActive() {
    return _selectedDecades.isNotEmpty ||
        _selectedCountries.isNotEmpty ||
        _founderFilterController.text.isNotEmpty ||
        _cityFilterController.text.isNotEmpty;
  }

  List<BrandInfo> _applyFilters(Iterable<BrandInfo> brands) {
    return brands.where((brand) {
      final decadeMatch = _selectedDecades.isEmpty ||
          (brand.foundationDecade != null && _selectedDecades.contains(brand.foundationDecade));

      final countryMatch = _selectedCountries.isEmpty ||
          (brand.country != null && _selectedCountries.contains(brand.country));

      final founderMatch = _founderFilterController.text.isEmpty ||
          (brand.founder?.toLowerCase().contains(_founderFilterController.text.toLowerCase()) ?? false);

      final cityMatch = _cityFilterController.text.isEmpty ||
          (brand.city?.toLowerCase().contains(_cityFilterController.text.toLowerCase()) ?? false);

      return decadeMatch && countryMatch && founderMatch && cityMatch;
    }).toList();
  }

  Future<void> _showBrandInfoDialog(BuildContext context, SearchGenre genre) async {
    final allBrandsInGenre = BrandData.getBrandInfosForGenre(genre);
    
    String dialogSearchQuery = ''; 
    final searchResult = allBrandsInGenre; 
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final q = dialogSearchQuery.toLowerCase();
            final currentSearchResult = q.isEmpty ? searchResult : searchResult.where((brand) {
              return brand.name.toLowerCase().contains(q) ||
                  brand.description.toLowerCase().contains(q) ||
                  brand.url.toLowerCase().contains(q);
            }).toList();

            return AlertDialog(
              insetPadding: const EdgeInsets.all(10.0),
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              title: Text(
                '${BrandData.getGenreDisplayName(genre)} のブランド情報',
                style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'この中でさらに検索...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                        filled: true,
                        fillColor: Colors.white10,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      onChanged: (value) => setDialogState(() => dialogSearchQuery = value),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: currentSearchResult.isEmpty
                          ? const Center(child: Text('該当なし', style: TextStyle(color: Colors.white54)))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: currentSearchResult.length,
                              itemBuilder: (ctx, index) => _buildBrandCard(currentSearchResult[index], dialogSearchQuery),
                            ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('閉じる', style: TextStyle(color: Colors.lightBlueAccent)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ▼▼▼▼▼ ここからが変更箇所 ▼▼▼▼▼
  
  /// 地図アプリを起動してブランド店舗を検索するメソッド
  Future<void> _openMapForBrand(BrandInfo brand) async {
    // ブランド名に「店舗」を加えて検索クエリを作成し、URLエンコードする
    final query = Uri.encodeComponent('${brand.name} 店舗');
    
    // プラットフォームに応じて適切な地図URLを生成
    final Uri mapUri;
    if (Platform.isIOS) {
      // iOSの場合はApple MapsのURLスキームを使用
      mapUri = Uri.parse('https://maps.apple.com/?q=$query');
    } else {
      // Androidやその他のプラットフォームではGoogle MapsのWeb URLを使用
      // (Google Mapsアプリがインストールされていれば、通常はアプリで開かれる)
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

  Widget _buildBrandCard(BrandInfo brand, String query) {
    return Card(
      color: Colors.white12,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ブランド名と地図アイコンを横並びに配置
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text.rich(
                    _highlightText(brand.name, query),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                // 地図アイコンボタン
                IconButton(
                  onPressed: () => _openMapForBrand(brand),
                  icon: const Icon(Icons.map_outlined, color: Colors.lightBlueAccent, size: 26),
                  tooltip: '店舗を地図で探す',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6.0,
              runSpacing: 4.0,
              children: [
                if (brand.foundationYear != null)
                  Chip(
                    label: Text('${brand.foundationYear}年', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.zero, visualDensity: VisualDensity.compact,
                  ),
                if (brand.country != null)
                  Chip(
                    label: Text(brand.country!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    backgroundColor: Colors.indigo,
                    padding: EdgeInsets.zero, visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text.rich(
              _highlightText(brand.description, query),
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            if (brand.url.isNotEmpty) ...[
              const SizedBox(height: 8),
              InkWell(
                child: Text.rich(
                  _highlightText(brand.url, query),
                  style: TextStyle(
                    color: Colors.blueAccent[100],
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blueAccent[100],
                  ),
                ),
                onTap: () async {
                  final Uri url = Uri.parse(brand.url);
                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('URLを開けませんでした: ${brand.url}', style: const TextStyle(color: Colors.white)),
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
  }
  
  // ▲▲▲▲▲ ここまでが変更箇所 ▲▲▲▲▲

  Future<void> _showFilterDialog(BuildContext context) async {
    final allBrands = BrandData.allBrands.values;
    final decades = allBrands
        .map((b) => b.foundationDecade).whereType<int>().toSet().toList()..sort((a,b) => b.compareTo(a)); // 降順
    final countries = allBrands
        .map((b) => b.country).whereType<String>().toSet().toList()..sort();

    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            
            Widget buildSection(String title, Widget child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Text(title, style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
                  ),
                  child,
                ],
              );
            }
            
            return AlertDialog(
              backgroundColor: Colors.grey[850],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              title: const Text('ブランド絞り込み', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSection('創業年代 (10年毎)', Wrap(
                      spacing: 8.0, runSpacing: 4.0,
                      children: decades.map((decade) {
                        return FilterChip(
                          label: Text('${decade}s', style: const TextStyle(color: Colors.white)),
                          selected: _selectedDecades.contains(decade),
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) _selectedDecades.add(decade);
                              else _selectedDecades.remove(decade);
                            });
                          },
                          selectedColor: Colors.lightBlue,
                          backgroundColor: Colors.grey[700],
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    )),
                    buildSection('創業国', Wrap(
                      spacing: 8.0, runSpacing: 4.0,
                      children: countries.map((country) {
                        return FilterChip(
                          label: Text(country, style: const TextStyle(color: Colors.white)),
                          selected: _selectedCountries.contains(country),
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) _selectedCountries.add(country);
                              else _selectedCountries.remove(country);
                            });
                          },
                          selectedColor: Colors.lightBlue,
                          backgroundColor: Colors.grey[700],
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    )),
                    buildSection('創業者', TextField(
                      controller: _founderFilterController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '創業者名で検索',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true, fillColor: Colors.grey[800],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      onChanged: (value) => setDialogState((){}),
                    )),
                    buildSection('創業地', TextField(
                      controller: _cityFilterController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '創業地で検索',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true, fillColor: Colors.grey[800],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      onChanged: (value) => setDialogState((){}),
                    )),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('リセット', style: TextStyle(color: Colors.grey)),
                  onPressed: () {
                    setDialogState(() {
                      _selectedDecades.clear();
                      _selectedCountries.clear();
                      _founderFilterController.clear();
                      _cityFilterController.clear();
                    });
                  },
                ),
                TextButton(
                  child: const Text('適用', style: TextStyle(color: Colors.lightBlueAccent)),
                  onPressed: () {
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
        });
  }

  Widget _buildBrandSearchResultsList() {
    final filteredByAttributes = _applyFilters(BrandData.allBrands.values);

    final q = _brandSearchQuery.trim().toLowerCase();
    final searchResult = q.isEmpty
        ? filteredByAttributes
        : filteredByAttributes.where((brand) {
            return brand.name.toLowerCase().contains(q) ||
                brand.description.toLowerCase().contains(q) ||
                brand.url.toLowerCase().contains(q);
          }).toList();

    if (searchResult.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _isFilterActive() || _brandSearchQuery.isNotEmpty
                ? '検索条件に一致するブランドはありません。'
                : '上部の検索欄やフィルターを\n使用してブランドを検索・絞り込みできます。',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      );
    }

    final Map<SearchGenre, List<BrandInfo>> genreToBrands = {};
    for (final genre in _editableGenreOrder) {
      final brandsInGenre = searchResult
          .where((brand) => BrandData.getBrandNamesForGenre(genre).contains(brand.name))
          .toList();
      if (brandsInGenre.isNotEmpty) {
        genreToBrands[genre] = brandsInGenre;
      }
    }

    if (genreToBrands.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '検索条件に一致するブランドはありません。',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ),
        );
    }

    final sortedEntries = genreToBrands.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: 8.0, left: 8.0, right: 8.0, bottom: 16.0,
      ),
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 4.0),
              child: Text(
                BrandData.getGenreDisplayName(entry.key),
                style: const TextStyle(
                    color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            ...entry.value.map((brand) => _buildBrandCard(brand, _brandSearchQuery)),
            if (index < sortedEntries.length - 1)
              const Divider(height: 24, color: Colors.white24, indent: 16, endIndent: 16),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    _hasChanges();
    final filteredGenreOrder = _genreSearchQuery.isEmpty
        ? _editableGenreOrder
        : _editableGenreOrder.where((genre) {
            final name = BrandData.getGenreDisplayName(genre);
            return name.toLowerCase().contains(_genreSearchQuery.toLowerCase());
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
          actions: [
            if (_tabController.index == 1)
              IconButton(
                icon: Icon(Icons.filter_list, color: _isFilterActive() ? Colors.lightBlueAccent : Colors.white),
                onPressed: () => _showFilterDialog(context),
                tooltip: 'ブランド絞り込み',
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 64),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'ジャンル設定'),
                    Tab(text: 'ブランド検索'),
                  ],
                  labelColor: Colors.lightBlueAccent,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: Colors.lightBlueAccent,
                ),
                SizedBox(
                  height: 64,
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: _genreSearchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'ジャンル名で絞り込み',
                            hintStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.search, color: Colors.white54),
                            filled: true, fillColor: const Color(0xFF3a3a3c),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                          onChanged: (value) => setState(() => _genreSearchQuery = value),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: _brandSearchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'ブランド名・説明・URLで検索',
                            hintStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.search, color: Colors.white54),
                            filled: true, fillColor: const Color(0xFF3a3a3c),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                          onChanged: (value) => setState(() => _brandSearchQuery = value),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _tabController.index == 0 && _isSaveButtonVisible
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
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
            : null,
        body: TabBarView(
          controller: _tabController,
          children: [
            ReorderableListView.builder(
              padding: EdgeInsets.only(
                top: 8.0, left: 8.0, right: 8.0,
                bottom: _isSaveButtonVisible ? 100.0 : 16.0,
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
                        onPressed: () => _showBrandInfoDialog(context, genre),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          _highlightText(BrandData.getGenreDisplayName(genre), _genreSearchQuery),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  value: _editableGenreVisibility[genre] ?? true,
                  onChanged: (bool value) {
                    setState(() {
                      _editableGenreVisibility[genre] = value;
                    });
                  },
                  activeColor: Colors.lightBlueAccent,
                  inactiveTrackColor: Colors.grey[700],
                  secondary: ReorderableDragStartListener(
                    index: _editableGenreOrder.indexOf(genre),
                    child: const Icon(Icons.drag_handle, color: Colors.white54),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  final itemToMove = filteredGenreOrder[oldIndex];
                  final originalOldIndex = _editableGenreOrder.indexOf(itemToMove);
              
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final targetItem = filteredGenreOrder[newIndex];
                  final originalNewIndex = _editableGenreOrder.indexOf(targetItem);
              
                  final item = _editableGenreOrder.removeAt(originalOldIndex);
                  _editableGenreOrder.insert(originalNewIndex, item);
                });
              },
            ),
            _buildBrandSearchResultsList(),
          ],
        ),
      ),
    );
  }
}