import 'package:flutter/material.dart'; // SearchGenre を使用するために必要に応じてインポート

enum SearchGenre {
  lifestyle,
  apparel,
  outdoor,
  bag,
  sports,
  sneakers,
  furniture,
  kitchenware,
  homedecor,
  beddingbath,
  jewelry,
  watches,
  eyewear,
  electronics,
  audiodevices,
  cameras,
  stationery,
  musicalinstruments,
  beauty,
  healthcare,
  petsupplies,
  apparelHighBrand,
  furnitureHighBrand,
  bagHighBrand,
  jewelryHighBrand,
  fitness,
  bicycle,
  bicycleSports,
  vintageClothing,
  antiques,
  streetStyle,
  gyaruStyle,
  japaneseDesigner, // ★ 追加: 日本人デザイナーズブランド
}

class BrandData {
  static const List<String> availableLifestyleBrands = ['無印良品', 'イケア', 'ニトリ','seria','Francfranc','LOWYA','ベルメゾン','LOFT','東急ハンズ', 'ACTUS'];
  static const List<String> availableApparelBrands = ['ユニクロ', 'GU', 'ZARA', 'H&M', 'BEAMS', 'しまむら', 'Right-on', 'GAP', 'アーバンリサーチ', 'ユナイテッドアローズ', 'ナノユニバース', 'ジャーナルスタンダード'];
  static const List<String> availableOutdoorBrands = [
    'コールマン', 'スノーピーク', 'ロゴス', 'モンベル', 'パタゴニア', 'ザ・ノース・フェイス',
    'キャプテンスタッグ', 'DOD', 'ヘリノックス', 'チャムス', 'マムート', 'ミレー'
  ];
  static const List<String> availableBagBrands = [
    'ポーター', 'マンハッタンポーテージ', 'グレゴリー', 'アークテリクス', 'ミステリーランチ',
    'ケルティ', 'オスプレー', 'カリマー', 'ブリーフィング', 'トゥミ'
  ];
  static const List<String> availableSportsBrands = [
    'ナイキ', 'アディダス', 'プーマ', 'アシックス', 'ミズノ',
    'アンダーアーマー', 'ニューバランス', 'デサント', 'ルコックスポルティフ', 'ヨネックス'
  ];
  static const List<String> availableSneakersBrands = [
    'ナイキ', 'アディダス', 'ニューバランス', 'コンバース', 'バンズ',
    'リーボック', 'プーマ', 'アシックス', 'オニツカタイガー', 'サッカニー'
  ];
  // 新しいジャンルのブランドリスト
  static const List<String> availableFurnitureBrands = ['カリモク家具', 'マルニ木工', '天童木工', 'ハーマンミラー', 'ヴィトラ', 'カッシーナ', 'B&B Italia', 'アルフレックス', 'フリッツ・ハンセン', 'イデー'];
  static const List<String> availableKitchenwareBrands = ['ル・クルーゼ', 'ストウブ', 'WMF', 'フィスラー', 'ビタクラフト', 'ツヴィリング J.A. ヘンケルス', 'グローバル', '野田琺瑯', '柳宗理', 'イッタラ'];
  static const List<String> availableHomedecorBrands = ['HAY', 'menu', 'ferm LIVING', 'Normann Copenhagen', 'Muuto', '&Tradition', 'GUBI', 'MOHEIM', 'IDEE', 'ザラホーム'];
  static const List<String> availableBeddingbathBrands = ['西川', 'エアウィーヴ', 'テンピュール', 'シモンズ', 'サータ', 'フランスベッド', '内野', '今治タオル', 'ホットマン', 'テネリータ'];
  static const List<String> availableJewelryBrands = ['ティファニー', 'カルティエ', 'ブルガリ', 'ヴァンクリーフ＆アーペル', 'ハリー・ウィンストン', 'ショパール', 'ブシュロン', 'ミキモト', 'タサキ', '4℃'];
  static const List<String> availableWatchesBrands = ['ロレックス', 'オメガ', 'タグ・ホイヤー', 'ブライトリング', 'IWC', 'セイコー', 'シチズン', 'カシオ', 'グランドセイコー', 'パネライ'];
  static const List<String> availableEyewearBrands = ['レイバン', 'オリバーピープルズ', 'トムフォード', 'アイヴァン', 'フォーナインズ', '金子眼鏡', '白山眼鏡店', 'JINS', 'Zoff', 'OWNDAYS'];
  static const List<String> availableElectronicsBrands = ['パナソニック', 'ソニー', '日立', '三菱電機', 'シャープ', 'ダイソン', 'バルミューダ', 'Apple', 'Samsung', 'LG'];
  static const List<String> availableAudiodevicesBrands = ['ソニー', 'ボーズ', 'ゼンハイザー', 'オーディオテクニカ', 'JBL', 'Bang & Olufsen', 'Shure', 'AKG', 'Beats by Dr. Dre', 'ヤマハ'];
  static const List<String> availableCamerasBrands = ['キヤノン', 'ニコン', 'ソニー', '富士フイルム', 'オリンパス', 'パナソニック', 'ライカ', 'GoPro', 'DJI', 'リコー'];
  static const List<String> availableStationeryBrands = ['コクヨ', 'パイロット', '三菱鉛筆', 'ゼブラ', 'ぺんてる', 'トンボ鉛筆', 'デザインフィル', '伊東屋', 'ロフト', 'キングジム'];
  static const List<String> availableMusicalinstrumentsBrands = ['ヤマハ', 'ローランド', 'コルグ', 'フェンダー', 'ギブソン', 'マーティン', 'パール', 'タマ', 'カワイ', 'スタインウェイ'];
  static const List<String> availableBeautyBrands = ['資生堂', '花王', 'コーセー', 'ポーラ', 'SK-II', 'ランコム', 'エスティローダー', 'シャネル', 'ディオール', 'イヴ・サンローラン'];
  static const List<String> availableHealthcareBrands = ['オムロン', 'タニタ', 'テルモ', 'パナソニック ヘルスケア', 'フィリップス', 'ブラウン', 'ドクターエア', 'シックスパッド', 'ファイテン', 'ガーミン'];
  static const List<String> availablePetsuppliesBrands = ['アイリスオーヤマ', 'ユニ・チャーム ペット', 'いなばペットフード', 'ピュリナ', 'ロイヤルカナン', 'ヒルズ', 'ペティオ', 'ドギーマン', 'リッチェル', 'GEX'];
  static const List<String> availableApparelHighBrandBrands = ['シャネル', 'エルメス', 'ルイ・ヴィトン', 'グッチ', 'プラダ', 'ディオール', 'サンローラン', 'バレンシアガ', 'セリーヌ', 'フェンディ'];
  static const List<String> availableFurnitureHighBrandBrands = ['カッシーナ', 'B&B Italia', 'ポリフォーム', 'アルフレックス', 'ミノッティ', 'フレックスフォルム', 'デパドヴァ', 'ポルトローナ・フラウ', 'リーン・ロゼ', 'フリッツ・ハンセン'];
  static const List<String> availableBagHighBrandBrands = ['エルメス', 'シャネル', 'ルイ・ヴィトン', 'グッチ', 'プラダ', 'セリーヌ', 'ロエベ', 'ゴヤール', 'デルヴォー', 'ヴァレクストラ'];
  static const List<String> availableJewelryHighBrandBrands = ['ハリー・ウィンストン', 'ヴァンクリーフ＆アーペル', 'カルティエ', 'ブルガリ', 'ティファニー', 'ショパール', 'グラフ', 'ブシュロン', 'ピアジェ', 'ショーメ'];
  static const List<String> availableFitnessBrands = ['ルルレモン', 'ナイキ', 'アディダス', 'アンダーアーマー', 'リーボック', 'ゴールドジム', 'MYPROTEIN', 'DNS', 'SAVAS', 'VALX'];
  static const List<String> availableBicycleBrands = ['ジャイアント', 'トレック', 'スペシャライズド', 'ビアンキ', 'キャノンデール', 'スコット', 'ピナレロ', 'サーヴェロ', 'コルナゴ', 'メリダ'];
  static const List<String> availableBicycleSportsBrands = ['シマノ', 'カンパニョーロ', 'SRAM', 'マヴィック', 'DT Swiss', 'ZIPP', 'エンヴィ', 'フルクラム', 'ボントレガー', 'オークリー'];

