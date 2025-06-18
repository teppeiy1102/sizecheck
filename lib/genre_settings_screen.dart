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

  bool _isSaveButtonVisible = false;

  // 絞り込み条件を保持するState変数
  Set<int> _selectedDecades = {};
  Set<String> _selectedCountries = {};
  final TextEditingController _founderFilterController = TextEditingController();
  final TextEditingController _cityFilterController = TextEditingController();

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
    _founderFilterController.dispose();
    _cityFilterController.dispose();
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
    
    // このメソッドはビルド中に呼ばれることがあるため、setStateを直接呼ぶ代わりにコールバックを使う
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
    if (!_hasChanges()) return true;
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

  Future<void> _showAllBrandSearchDialog(BuildContext context, String query) async {
    final filteredByAttributes = _applyFilters(BrandData.allBrands.values);
    
    final q = query.trim().toLowerCase();
    final searchResult = q.isEmpty ? filteredByAttributes : filteredByAttributes.where((brand) {
      return brand.name.toLowerCase().contains(q) ||
          brand.description.toLowerCase().contains(q) ||
          brand.url.toLowerCase().contains(q);
    }).toList();

    if (searchResult.isEmpty) {
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

    final Map<SearchGenre, List<BrandInfo>> genreToBrands = {};
    for (final brand in searchResult) {
      for (final genre in SearchGenre.values) {
        if (BrandData.getBrandNamesForGenre(genre).contains(brand.name)) {
          genreToBrands.putIfAbsent(genre, () => []).add(brand);
        }
      }
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(10.0),
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        BrandData.getGenreDisplayName(entry.key),
                        style: const TextStyle(
                          color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    ...entry.value.map((brand) => _buildBrandCard(brand, query)),
                  ],
                );
              }).toList(),
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
  }

  Future<void> _showBrandInfoDialog(BuildContext context, SearchGenre genre) async {
    final allBrandsInGenre = BrandData.getBrandInfosForGenre(genre);
    final filteredByAttributes = _applyFilters(allBrandsInGenre);
    
    final q = _brandSearchQuery.toLowerCase();
    final searchResult = q.isEmpty ? filteredByAttributes : filteredByAttributes.where((brand) {
      return brand.name.toLowerCase().contains(q) ||
          brand.description.toLowerCase().contains(q) ||
          brand.url.toLowerCase().contains(q);
    }).toList();
    
    if (searchResult.isEmpty) {
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
          insetPadding: const EdgeInsets.all(10.0),
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(
            '${BrandData.getGenreDisplayName(genre)} のブランド情報',
            style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchResult.length,
              itemBuilder: (ctx, index) => _buildBrandCard(searchResult[index], _brandSearchQuery),
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
            Text.rich(
              _highlightText(brand.name, query),
              style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6.0,
              runSpacing: 4.0,
              children: [
                if (brand.foundationYear != null)
                  Chip(
                    label: Text('${brand.foundationYear}年', style: TextStyle(color: Colors.white, fontSize: 12)),
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.zero, visualDensity: VisualDensity.compact,
                  ),
                if (brand.country != null)
                  Chip(
                    label: Text(brand.country!, style: TextStyle(color: Colors.white, fontSize: 12)),
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
                          label: Text('${decade}s', style: TextStyle(color: Colors.white)),
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
                          label: Text(country, style: TextStyle(color: Colors.white)),
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
                        hintStyle: TextStyle(color: Colors.white54),
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
                        hintStyle: TextStyle(color: Colors.white54),
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
            IconButton(
              icon: Icon(Icons.filter_list, color: _isFilterActive() ? Colors.lightBlueAccent : Colors.white),
              onPressed: () => _showFilterDialog(context),
              tooltip: 'ブランド絞り込み',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(112),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _genreSearchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'ジャンル名で検索',
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
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _brandSearchQuery.isEmpty && !_isFilterActive()
                            ? null
                            : () => _showAllBrandSearchDialog(context, _brandSearchQuery),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        body: ReorderableListView.builder(
          padding: EdgeInsets.only(
            top: 8.0, left: 8.0, right: 8.0, bottom: _isSaveButtonVisible ? 80.0 : 16.0,
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
              secondary: ReorderableDragStartListener(
                index: _editableGenreOrder.indexOf(genre), // フィルター適用後でも正しいindexを参照
                child: const Icon(Icons.drag_handle, color: Colors.white54),
              ),
            );
          },
          onReorder: (oldIndex, newIndex) {
            setState(() {
              // フィルター適用後のリストでのインデックスを、元のリストのインデックスに変換
              final oldItem = filteredGenreOrder[oldIndex];
              final originalOldIndex = _editableGenreOrder.indexOf(oldItem);

              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              // フィルター適用後のリストでの移動先インデックスを、元のリストのインデックスに変換
              final newItem = filteredGenreOrder[newIndex];
              final originalNewIndex = _editableGenreOrder.indexOf(newItem);

              final item = _editableGenreOrder.removeAt(originalOldIndex);
              _editableGenreOrder.insert(originalNewIndex, item);
              
              _hasChanges();
            });
          },
        ),
      ),
    );
  }
}