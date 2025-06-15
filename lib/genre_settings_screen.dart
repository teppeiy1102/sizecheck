import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'brand_data.dart';
import 'package:collection/collection.dart'; // ★ ListEquality と MapEquality のために追加
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ★★★ 追加 ★★★
import 'dart:io'; // ★★★ 追加 ★★★

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

  late List<SearchGenre> _initialGenreOrder; // ★ 追加: 初期状態を保ｘｗ
  late Map<SearchGenre, bool> _initialGenreVisibility; // ★ 追加: 初期状態を保持

  // ★★★ バナー広告関連の変数 ★★★
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  final String _bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7148683667182672/9797170752' // AndroidのテストID
      : 'ca-app-pub-7148683667182672/3020009417'; // iOSのテストID

  @override
  void initState() {
    super.initState();
    _editableGenreOrder = List.from(widget.currentGenreOrder);
    _editableGenreVisibility = Map.from(widget.currentGenreVisibility);

    // ★ 初期状態をディープコピーして保存
    _initialGenreOrder = List.from(widget.currentGenreOrder);
    _initialGenreVisibility = Map.from(widget.currentGenreVisibility);
    _loadBannerAd(); // ★★★ バナー広告をロード ★★★
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // ★★★ バナー広告を破棄 ★★★
    super.dispose();
  }

  // ★★★ バナー広告をロードするメソッド ★★★
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

  // ★ 変更があったかどうかを判定するメソッド
  bool _hasChanges() {
    const listEquality = ListEquality();
    const mapEquality = MapEquality();

    final orderChanged = !listEquality.equals(_editableGenreOrder, _initialGenreOrder);
    final visibilityChanged = !mapEquality.equals(_editableGenreVisibility, _initialGenreVisibility);
    
    return orderChanged || visibilityChanged;
  }

  // ★ 確認ダイアログを表示するメソッド
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

  Future<void> _showBrandInfoDialog(BuildContext context, SearchGenre genre) async {
    final brands = BrandData.getBrandsForGenre(genre);
    final genreName = BrandData.getGenreDisplayName(genre);

    if (brands.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$genreName に登録されているブランドはありません。', style: const TextStyle(color: Colors.white)),
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
          backgroundColor: Colors.black87, // ダークな背景色
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(
            '$genreName のブランド情報',
            style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: brands.length,
              itemBuilder: (BuildContext context, int index) {
                final brandName = brands[index];
                final brandUrl = BrandData.brandTopPageUrls[brandName];
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
                        Text(
                          brandName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          brandDescription,
                          style: TextStyle(color: Colors.white.withOpacity(0.8)),
                        ),
                        if (brandUrl != null && brandUrl.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          InkWell(
                            child: Text(
                              brandUrl,
                              style: TextStyle(
                                color: Colors.blueAccent[100], // 明るいアクセントカラー
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

  @override
  Widget build(BuildContext context) {
    // ★ WillPopScopeでScaffoldをラップ
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
          // ★ AppBarの戻るボタンも onWillPop で処理されるため、特別な対応は不要
          actions: [
            TextButton(
              onPressed: () {
                // 保存時は変更の有無に関わらず結果を返して閉じる
                Navigator.pop(context, {
                  'order': _editableGenreOrder,
                  'visibility': _editableGenreVisibility,
                });
              },
              child: const Text('保存', style: TextStyle(color: Colors.lightBlueAccent, fontSize: 16, )),
        ),]),
        body: Column( // ★★★ ReorderableListViewと広告を縦に並べるためにColumnを追加 ★★★
          children: [
            Expanded( // ★★★ ReorderableListView.builderをExpandedでラップ ★★★
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: _editableGenreOrder.length,
                itemBuilder: (context, index) {
                  final genre = _editableGenreOrder[index];
                  return SwitchListTile(
                    key: ValueKey(genre),
                    tileColor: const Color(0xFF2c2c2e), // タイルの背景色
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
                      });
                    },
                    activeColor: Colors.lightBlueAccent, // スイッチのオンの色
                    inactiveTrackColor: Colors.grey[700],
                    secondary: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.drag_handle, color: Colors.white54),
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
                  });
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
}