  // ★ ヴィンテージ古着ショップリスト
  static const List<String> availableVintageClothingShops = [
    'BerBerJin', 'JANTIQUES', 'Santa Monica', 'KINJI', 'WEGO VINTAGE',
    'FLAMINGO', 'NEW YORK JOE EXCHANGE', 'RAGTAG', 'Desert Snow', 'Pigsty'
  ];

  // ★ アンティークショップリスト
  static const List<String> availableAntiquesShops = [
    'THE GLOBE ANTIQUES', "Lloyd's Antiques", 'DEMODE KEY STATION', 'ANTRO', 'CEROTE ANTIQUES',
    'PTAH', 'GALLUP', 'アンティークモール銀座', 'BROCANTE', 'Found'
  ];

  // ★ ストリートブランドリスト
  static const List<String> availableStreetStyleBrands = [
    'Supreme', 'Stussy', 'A BATHING APE', 'Off-White', 'Palace Skateboards',
    'KITH', 'HUF', 'Carhartt WIP', 'X-LARGE', 'Undefeated'
  ];

  // ★ ギャル系ブランドリスト
  static const List<String> availableGyaruStyleBrands = [
    'CECIL McBEE', 'EGOIST', 'rienda', 'LIP SERVICE', 'Delyle NOIR',
    'DaTuRa', 'RESEXXY', 'GYDA', 'MOUSSY', 'SLY'
  ];

