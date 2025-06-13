import 'package:flutter/material.dart'; // SearchGenre を使用するために必要に応じてインポート

enum SearchGenre { lifestyle, apparel, outdoor, bag, sports, sneakers }

class BrandData {
  static const List<String> availableLifestyleBrands = ['無印良品', 'イケア', 'ニトリ','seria','Francfranc','LOWYA','ベルメゾン','LOFT','東急ハンズ'];
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
      default:
        return "";
    }
  }
}