  // ★ 日本人デザイナーズブランドリスト
  static const List<String> availableJapaneseDesignerBrands = [
    'COMME des GARÇONS', 'Yohji Yamamoto', 'ISSEY MIYAKE', 'sacai', 'UNDERCOVER',
    'TOGA', 'beautiful people', 'kolor', 'N.HOOLYWOOD', 'White Mountaineering',
    'HYKE', 'Mame Kurogouchi'
  ];


  static const Map<String, String> brandTopPageUrls = {
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
    'ACTUS': 'https://www.actus-interior.com/',
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

    // 家具
    'カリモク家具': 'https://www.karimoku.co.jp/',
    'マルニ木工': 'https://www.maruni.com/jp/',
    '天童木工': 'https://www.tendo-mokko.co.jp/',
    'ハーマンミラー': 'https://www.hermanmiller.com/ja_jp/',
    'ヴィトラ': 'https://www.vitra.com/ja-jp/',
    'カッシーナ': 'https://www.cassina-ixc.jp/',
    'B&B Italia': 'https://www.bebitalia.com/ja',
    'アルフレックス': 'https://www.arflex.co.jp/',
    'フリッツ・ハンセン': 'https://fritzhansen.com/ja-JP',
    'イデー': 'https://www.idee-online.com/',
    // キッチン用品
    'ル・クルーゼ': 'https://www.lecreuset.co.jp/',
    'ストウブ': 'https://www.staub-online.com/jp/',
    'WMF': 'https://www.wmf.co.jp/',
    'フィスラー': 'https://www.fissler.com/jp/',
    'ビタクラフト': 'https://www.vitacraft.co.jp/',
    'ツヴィリング J.A. ヘンケルス': 'https://www.zwilling.com/jp/',
    'グローバル': 'https://www.yoshikin.co.jp/global/',
    '野田琺瑯': 'https://www.nodahoro.com/',
    '柳宗理': 'https://www.yanagi-support.jp/', // 公式が見つからず、サポートページ
    'イッタラ': 'https://www.iittala.jp/',
    // インテリア雑貨
    'HAY': 'https://www.hay-japan.com/',
    'menu': 'https://menuspace.com/',
    'ferm LIVING': 'https://fermliving.com/',
    'Normann Copenhagen': 'https://www.normann-copenhagen.com/',
    'Muuto': 'https://muuto.com/',
    '&Tradition': 'https://www.andtradition.com/',
    'GUBI': 'https://gubi.com/',
    'MOHEIM': 'https://moheim.com/',
    // 'IDEE' は家具と重複
    'ザラホーム': 'https://www.zarahome.com/jp/',
    // 寝具・バス用品
    '西川': 'https://www.nishikawa1566.com/',
    'エアウィーヴ': 'https://airweave.jp/',
    'テンピュール': 'https://jp.tempur.com/',
    'シモンズ': 'https://www.simmons.co.jp/',
    'サータ': 'https://www.serta-japan.jp/',
    'フランスベッド': 'https://www.francebed.co.jp/',
    '内野': 'https://uchino.shop/',
    '今治タオル': 'https://imabaritowel.jp/', // ポータルサイト
    'ホットマン': 'https://hotman.co.jp/',
    'テネリータ': 'https://www.tenerita.com/',
    // ジュエリー
    'ティファニー': 'https://www.tiffany.co.jp/',
    'カルティエ': 'https://www.cartier.jp/',
    'ブルガリ': 'https://www.bulgari.com/ja-jp/',
    'ヴァンクリーフ＆アーペル': 'https://www.vancleefarpels.com/jp/ja.html',
    'ハリー・ウィンストン': 'https://www.harrywinston.com/ja',
    'ショパール': 'https://www.chopard.jp/',
    'ブシュロン': 'https://www.boucheron.com/ja_jp/',
    'ミキモト': 'https://www.mikimoto.com/',
    'タサキ': 'https://www.tasaki.co.jp/',
    '4℃': 'https://www.fdcp.co.jp/4c/',
    // 腕時計
    'ロレックス': 'https://www.rolex.com/ja',
    'オメガ': 'https://www.omegawatches.jp/',
    'タグ・ホイヤー': 'https://www.tagheuer.com/jp/ja/',
    'ブライトリング': 'https://www.breitling.com/jp-ja/',
    'IWC': 'https://www.iwc.com/jp/ja.html',
    'セイコー': 'https://www.seikowatches.com/jp-ja',
    'シチズン': 'https://citizen.jp/',
    'カシオ': 'https://www.casio.com/jp/',
    'グランドセイコー': 'https://www.grand-seiko.com/jp-ja',
    'パネライ': 'https://www.panerai.com/jp/ja/home.html',
    // メガネ・サングラス
    'レイバン': 'https://www.ray-ban.com/japan',
    'オリバーピープルズ': 'https://oliverpeoples.jp/',
    'トムフォード': 'https://www.tomford.com/eyewear/', // グローバルサイト
    'アイヴァン': 'https://eyevan.com/',
    'フォーナインズ': 'https://www.fournines.co.jp/',
    '金子眼鏡': 'https://www.kaneko-optical.co.jp/',
    '白山眼鏡店': 'https://hakusan-megane.co.jp/',
    'JINS': 'https://www.jins.com/jp/',
    'Zoff': 'https://www.zoff.co.jp/',
    'OWNDAYS': 'https://www.owndays.com/jp/ja',
    // 家電
    'パナソニック': 'https://panasonic.jp/',
    'ソニー': 'https://www.sony.jp/',
    '日立': 'https://www.hitachi.co.jp/products/electronics/',
    '三菱電機': 'https://www.mitsubishielectric.co.jp/home/',
    'シャープ': 'https://jp.sharp/',
    'ダイソン': 'https://www.dyson.co.jp/',
    'バルミューダ': 'https://www.balmuda.com/',
    'Apple': 'https://www.apple.com/jp/',
    'Samsung': 'https://www.samsung.com/jp/',
    'LG': 'https://www.lg.com/jp',
    // オーディオ機器
    // 'ソニー' は家電と重複
    'ボーズ': 'https://www.bose.co.jp/',
    'ゼンハイザー': 'https://www.sennheiser.com/ja-jp',
    'オーディオテクニカ': 'https://www.audio-technica.co.jp/',
    'JBL': 'https://jp.jbl.com/',
    'Bang & Olufsen': 'https://www.bang-olufsen.com/ja/jp',
    'Shure': 'https://www.shure.com/ja-JP',
    'AKG': 'https://jp.akg.com/',
    'Beats by Dr. Dre': 'https://www.beatsbydre.com/jp',
    'ヤマハ': 'https://jp.yamaha.com/products/audio_visual/',
    // カメラ
    'キヤノン': 'https://canon.jp/',
    'ニコン': 'https://www.nikon-image.com/products/',
    // 'ソニー' は家電と重複
    '富士フイルム': 'https://fujifilm-x.com/ja-jp/',
    'オリンパス': 'https://om-systems.com/ja-jp/', // OMデジタルソリューションズ
    // 'パナソニック' は家電と重複
    'ライカ': 'https://leica-camera.com/ja-JP',
    'GoPro': 'https://gopro.com/ja/jp/',
    'DJI': 'https://www.dji.com/jp',
    'リコー': 'https://www.ricoh-imaging.co.jp/japan/',
    // 文房具
    'コクヨ': 'https://www.kokuyo.co.jp/',
    'パイロット': 'https://www.pilot.co.jp/',
    '三菱鉛筆': 'https://www.mpuni.co.jp/',
    'ゼブラ': 'https://www.zebra.co.jp/',
    'ぺんてる': 'https://www.pentel.co.jp/',
    'トンボ鉛筆': 'https://www.tombow.com/products/',
    'デザインフィル': 'https://www.designphil.co.jp/', // ミドリなど
    '伊東屋': 'https://www.ito-ya.co.jp/',
    // 'ロフト' は生活雑貨と重複
    'キングジム': 'https://www.kingjim.co.jp/',
    // 楽器
    // 'ヤマハ' はオーディオ機器と重複
    'ローランド': 'https://www.roland.com/jp/',
    'コルグ': 'https://www.korg.com/jp/',
    'フェンダー': 'https://www.fender.com/ja-JP/',
    'ギブソン': 'https://www.gibson.com/ja-JP/',
    'マーティン': 'https://www.martinclubjp.com/guitar/', // 日本のファンクラブサイト
    'パール': 'https://pearldrum.com/',
    'タマ': 'https://www.tama.com/jp/',
    'カワイ': 'https://www.kawai.jp/',
    'スタインウェイ': 'https://www.steinway.co.jp/',
    // コスメ・美容
    '資生堂': 'https://www.shiseido.co.jp/',
    '花王': 'https://www.kao.com/jp/', // ソフィーナなど
    'コーセー': 'https://www.kose.co.jp/',
    'ポーラ': 'https://www.pola.co.jp/',
    'SK-II': 'https://www.sk-ii.jp/',
    'ランコム': 'https://www.lancome.jp/',
    'エスティローダー': 'https://www.esteelauder.jp/',
    'シャネル': 'https://www.chanel.com/ja_JP/fragrance-beauty/',
    'ディオール': 'https://www.dior.com/ja_jp/beauty',
    'イヴ・サンローラン': 'https://www.yslb.jp/',
    // ヘルスケア用品
    'オムロン': 'https://www.healthcare.omron.co.jp/',
    'タニタ': 'https://www.tanita.co.jp/',
    'テルモ': 'https://www.terumo.co.jp/consumer/',
    'パナソニック ヘルスケア': 'https://panasonic.jp/health/', // パナソニックのヘルスケア製品
    'フィリップス': 'https://www.philips.co.jp/c-m-hs/health-care',
    'ブラウン': 'https://www.braun.jp/',
    'ドクターエア': 'https://www.dr-air.com/',
    'シックスパッド': 'https://www.mtgec.jp/wellness/sixpad/',
    'ファイテン': 'https://www.phiten.com/',
    'ガーミン': 'https://www.garmin.co.jp/',
    // ペット用品
    'アイリスオーヤマ': 'https://www.irisohyama.co.jp/pet/',
    'ユニ・チャーム ペット': 'https://jp.unicharmpet.com/',
    'いなばペットフード': 'https://www.inaba-petfood.co.jp/',
    'ピュリナ': 'https://nestle.jp/brand/purina/',
    'ロイヤルカナン': 'https://www.royalcanin.com/jp',
    'ヒルズ': 'https://www.hills.co.jp/',
    'ペティオ': 'https://www.petio.com/',
    'ドギーマン': 'https://www.doggyman.com/',
    'リッチェル': 'https://www.richell.co.jp/pet/',
    'GEX': 'https://www.gex-fp.co.jp/',
    // アパレル（ハイブランド）
    // 'シャネル', 'ディオール' はコスメ・美容と重複
    'エルメス': 'https://www.hermes.com/jp/ja/',
    'ルイ・ヴィトン': 'https://jp.louisvuitton.com/jpn-jp/homepage',
    'グッチ': 'https://www.gucci.com/jp/ja/',
    'プラダ': 'https://www.prada.com/jp/ja.html',
    'サンローラン': 'https://www.ysl.com/ja-jp',
    'バレンシアガ': 'https://www.balenciaga.com/ja-jp',
    'セリーヌ': 'https://www.celine.com/ja-jp/',
    'フェンディ': 'https://www.fendi.com/jp-ja/',
    // 家具ハイブランド
    // 'カッシーナ', 'B&B Italia', 'アルフレックス', 'フリッツ・ハンセン' は家具と重複
    'ポリフォーム': 'https://www.poliform.it/ja/',
    'ミノッティ': 'https://www.minotti.com/',
    'フレックスフォルム': 'https://www.flexform.it/ja',
    'デパドヴァ': 'https://www.depadova.com/ja/',
    'ポルトローナ・フラウ': 'https://www.poltronafrau.com/ja',
    'リーン・ロゼ': 'https://www.ligne-roset.jp/',
    // バッグハイブランド
    // 'エルメス', 'シャネル', 'ルイ・ヴィトン', 'グッチ', 'プラダ', 'セリーヌ' はアパレル（ハイブランド）と重複
    'ロエベ': 'https://www.loewe.com/jap/ja/home',
    'ゴヤール': 'https://www.goyard.com/jp_ja/',
    'デルヴォー': 'https://www.delvaux.com/ja/',
    'ヴァレクストラ': 'https://www.valextra.jp/',
    // ジュエリーハイブランド
    // 'ハリー・ウィンストン', 'ヴァンクリーフ＆アーペル', 'カルティエ', 'ブルガリ', 'ティファニー', 'ショパール', 'ブシュロン' はジュエリーと重複
    'グラフ': 'https://www.graff.com/jp-ja/home/',
    'ピアジェ': 'https://www.piaget.com/jp-ja',
    'ショーメ': 'https://www.chaumet.com/jp_ja',
    // フィットネス
    'ルルレモン': 'https://www.lululemon.co.jp/',
    // 'ナイキ', 'アディダス', 'アンダーアーマー', 'リーボック' はスポーツと重複
    'ゴールドジム': 'https://www.goldsgym.jp/', // 用品販売もあり
    'MYPROTEIN': 'https://www.myprotein.jp/',
    'DNS': 'https://www.dnszone.jp/',
    'SAVAS': 'https://www.meiji.co.jp/sports/savas/',
    'VALX': 'https://valx.jp/',
    // 自転車
    'ジャイアント': 'https://www.giant.co.jp/',
    'トレック': 'https://www.trekbikes.com/jp/ja_JP/',
    'スペシャライズド': 'https://www.specialized.com/jp/ja/',
    'ビアンキ': 'https://www.japan.bianchi.com/',
    'キャノンデール': 'https://www.cannondale.com/ja-jp',
    'スコット': 'https://www.scott-japan.com/',
    'ピナレロ': 'https://pinarello.com/japan/',
    'サーヴェロ': 'https://cervelo.com/ja_JP/',
    'コルナゴ': 'https://www.colnago.co.jp/',
    'メリダ': 'https://www.merida.jp/',
    // 自転車（スポーツ）
    'シマノ': 'https://bike.shimano.com/ja-JP/home.html',
    'カンパニョーロ': 'https://www.campagnolo.com/JP/ja/',
    'SRAM': 'https://www.sram.com/en/sram',
    'マヴィック': 'https://www.mavic.com/ja-jp',
    'DT Swiss': 'https://www.dtswiss.com/en/',
    'ZIPP': 'https://www.sram.com/en/zipp',
    'エンヴィ': 'https://www.enve.com/',
    'フルクラム': 'https://www.fulcrumwheels.com/ja',
    'ボントレガー': 'https://www.trekbikes.com/jp/ja_JP/bontrager/',
    'オークリー': 'https://www.oakley.com/ja-jp',

    // ★ ヴィンテージ古着ショップ
    'BerBerJin': 'https://berberjin.com/',
    'JANTIQUES': 'https://jantiques05.buyshop.jp/', // 内田商店オンライン
    'Santa Monica': 'https://www.harajuku-santamonica.com/',
    'KINJI': 'https://www.kinji.jp/',
    'WEGO VINTAGE': 'https://wego.jp/collections/vintage', // WEGOオンラインのヴィンテージカテゴリ
    'FLAMINGO': 'https://www.flamingo-online.jp/',
    'NEW YORK JOE EXCHANGE': 'https://newyorkjoeexchange.com/',
    'RAGTAG': 'https://www.ragtag.jp/',
    'Desert Snow': 'https://desertsnow.jp/',
    'Pigsty': 'https://pigsty-web.com/',

    // ★ アンティークショップ
    'THE GLOBE ANTIQUES': 'https://www.globe-antiques.com/',
    "Lloyd's Antiques": 'https://www.lloyds.co.jp/',
    'DEMODE KEY STATION': 'https://demode-key.com/', // KEY STATION (福生など)
    'ANTRO': 'https://antro.jp/',
    'CEROTE ANTIQUES': 'https://cerote-antiques.com/',
    'PTAH': 'http://ptah.jp/', // 公式サイトがシンプルなため注意
    'GALLUP': 'https://www.thegallup.com/', // ショールーム
    'アンティークモール銀座': 'https://www.antiques-jp.com/',
    'BROCANTE': 'https://brocante-jp.com/', // 自由が丘など
    'Found': 'https://www.found-f.com/',

    // ★ 日本人デザイナーズブランド
    'COMME des GARÇONS': 'https://www.comme-des-garcons.com/',
    'Yohji Yamamoto': 'https://www.yohjiyamamoto.co.jp/',
    'ISSEY MIYAKE': 'https://www.isseymiyake.com/',
    'sacai': 'https://www.sacai.jp/',
    'UNDERCOVER': 'https://undercoverism.com/',
    'TOGA': 'https://toga.jp/',
    'beautiful people': 'https://beautiful-people.jp/',
    'kolor': 'https://kolor.jp/',
    'N.HOOLYWOOD': 'https://n-hoolywood.com/',
    'White Mountaineering': 'https://whitemountaineering.com/',
    'HYKE': 'https://hyke.jp/',
    'Mame Kurogouchi': 'https://www.mamekurogouchi.com/',
  };

  static String getGenreDisplayName(SearchGenre genre) {
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
      case SearchGenre.furniture:
        return "家具";
      case SearchGenre.kitchenware:
        return "キッチン用品";
      case SearchGenre.homedecor:
        return "インテリア雑貨";
      case SearchGenre.beddingbath:
        return "寝具・バス用品";
      case SearchGenre.jewelry:
        return "ジュエリー";
      case SearchGenre.watches:
        return "腕時計";
      case SearchGenre.eyewear:
        return "メガネ・サングラス";
      case SearchGenre.electronics:
        return "家電";
      case SearchGenre.audiodevices:
        return "オーディオ機器";
      case SearchGenre.cameras:
        return "カメラ";
      case SearchGenre.stationery:
        return "文房具";
      case SearchGenre.musicalinstruments:
        return "楽器";
      case SearchGenre.beauty:
        return "コスメ・美容";
      case SearchGenre.healthcare:
        return "ヘルスケア用品";
      case SearchGenre.petsupplies:
        return "ペット用品";
      case SearchGenre.apparelHighBrand:
        return "アパレル（ハイブランド）";
      case SearchGenre.furnitureHighBrand:
        return "家具（ハイブランド）";
      case SearchGenre.bagHighBrand:
        return "バッグ（ハイブランド）";
      case SearchGenre.jewelryHighBrand:
        return "ジュエリー（ハイブランド）";
      case SearchGenre.fitness:
        return "フィットネス";
      case SearchGenre.bicycle:
        return "自転車";
      case SearchGenre.bicycleSports:
        return "自転車（スポーツ）";
      case SearchGenre.vintageClothing: // ★ 追加
        return "ヴィンテージ古着";
      case SearchGenre.antiques: // ★ 追加
        return "アンティーク";
      case SearchGenre.streetStyle: // ★ 追加
        return "ストリート";
      case SearchGenre.gyaruStyle: // ★ 追加
        return "ギャル系";
      case SearchGenre.japaneseDesigner: // ★ 追加
        return "日本人デザイナーズ";
      default:
        return "";
    }
  }
}