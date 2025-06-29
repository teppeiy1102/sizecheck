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
  japaneseDesigner,
}

/// ブランドの詳細情報を格納するクラス
class BrandInfo {
  final String name;
  final String description;
  final String url;
  final int? foundationYear;
  final String? founder;
  final String? country;
  final String? city;

  const BrandInfo({
    required this.name,
    required this.description,
    this.url = '',
    this.foundationYear,
    this.founder,
    this.country,
    this.city,
  });

  /// 創業年代 (例: 1980, 1990) を計算して返す
  int? get foundationDecade {
    if (foundationYear == null) return null;
    return (foundationYear! ~/ 10) * 10;
  }
}

class BrandData {
  /// 全てのブランド情報をここで一元管理
  /// 

  /// ブランド名からジャンルを取得する
  static SearchGenre? getGenreForBrand(String brandName) {
    for (final genre in SearchGenre.values) {
      final brands = getBrandNamesForGenre(genre);
      if (brands.contains(brandName)) {
        return genre;
      }
    }
    return null;
  }
  static final Map<String, BrandInfo> allBrands = {
    // lifestyle
    '無印良品': BrandInfo(
        name: '無印良品',
        description: '日本発のライフスタイルブランド。1980年設立。シンプルで高品質な衣料品、生活雑貨、食品などを展開。',
        url: 'https://www.muji.com/jp/ja/store',
        foundationYear: 1980,
        country: '日本'),
    'イケア': BrandInfo(
        name: 'イケア',
        description: 'スウェーデン発祥の世界最大の家具小売業者。1943年イングヴァル・カンプラードにより創業。',
        url: 'https://www.ikea.com/jp/ja/',
        foundationYear: 1943,
        founder: 'イングヴァル・カンプラード',
        country: 'スウェーデン'),
    'ニトリ': BrandInfo(
        name: 'ニトリ',
        description: '北海道札幌市発祥の家具・インテリア用品小売業大手。1967年創業。「お、ねだん以上。」のキャッチコピーで知られる。',
        url: 'https://www.nitori-net.jp/ec/',
        foundationYear: 1967,
        country: '日本',
        city: '北海道札幌市'),
    'seria': BrandInfo(
        name: 'seria',
        description: '岐阜県大垣市発祥の100円ショップチェーン。「Color the days 日常を彩る」をコンセプトに、デザイン性の高い商品を提供。',
        url: 'https://www.seria-group.com/',
        foundationYear: 1987,
        country: '日本',
        city: '岐阜県大垣市'),
    'Francfranc': BrandInfo(
        name: 'Francfranc',
        description: '日本発のインテリア・雑貨ブランド。1992年設立。カジュアルスタイリッシュをコンセプトに、家具から雑貨まで幅広く展開。',
        url: 'https://francfranc.com/',
        foundationYear: 1992,
        country: '日本'),
    'LOWYA': BrandInfo(
        name: 'LOWYA',
        description: '福岡県発の家具・インテリアのECブランド。2004年創業。トレンドを取り入れたデザイン性の高い商品を低価格で提供。',
        url: 'https://www.low-ya.com/',
        foundationYear: 2004,
        country: '日本',
        city: '福岡県'),
    'ベルメゾン': BrandInfo(
        name: 'ベルメゾン',
        description: '千趣会が運営する通販ブランド。1976年創刊。ファッション、インテリア、雑貨など女性をターゲットにした幅広い商品が特徴。',
        url: 'https://www.bellemaison.jp/',
        foundationYear: 1976,
        country: '日本'),
    'LOFT': BrandInfo(
        name: 'LOFT',
        description: '日本の生活雑貨専門店。1987年渋谷に1号店オープン。「時の器」をコンセプトに、文具、コスメ、家庭用品などを扱う。',
        url: 'https://www.loft.co.jp/store/',
        foundationYear: 1987,
        country: '日本'),
    '東急ハンズ': BrandInfo(
        name: '東急ハンズ',
        description: '日本の生活雑貨・DIY用品小売店。1976年創業。「ここは、ヒント・マーケット。」をコンセプトに、多彩な商品を取り揃える。現在はハンズとして営業。',
        url: 'https://hands.net/',
        foundationYear: 1976,
        country: '日本'),
    'ACTUS': BrandInfo(
        name: 'ACTUS',
        description: '日本のインテリアショップ。1969年創業。ヨーロッパのモダン家具を中心に、質の高いライフスタイルを提案。',
        url: 'https://www.actus-interior.com/',
        foundationYear: 1969,
        country: '日本'),

    // apparel
    'ユニクロ': BrandInfo(
        name: 'ユニクロ',
        description: '山口県発祥のファーストリテイリング傘下ブランド。1984年に1号店オープン。LifeWearがコンセプト。',
        url: 'https://www.uniqlo.com/jp/ja/',
        foundationYear: 1984,
        country: '日本',
        city: '山口県'),
    'GU': BrandInfo(
        name: 'GU',
        description: 'ユニクロの姉妹ブランド。2006年設立。より低価格でトレンド性の高いファッションを提供。',
        url: 'https://www.gu-global.com/jp/ja/',
        foundationYear: 2006,
        country: '日本'),
    'ZARA': BrandInfo(
        name: 'ZARA',
        description: 'スペイン発のアパレルブランド。1975年アマンシオ・オルテガにより創業。ファストファッションの代表格。',
        url: 'https://www.zara.com/jp/',
        foundationYear: 1975,
        founder: 'アマンシオ・オルテガ',
        country: 'スペイン'),
    'H&M': BrandInfo(
        name: 'H&M',
        description: 'スウェーデン発の世界的なアパレルブランド。1947年設立。トレンド性の高い商品をリーズナブルな価格で提供するファストファッションの代表格。',
        url: 'https://www2.hm.com/ja_jp/index.html',
        foundationYear: 1947,
        country: 'スウェーデン'),
    'BEAMS': BrandInfo(
        name: 'BEAMS',
        description: '日本のセレクトショップおよびオリジナルブランド。1976年創業。ファッションから雑貨、カルチャーまで、時代のニーズに応える多彩な商品を展開。',
        url: 'https://www.beams.co.jp/',
        foundationYear: 1976,
        country: '日本'),
    'しまむら': BrandInfo(
        name: 'しまむら',
        description: '埼玉県発祥の衣料品チェーンストア。1953年設立。低価格で幅広い世代向けのファッションアイテムを提供し、「しまパト」の愛称で親しまれる。',
        url: 'https://www.shimamura.gr.jp/shimamura/',
        foundationYear: 1953,
        country: '日本',
        city: '埼玉県'),
    'Right-on': BrandInfo(
        name: 'Right-on',
        description: 'ジーンズを中心としたセレクトショップ。1980年創業。国内外の有名ジーンズブランドやオリジナルウェアを豊富に取り揃える。',
        url: 'https://right-on.co.jp/',
        foundationYear: 1980,
        country: '日本'),
    'GAP': BrandInfo(
        name: 'GAP',
        description: 'アメリカ・サンフランシスコ発のアパレルブランド。1969年創業。デニムやロゴアイテムが象徴的なアメリカンカジュアルの代表格。',
        url: 'https://www.gap.co.jp/',
        foundationYear: 1969,
        country: 'アメリカ',
        city: 'サンフランシスコ'),
    'アーバンリサーチ': BrandInfo(
        name: 'アーバンリサーチ',
        description: '日本のセレクトショップ。1997年創業。「すごいをシェアする」をコンセプトに、都会的で洗練されたカジュアルウェアを提案。',
        url: 'https://www.urban-research.jp/',
        foundationYear: 1997,
        country: '日本'),
    'ユナイテッドアローズ': BrandInfo(
        name: 'ユナイテッドアローズ',
        description: '日本を代表するセレクトショップ。1989年創業。「豊かさ・上質感」をキーワードに、国内外からセレクトしたアイテムとオリジナルブランドを展開。',
        url: 'https://store.united-arrows.co.jp/',
        foundationYear: 1989,
        country: '日本'),
    'ナノユニバース': BrandInfo(
        name: 'ナノユニバース',
        description: '日本のセレクトショップ。1999年創業。ヨーロピアンテイストを基に、トレンドを取り入れたモダンで洗練されたスタイルを提案。',
        url: 'https://store.nanouniverse.jp/',
        foundationYear: 1999,
        country: '日本'),
    'ジャーナルスタンダード': BrandInfo(
        name: 'ジャーナルスタンダード',
        description: 'ベイクルーズグループが展開するセレクトショップ。1997年創業。アメリカンカジュアルをベースに、国内外の旬なブランドをミックスしたスタイルを提案。',
        url: 'https://baycrews.jp/brand/detail/journalstandard',
        foundationYear: 1997,
        country: '日本'),

    // outdoor
    'コールマン': BrandInfo(
        name: 'コールマン',
        description: 'アメリカ発のアウトドア用品メーカー。1900年創業。ランタンから始まり、キャンプ用品全般で有名。',
        url: 'https://www.coleman.co.jp/',
        foundationYear: 1900,
        country: 'アメリカ'),
    'スノーピーク': BrandInfo(
        name: 'スノーピーク',
        description: '新潟県三条市発のアウトドア総合メーカー。1958年創業。高品質でデザイン性の高い製品が特徴。',
        url: 'https://www.snowpeak.co.jp/',
        foundationYear: 1958,
        country: '日本',
        city: '新潟県三条市'),
    'ロゴス': BrandInfo(
        name: 'ロゴス',
        description: '日本のアウトドア総合ブランド。1985年設立。「水辺5メートルから標高800メートルまで」をコンセプトに、家族で楽しめるキャンプ用品を開発。',
        url: 'https://www.logos.ne.jp/',
        foundationYear: 1985,
        country: '日本'),
    'モンベル': BrandInfo(
        name: 'モンベル',
        description: '大阪府発の日本を代表するアウトドア総合メーカー。1975年辰野勇により創業。「Function is Beauty」をコンセプトに、高品質な製品を製造。',
        url: 'https://www.montbell.jp/',
        foundationYear: 1975,
        founder: '辰野勇',
        country: '日本',
        city: '大阪府'),
    'パタゴニア': BrandInfo(
        name: 'パタゴニア',
        description: 'アメリカのアウトドアウェアブランド。1973年イヴォン・シュイナードにより創業。高品質な製品と徹底した環境保護活動で世界的に有名。',
        url: 'https://www.patagonia.jp/',
        foundationYear: 1973,
        founder: 'イヴォン・シュイナード',
        country: 'アメリカ'),
    'ザ・ノース・フェイス': BrandInfo(
        name: 'ザ・ノース・フェイス',
        description: 'アメリカ・カリフォルニア発のアウトドアブランド。1966年創業。過酷な自然環境に対応する高機能な製品で、アウトドアからタウンユースまで絶大な支持を得る。',
        url: 'https://www.goldwin.co.jp/tnf/',
        foundationYear: 1966,
        country: 'アメリカ',
        city: 'カリフォルニア'),
    'キャプテンスタッグ': BrandInfo(
        name: 'キャプテンスタッグ',
        description: '新潟県三条市発のアウトドア用品総合ブランド。1976年設立。鹿のロゴが特徴で、使いやすさと手頃な価格で人気。',
        url: 'https://www.captainstag.net/',
        foundationYear: 1976,
        country: '日本',
        city: '新潟県三条市'),
    'DOD': BrandInfo(
        name: 'DOD',
        description: '大阪府のビーズ株式会社が展開するアウトドア用品ブランド。2008年設立。ユニークなネーミングとデザインで、新しいキャンプスタイルを提案。',
        url: 'https://www.dod.camp/',
        foundationYear: 2008,
        country: '日本',
        city: '大阪府'),
    'ヘリノックス': BrandInfo(
        name: 'ヘリノックス',
        description: '韓国発のアウトドアファニチャーブランド。DAC社の技術力を背景に、軽量かつ高強度なチェアやコットで世界的に評価されている。',
        url: 'https://www.helinox.jp/',
        country: '韓国'),
    'チャムス': BrandInfo(
        name: 'チャムス',
        description: 'アメリカ・ユタ州発のアウトドアカジュアルブランド。1983年創業。ペンギンに似た「ブービーバード」のロゴが特徴で、カラフルで楽しいデザインが人気。',
        url: 'https://www.chums.jp/',
        foundationYear: 1983,
        country: 'アメリカ',
        city: 'ユタ州'),
    'マムート': BrandInfo(
        name: 'マムート',
        description: 'スイス発の登山・アウトドア用品ブランド。1862年創業。ロープ製造から始まり、安全性と機能性に優れたウェアやギアを展開。',
        url: 'https://www.mammut.jp/',
        foundationYear: 1862,
        country: 'スイス'),
    'ミレー': BrandInfo(
        name: 'ミレー',
        description: 'フランス発の登山・アウトドア用品ブランド。1921年創業。世界で初めてアルピニスト向けバックパックを開発したことで知られる。',
        url: 'https://www.millet.jp/',
        foundationYear: 1921,
        country: 'フランス'),

    // bag
    'ポーター': BrandInfo(
        name: 'ポーター',
        description: '日本のカバンメーカー吉田カバンのメインブランド。1962年発表。創業は1935年。日本製にこだわり高品質。',
        url: 'https://www.yoshidakaban.com/product/search_result.html?p_series=&p_lisence_id=1&p_keywd=',
        foundationYear: 1962,
        country: '日本'),
    'マンハッタンポーテージ': BrandInfo(
        name: 'マンハッタンポーテージ',
        description: 'アメリカニューヨーク発のバッグブランド。1983年創業。赤いロゴが特徴的で、メッセンジャーバッグが有名。',
        url: 'https://www.manhattanportage.co.jp/',
        foundationYear: 1983,
        country: 'アメリカ',
        city: 'ニューヨーク'),
    'グレゴリー': BrandInfo(
        name: 'グレゴリー',
        description: 'アメリカ発のバックパック専門ブランド。1977年ウェイン・グレゴリーにより創業。「背負うのではなく、着る」と称されるほどの快適なフィット感が特徴。',
        url: 'https://www.gregory.jp/',
        foundationYear: 1977,
        founder: 'ウェイン・グレゴリー',
        country: 'アメリカ'),
    'アークテリクス': BrandInfo(
        name: 'アークテリクス',
        description: 'カナダ・バンクーバー発のアウトドアブランド。1989年創業。始祖鳥の化石のロゴが特徴で、革新的な技術と最高品質の素材を用いた製品で知られる。',
        url: 'https://arcteryx.jp/',
        foundationYear: 1989,
        country: 'カナダ',
        city: 'バンクーバー'),
    'ミステリーランチ': BrandInfo(
        name: 'ミステリーランチ',
        description: 'アメリカ・モンタナ州発のバックパックブランド。2000年創業。米軍特殊部隊にも採用されるほどの耐久性と機能性を誇る。',
        url: 'https://www.mysteryranch.jp/',
        foundationYear: 2000,
        country: 'アメリカ',
        city: 'モンタナ州'),
    'ケルティ': BrandInfo(
        name: 'ケルティ',
        description: 'アメリカのアウトドアブランド。1952年ディック・ケルティにより創業。バックパックの原型を築いたブランドとして知られる。',
        url: 'https://www.kelty.co.jp/',
        foundationYear: 1952,
        founder: 'ディック・ケルティ',
        country: 'アメリカ'),
    'オスプレー': BrandInfo(
        name: 'オスプレー',
        description: 'アメリカ・コロラド州発のバックパック専門ブランド。1974年創業。ユーザーの身体に合わせたカスタムフィッティングシステムで高い評価を得る。',
        url: 'https://www.osprey.com/jp/ja/',
        foundationYear: 1974,
        country: 'アメリカ',
        city: 'コロラド州'),
    'カリマー': BrandInfo(
        name: 'カリマー',
        description: 'イギリス発のアウトドアブランド。1946年創業。アルピニズム発祥の国ならではの、タフで機能的なリュックサックが有名。',
        url: 'https://www.karrimor.jp/',
        foundationYear: 1946,
        country: 'イギリス'),
    'ブリーフィング': BrandInfo(
        name: 'ブリーフィング',
        description: '日本企画・アメリカ生産のラゲッジブランド。1998年誕生。ミルスペックに準拠した強靭な素材と、都会的なデザインが融合。',
        url: 'https://www.briefing-usa.com/',
        foundationYear: 1998,
        country: '日本'),
    'トゥミ': BrandInfo(
        name: 'トゥミ',
        description: 'アメリカ発のトラベル・ビジネスバッグブランド。1975年創業。高い機能性と耐久性で、世界中のビジネスパーソンから支持されている。',
        url: 'https://www.tumi.co.jp/',
        foundationYear: 1975,
        country: 'アメリカ'),

    // sports
    'ナイキ': BrandInfo(
        name: 'ナイキ',
        description: 'アメリカ・オレゴン州発の世界最大のスポーツブランド。1964年創業。「Swoosh」ロゴで知られ、エアジョーダンなど革新的なスニーカーやウェアを多数生み出している。',
        url: 'https://www.nike.com/jp/',
        foundationYear: 1964,
        country: 'アメリカ',
        city: 'オレゴン州'),
    'アディダス': BrandInfo(
        name: 'アディダス',
        description: 'ドイツ発の総合スポーツ用品メーカー。1949年アドルフ・ダスラーにより設立。3本線の「スリーストライプス」が象徴的で、スポーツからファッションまで幅広く展開。',
        url: 'https://shop.adidas.jp/',
        foundationYear: 1949,
        founder: 'アドルフ・ダスラー',
        country: 'ドイツ'),
    'プーマ': BrandInfo(
        name: 'プーマ',
        description: 'ドイツ発のスポーツブランド。1948年ルドルフ・ダスラー（アディダス創業者の兄）により設立。スポーツとライフスタイルの融合を掲げる。',
        url: 'https://jp.puma.com/',
        foundationYear: 1948,
        founder: 'ルドルフ・ダスラー',
        country: 'ドイツ'),
    'アシックス': BrandInfo(
        name: 'アシックス',
        description: '兵庫県神戸市発のスポーツ用品メーカー。1949年鬼塚喜八郎により創業。ランニングシューズなど競技用シューズで高い技術力を持つ。',
        url: 'https://www.asics.com/jp/ja-jp/',
        foundationYear: 1949,
        founder: '鬼塚喜八郎',
        country: '日本',
        city: '兵庫県神戸市'),
    'ミズノ': BrandInfo(
        name: 'ミズノ',
        description: '大阪府発の総合スポーツ用品メーカー。1906年創業。野球用品をはじめ、様々なスポーツ分野で高品質な製品を提供。',
        url: 'https://jpn.mizuno.com/',
        foundationYear: 1906,
        country: '日本',
        city: '大阪府'),
    'アンダーアーマー': BrandInfo(
        name: 'アンダーアーマー',
        description: 'アメリカ・メリーランド州発のスポーツウェアブランド。1996年創業。身体にフィットする「コンプレッションウェア」で急成長した。',
        url: 'https://www.underarmour.co.jp/',
        foundationYear: 1996,
        country: 'アメリカ',
        city: 'メリーランド州'),
    'ニューバランス': BrandInfo(
        name: 'ニューバランス',
        description: 'アメリカ・ボストン発のスポーツシューズメーカー。1906年創業。矯正靴の製造から始まり、履き心地を追求したスニーカーで人気。',
        url: 'https://shop.newbalance.jp/',
        foundationYear: 1906,
        country: 'アメリカ',
        city: 'ボストン'),
    'デサント': BrandInfo(
        name: 'デサント',
        description: '大阪府発のスポーツウェアメーカー。1935年創業。スキーウェアや野球のユニフォームなど、高機能なアスリート向けウェアで知られる。',
        url: 'https://store.descente.co.jp/',
        foundationYear: 1935,
        country: '日本',
        city: '大阪府'),
    'ルコックスポルティフ': BrandInfo(
        name: 'ルコックスポルティフ',
        description: 'フランス発のスポーツ用品ブランド。1882年創業。「雄鶏」のロゴが特徴で、サイクリングウェアやテニスウェアで有名。',
        url: 'https://store.descente.co.jp/lecoqsportif/',
        foundationYear: 1882,
        country: 'フランス'),
    'ヨネックス': BrandInfo(
        name: 'ヨネックス',
        description: '東京都発のスポーツ用品メーカー。1946年創業。バドミントンやテニスのラケットで世界トップクラスのシェアを誇る。',
        url: 'https://www.yonex.co.jp/',
        foundationYear: 1946,
        country: '日本',
        city: '東京都'),

    // sneakers
    'コンバース': BrandInfo(
        name: 'コンバース',
        description: 'アメリカ発のシューズブランド。1908年創業。「オールスター」や「ジャックパーセル」などのスニーカーは、時代を超えて愛される定番アイテム。',
        url: 'https://converse.co.jp/',
        foundationYear: 1908,
        country: 'アメリカ'),
    'バンズ': BrandInfo(
        name: 'バンズ',
        description: 'アメリカ・カリフォルニア発のシューズブランド。1966年創業。スケートボードカルチャーと共に成長し、「ワッフルソール」が特徴。',
        url: 'https://www.vans.co.jp/',
        foundationYear: 1966,
        country: 'アメリカ',
        city: 'カリフォルニア'),
    'リーボック': BrandInfo(
        name: 'リーボック',
        description: 'イギリス発祥のスポーツ用品ブランド。1895年創業。フィットネス分野に強く、「ポンプフューリー」など独創的なスニーカーで知られる。',
        url: 'https://reebok.jp/',
        foundationYear: 1895,
        country: 'イギリス'),
    'オニツカタイガー': BrandInfo(
        name: 'オニツカタイガー',
        description: 'アシックスの前身ブランド。1949年創業。レトロでスタイリッシュなデザインが特徴で、ファッションブランドとして再評価されている。',
        url: 'https://www.onitsukatiger.com/jp/ja-jp/',
        foundationYear: 1949,
        country: '日本'),
    'サッカニー': BrandInfo(
        name: 'サッカニー',
        description: 'アメリカ最古級のランニングシューズブランド。1898年創業。高い機能性とクラシックなデザインで、ランナーからスニーカーファンまで支持される。',
        url: 'https://www.saucony-japan.com/',
        foundationYear: 1898,
        country: 'アメリカ'),

    // furniture
    'カリモク家具': BrandInfo(
        name: 'カリモク家具',
        description: '愛知県発の日本を代表する木製家具メーカー。1940年創業。「100歳の木を使うなら、その使い方は100年先まで考えなければならない」という理念を持つ。',
        url: 'https://www.karimoku.co.jp/',
        foundationYear: 1940,
        country: '日本',
        city: '愛知県'),
    'マルニ木工': BrandInfo(
        name: 'マルニ木工',
        description: '広島県発の老舗木工家具メーカー。1928年創業。高度な木工技術と普遍的なデザインで、世界的に評価される家具を製造。',
        url: 'https://www.maruni.com/jp/',
        foundationYear: 1928,
        country: '日本',
        city: '広島県'),
    '天童木工': BrandInfo(
        name: '天童木工',
        description: '山形県天童市発の家具メーカー。1940年創業。成形合板技術のパイオニアとして、柳宗理の「バタフライスツール」など数々の名作を生み出す。',
        url: 'https://www.tendo-mokko.co.jp/',
        foundationYear: 1940,
        country: '日本',
        city: '山形県天童市'),
    'ハーマンミラー': BrandInfo(
        name: 'ハーマンミラー',
        description: 'アメリカのオフィス家具・ホームファニチャーメーカー。1905年創業。イームズ夫妻やジョージ・ネルソンなどのデザイナーと共にモダンデザインを牽引。',
        url: 'https://www.hermanmiller.com/ja_jp/',
        foundationYear: 1905,
        country: 'アメリカ'),
    'ヴィトラ': BrandInfo(
        name: 'ヴィトラ',
        description: 'スイスの家具・インテリアブランド。1950年創業。イームズやヴェルナー・パントンの名作家具の製造権を持ち、デザイン性の高い製品を展開。',
        url: 'https://www.vitra.com/ja-jp/',
        foundationYear: 1950,
        country: 'スイス'),
    'カッシーナ': BrandInfo(
        name: 'カッシーナ',
        description: 'イタリアの高級家具ブランド。1927年創業。モダンデザインの巨匠たちの作品を復刻する「イ・マエストリ」コレクションで知られる。',
        url: 'https://www.cassina-ixc.jp/',
        foundationYear: 1927,
        country: 'イタリア'),
    'B&B Italia': BrandInfo(
        name: 'B&B Italia',
        description: 'イタリアを代表するモダンファニチャーブランド。1966年創業。革新的な技術と洗練されたデザインで、世界のインテリアデザインをリードする。',
        url: 'https://www.bebitalia.com/ja',
        foundationYear: 1966,
        country: 'イタリア'),
    'アルフレックス': BrandInfo(
        name: 'アルフレックス',
        description: 'イタリア発祥の家具ブランド。1951年創業。日本法人は1969年設立。「豊かな暮らし」を提案するモダンで快適な家具が特徴。',
        url: 'https://www.arflex.co.jp/',
        foundationYear: 1951,
        country: 'イタリア'),
    'フリッツ・ハンセン': BrandInfo(
        name: 'フリッツ・ハンセン',
        description: 'デンマークを代表する家具ブランド。1872年創業。アルネ・ヤコブセンのセブンチェアなど、北欧デザインのアイコン的名作を数多く製造。',
        url: 'https://fritzhansen.com/ja-JP',
        foundationYear: 1872,
        country: 'デンマーク'),
    'イデー': BrandInfo(
        name: 'イデー',
        description: '日本のインテリアブランド・ショップ。1982年創業。「生活の探求、美意識のある暮らし」をテーマに、オリジナル家具や国内外の雑貨を扱う。',
        url: 'https://www.idee-online.com/',
        foundationYear: 1982,
        country: '日本'),

    // kitchenware
    'ル・クルーゼ': BrandInfo(
        name: 'ル・クルーゼ',
        description: 'フランス発の鋳物ホーロー鍋ブランド。1925年創業。優れた熱伝導と美しいカラーリングで、世界中のキッチンで愛用されている。',
        url: 'https://www.lecreuset.co.jp/',
        foundationYear: 1925,
        country: 'フランス'),
    'ストウブ': BrandInfo(
        name: 'ストウブ',
        description: 'フランス・アルザス地方発の鋳物ホーロー鍋ブランド。1974年創業。プロの料理人にも愛される機能性と、重厚感のあるデザインが特徴。',
        url: 'https://www.staub-online.com/jp/',
        foundationYear: 1974,
        country: 'フランス',
        city: 'アルザス地方'),
    'WMF': BrandInfo(
        name: 'WMF',
        description: 'ドイツのキッチン・テーブルウェアブランド。1853年創業。圧力鍋やカトラリーなど、高品質で機能的な製品を幅広く展開。',
        url: 'https://www.wmf.co.jp/',
        foundationYear: 1853,
        country: 'ドイツ'),
    'フィスラー': BrandInfo(
        name: 'フィスラー',
        description: 'ドイツの高級調理器具メーカー。1845年創業。世界で初めてスプリング式圧力鍋を開発したことで知られ、品質と安全性に定評がある。',
        url: 'https://www.fissler.com/jp/',
        foundationYear: 1845,
        country: 'ドイツ'),
    'ビタクラフト': BrandInfo(
        name: 'ビタクラフト',
        description: 'アメリカ発の調理器具ブランド。1939年創業。無水・無油調理が可能な多層構造鍋が特徴で、健康志向のユーザーに支持される。',
        url: 'https://www.vitacraft.co.jp/',
        foundationYear: 1939,
        country: 'アメリカ'),
    'ツヴィリング J.A. ヘンケルス': BrandInfo(
        name: 'ツヴィリング J.A. ヘンケルス',
        description: 'ドイツ・ゾーリンゲン発の刃物・調理器具メーカー。1731年創業。双子のロゴで知られ、高品質な包丁やキッチンツールが世界的に有名。',
        url: 'https://www.zwilling.com/jp/',
        foundationYear: 1731,
        country: 'ドイツ',
        city: 'ゾーリンゲン'),
    'グローバル': BrandInfo(
        name: 'グローバル',
        description: '新潟県燕三条の吉田金属工業が製造する包丁ブランド。1985年誕生。刃から柄まで一体型のステンレス製で、スタイリッシュなデザインと切れ味で人気。',
        url: 'https://www.yoshikin.co.jp/global/',
        foundationYear: 1985,
        country: '日本',
        city: '新潟県燕三条'),
    '野田琺瑯': BrandInfo(
        name: '野田琺瑯',
        description: '東京・江東区の琺瑯（ホーロー）製品専門メーカー。1934年創業。「ホワイトシリーズ」など、シンプルで長く使える高品質な製品が特徴。',
        url: 'https://www.nodahoro.com/',
        foundationYear: 1934,
        country: '日本',
        city: '東京都江東区'),
    '柳宗理': BrandInfo(
        name: '柳宗理',
        description: '日本のインダストリアルデザイナー、柳宗理が手がけたデザイン製品群。キッチンツールやカトラリーは、使いやすさと普遍的な美しさで高い評価を得ている。',
        url: 'https://www.yanagi-support.jp/',
        country: '日本'),
    'イッタラ': BrandInfo(
        name: 'イッタラ',
        description: 'フィンランドを代表するテーブルウェア・ライフスタイルブランド。1881年創業。アルヴァ・アアルトのベースなど、時代を超えて愛されるデザインが特徴。',
        url: 'https://www.iittala.jp/',
        foundationYear: 1881,
        country: 'フィンランド'),

    // homedecor
    'HAY': BrandInfo(
        name: 'HAY',
        description: 'デンマークのインテリアプロダクトブランド。2002年設立。50-60年代のデザインを現代的に解釈し、手頃な価格でデザイン性の高い製品を提供。',
        url: 'https://www.hay-japan.com/',
        foundationYear: 2002,
        country: 'デンマーク'),
    'menu': BrandInfo(
        name: 'menu',
        description: 'デンマークのデザイン会社。1978年設立。スカンジナビアデザインの伝統に基づき、美しく機能的な日常品を創造する。',
        url: 'https://menuspace.com/',
        foundationYear: 1978,
        country: 'デンマーク'),
    'ferm LIVING': BrandInfo(
        name: 'ferm LIVING',
        description: 'デンマーク・コペンハーゲン発のインテリアブランド。2006年設立。グラフィカルなパターンや温かみのあるデザインが特徴。',
        url: 'https://fermliving.com/',
        foundationYear: 2006,
        country: 'デンマーク',
        city: 'コペンハーゲン'),
    'Normann Copenhagen': BrandInfo(
        name: 'Normann Copenhagen',
        description: 'デンマークのデザイン会社。1999年設立。「常識への挑戦」を掲げ、大胆で革新的な家具や照明、雑貨を展開。',
        url: 'https://www.normann-copenhagen.com/',
        foundationYear: 1999,
        country: 'デンマーク'),
    'Muuto': BrandInfo(
        name: 'Muuto',
        description: 'デンマーク・コペンハーゲン発のデザインブランド。2006年設立。スカンジナビアデザインに新しい視点を取り入れた家具や照明で注目を集める。',
        url: 'https://muuto.com/',
        foundationYear: 2006,
        country: 'デンマーク',
        city: 'コペンハーゲン'),
    '&Tradition': BrandInfo(
        name: '&Tradition',
        description: 'デンマークのデザイン会社。2010年設立。往年の名作の復刻と、現代のデザイナーとの協業により、伝統と革新を繋ぐ製品を生み出す。',
        url: 'https://www.andtradition.com/',
        foundationYear: 2010,
        country: 'デンマーク'),
    'GUBI': BrandInfo(
        name: 'GUBI',
        description: 'デンマーク・コペンハーゲン発のデザイン会社。1967年設立。過去の忘れられたデザインアイコンを再発見し、現代に蘇らせることで知られる。',
        url: 'https://gubi.com/',
        foundationYear: 1967,
        country: 'デンマーク',
        city: 'コペンハーゲン'),
    'MOHEIM': BrandInfo(
        name: 'MOHEIM',
        description: '日本・福井県発のライフスタイルブランド。2014年設立。ミニマルで普遍的なデザインの食器やインテリア雑貨を展開。',
        url: 'https://moheim.com/',
        foundationYear: 2014,
        country: '日本',
        city: '福井県'),
    'ザラホーム': BrandInfo(
        name: 'ザラホーム',
        description: 'ZARAを展開するインディテックス社が運営するインテリア・ホームファッションブランド。2003年設立。トレンドを取り入れた雑貨やリネン類を週2回新作投入する。',
        url: 'https://www.zarahome.com/jp/',
        foundationYear: 2003,
        country: 'スペイン'),

    // beddingbath
    '西川': BrandInfo(
        name: '西川',
        description: '1566年創業の日本の老舗寝具メーカー。質の高い睡眠を追求し、マットレス「AiR」や羽毛布団など、革新的な製品を開発。',
        url: 'https://www.nishikawa1566.com/',
        foundationYear: 1566,
        country: '日本'),
    'エアウィーヴ': BrandInfo(
        name: 'エアウィーヴ',
        description: '日本の寝具メーカー。2007年より本格販売開始。独自素材「エアファイバー」を使用したマットレスパッドで知られ、多くのアスリートが愛用。',
        url: 'https://airweave.jp/',
        foundationYear: 2007,
        country: '日本'),
    'テンピュール': BrandInfo(
        name: 'テンピュール',
        description: 'デンマーク発の寝具ブランド。NASAが開発した素材を基に、体圧分散性に優れたマットレスやピローを製品化。',
        url: 'https://jp.tempur.com/',
        country: 'デンマーク'),
    'シモンズ': BrandInfo(
        name: 'シモンズ',
        description: 'アメリカ発のベッド・マットレスメーカー。1870年創業。ポケットコイルマットレスのパイオニアとして、世界中の高級ホテルで採用されている。',
        url: 'https://www.simmons.co.jp/',
        foundationYear: 1870,
        country: 'アメリカ'),
    'サータ': BrandInfo(
        name: 'サータ',
        description: 'アメリカのマットレスブランド。1931年創業。全米売上No.1の実績を誇り、快適な寝心地を追求した製品を開発。',
        url: 'https://www.serta-japan.jp/',
        foundationYear: 1931,
        country: 'アメリカ'),
    'フランスベッド': BrandInfo(
        name: 'フランスベッド',
        description: '日本のベッド・医療福祉用具メーカー。1949年創業。日本の住環境や日本人の体格に合わせた高品質なベッドを製造。',
        url: 'https://www.francebed.co.jp/',
        foundationYear: 1949,
        country: '日本'),
    '内野': BrandInfo(
        name: '内野',
        description: '東京発のタオル・バスローブメーカー。1947年創業。「マシュマロガーゼ」など、素材と使い心地にこだわった高品質な製品が特徴。',
        url: 'https://uchino.shop/',
        foundationYear: 1947,
        country: '日本',
        city: '東京都'),
    '今治タオル': BrandInfo(
        name: '今治タオル',
        description: '愛媛県今治市で製造されるタオルの地域ブランド。120年以上の歴史を持ち、「5秒ルール」などの厳しい品質基準をクリアした高品質なタオル。',
        url: 'https://imabaritowel.jp/',
        country: '日本',
        city: '愛媛県今治市'),
    'ホットマン': BrandInfo(
        name: 'ホットマン',
        description: '東京・青梅市発のタオル専門メーカー。1868年創業。1秒で水を吸う「1秒タオル」で知られ、企画から製造・販売まで一貫して行う。',
        url: 'https://hotman.co.jp/',
        foundationYear: 1868,
        country: '日本',
        city: '東京都青梅市'),
    'テネリータ': BrandInfo(
        name: 'テネリータ',
        description: '日本のオーガニックコットン製品ブランド。「ゆたかであること、上質であること」をコンセプトに、タオルやルームウェアなどを展開。',
        url: 'https://www.tenerita.com/',
        country: '日本'),

    // jewelry
    'ティファニー': BrandInfo(
        name: 'ティファニー',
        description: 'アメリカ・ニューヨーク発の世界的なジュエリーブランド。1837年創業。「ティファニーブルー」のボックスで知られ、エンゲージリングなどで絶大な人気を誇る。',
        url: 'https://www.tiffany.co.jp/',
        foundationYear: 1837,
        country: 'アメリカ',
        city: 'ニューヨーク'),
    'カルティエ': BrandInfo(
        name: 'カルティエ',
        description: 'フランス・パリ発の名門ジュエラー・高級時計ブランド。1847年創業。「王の宝石商、宝石商の王」と称され、数々の王室御用達として歴史を刻む。',
        url: 'https://www.cartier.jp/',
        foundationYear: 1847,
        country: 'フランス',
        city: 'パリ'),
    'ブルガリ': BrandInfo(
        name: 'ブルガリ',
        description: 'イタリア・ローマ発の高級宝飾品ブランド。1884年創業。古代ローマの様式美を取り入れた大胆でグラマラスなデザインが特徴。',
        url: 'https://www.bulgari.com/ja-jp/',
        foundationYear: 1884,
        country: 'イタリア',
        city: 'ローマ'),
    'ヴァンクリーフ＆アーペル': BrandInfo(
        name: 'ヴァンクリーフ＆アーペル',
        description: 'フランス・パリ発の高級ジュエラー。1906年創業。「アルハンブラ」コレクションや「ミステリーセット」技法で知られる。',
        url: 'https://www.vancleefarpels.com/jp/ja.html',
        foundationYear: 1906,
        country: 'フランス',
        city: 'パリ'),
    'ハリー・ウィンストン': BrandInfo(
        name: 'ハリー・ウィンストン',
        description: 'アメリカ・ニューヨーク発の高級ジュエリー・腕時計ブランド。1932年創業。「キング・オブ・ダイヤモンド」と称され、最高級の宝石のみを扱う。',
        url: 'https://www.harrywinston.com/ja',
        foundationYear: 1932,
        country: 'アメリカ',
        city: 'ニューヨーク'),
    'ショパール': BrandInfo(
        name: 'ショパール',
        description: 'スイスの高級時計・宝飾ブランド。1860年創業。ムービングダイヤモンドが特徴の「ハッピーダイヤモンド」コレクションが有名。',
        url: 'https://www.chopard.jp/',
        foundationYear: 1860,
        country: 'スイス'),
    'ブシュロン': BrandInfo(
        name: 'ブシュロン',
        description: 'フランス・パリ発の高級宝飾品ブランド。1858年創業。ヴァンドーム広場に最初にブティックを構えたジュエラーとして知られる。',
        url: 'https://www.boucheron.com/ja_jp/',
        foundationYear: 1858,
        country: 'フランス',
        city: 'パリ'),
    'ミキモト': BrandInfo(
        name: 'ミキモト',
        description: '日本発の世界的なジュエリーブランド。1893年創業者・御木本幸吉が世界で初めて真珠の養殖に成功。高品質なパールジュエリーで知られる。',
        url: 'https://www.mikimoto.com/',
        foundationYear: 1893,
        founder: '御木本幸吉',
        country: '日本'),
    'タサキ': BrandInfo(
        name: 'タサキ',
        description: '日本のジュエリーブランド。1954年創業。真珠養殖から加工・販売まで一貫して行い、革新的なデザインのパールやダイヤモンドジュエリーで評価が高い。',
        url: 'https://www.tasaki.co.jp/',
        foundationYear: 1954,
        country: '日本'),
    '4℃': BrandInfo(
        name: '4℃',
        description: '日本のジュエリーブランド。1972年創業。シンプルでフェミニンなデザインが特徴で、特に若い女性からの支持が高い。',
        url: 'https://www.fdcp.co.jp/4c/',
        foundationYear: 1972,
        country: '日本'),

    // watches
    'ロレックス': BrandInfo(
        name: 'ロレックス',
        description: 'スイスの高級腕時計メーカー。1905年ハンス・ウィルスドルフにより創業。実用時計の最高峰として、高い精度、耐久性、資産価値で世界的に有名。',
        url: 'https://www.rolex.com/ja',
        foundationYear: 1905,
        founder: 'ハンス・ウィルスドルフ',
        country: 'スイス'),
    'オメガ': BrandInfo(
        name: 'オメガ',
        description: 'スイスの高級腕時計メーカー。1848年ルイ・ブランにより創業。NASAの公式装備品として月面に到達した「スピードマスター」などで知られる。',
        url: 'https://www.omegawatches.jp/',
        foundationYear: 1848,
        founder: 'ルイ・ブラン',
        country: 'スイス'),
    'タグ・ホイヤー': BrandInfo(
        name: 'タグ・ホイヤー',
        description: 'スイスの高級腕時計メーカー。1860年エドワード・ホイヤーにより創業。モータースポーツとの関わりが深く、クロノグラフのパイオニアとして有名。',
        url: 'https://www.tagheuer.com/jp/ja/',
        foundationYear: 1860,
        founder: 'エドワード・ホイヤー',
        country: 'スイス'),
    'ブライトリング': BrandInfo(
        name: 'ブライトリング',
        description: 'スイスの高級腕時計メーカー。1884年レオン・ブライトリングにより創業。航空業界との強いつながりを持ち、「腕につける計器」として知られる。',
        url: 'https://www.breitling.com/jp-ja/',
        foundationYear: 1884,
        founder: 'レオン・ブライトリング',
        country: 'スイス'),
    'IWC': BrandInfo(
        name: 'IWC',
        description: 'スイスの高級腕時計メーカー。1868年創業。質実剛健なドイツ魂とスイスの時計技術が融合した、エンジニアリング精神あふれる時計を製造。',
        url: 'https://www.iwc.com/jp/ja.html',
        foundationYear: 1868,
        country: 'スイス'),
    'セイコー': BrandInfo(
        name: 'セイコー',
        description: '日本を代表する時計メーカー。1881年服部金太郎により創業。世界初のクオーツ腕時計を製品化するなど、革新的な技術力で知られる。',
        url: 'https://www.seikowatches.com/jp-ja',
        foundationYear: 1881,
        founder: '服部金太郎',
        country: '日本'),
    'シチズン': BrandInfo(
        name: 'シチズン',
        description: '日本の時計メーカー。1918年創業。「市民に愛されるように」という理念を持ち、光で動く「エコ・ドライブ」技術が有名。',
        url: 'https://citizen.jp/',
        foundationYear: 1918,
        country: '日本'),
    'カシオ': BrandInfo(
        name: 'カシオ',
        description: '日本の電機メーカー。1946年創業。耐衝撃腕時計「G-SHOCK」は世界的な大ヒット商品となり、タフネスウォッチの代名詞。',
        url: 'https://www.casio.com/jp/',
        foundationYear: 1946,
        country: '日本'),
    'グランドセイコー': BrandInfo(
        name: 'グランドセイコー',
        description: 'セイコーが展開する高級腕時計ブランド。1960年誕生。「最高の普通」を追求し、日本の美意識と最高レベルの精度、仕上げを誇る。',
        url: 'https://www.grand-seiko.com/jp-ja',
        foundationYear: 1960,
        country: '日本'),
    'パネライ': BrandInfo(
        name: 'パネライ',
        description: 'イタリア・フィレンツェ発祥の高級腕時計ブランド。1860年創業。イタリア海軍特殊部隊のために製造した歴史を持ち、大型ケースと高い視認性が特徴。',
        url: 'https://www.panerai.com/jp/ja/home.html',
        foundationYear: 1860,
        country: 'イタリア',
        city: 'フィレンツェ'),

    // eyewear
    'レイバン': BrandInfo(
        name: 'レイバン',
        description: 'アメリカ発祥のサングラス・メガネブランド。1937年誕生。「アビエイター」や「ウェイファーラー」など、アイウェア史に残る数々の名作を生み出した。',
        url: 'https://www.ray-ban.com/japan',
        foundationYear: 1937,
        country: 'アメリカ'),
    'オリバーピープルズ': BrandInfo(
        name: 'オリバーピープルズ',
        description: 'アメリカ・ロサンゼルス発のアイウェアブランド。1987年創業。ヴィンテージデザインにインスパイアされた、精巧で美しいフレームが特徴。',
        url: 'https://oliverpeoples.jp/',
        foundationYear: 1987,
        country: 'アメリカ',
        city: 'ロサンゼルス'),
    'トムフォード': BrandInfo(
        name: 'トムフォード',
        description: 'アメリカのファッションデザイナー、トム・フォードによるブランド。アイウェアは、クラシックでセクシーなデザインと「T」のアイコンで人気。',
        url: 'https://www.tomford.com/eyewear/',
        founder: 'トム・フォード',
        country: 'アメリカ'),
    'アイヴァン': BrandInfo(
        name: 'アイヴァン',
        description: '日本・福井県鯖江市のアイウェアブランド。1972年「着るメガネ」をコンセプトに誕生。日本の高い技術力と美しいデザインが融合。',
        url: 'https://eyevan.com/',
        foundationYear: 1972,
        country: '日本',
        city: '福井県鯖江市'),
    'フォーナインズ': BrandInfo(
        name: 'フォーナインズ',
        description: '日本のメガネフレームブランド。1995年創業。「眼鏡は道具である」という理念のもと、最高の掛け心地を追求した機能的なフレームを製造。',
        url: 'https://www.fournines.co.jp/',
        foundationYear: 1995,
        country: '日本'),
    '金子眼鏡': BrandInfo(
        name: '金子眼鏡',
        description: '福井県鯖江市の眼鏡メーカー・小売店。1958年創業。職人による手作りにこだわり、伝統的な製法と上質な素材による高品質な眼鏡を製造。',
        url: 'https://www.kaneko-optical.co.jp/',
        foundationYear: 1958,
        country: '日本',
        city: '福井県鯖江市'),
    '白山眼鏡店': BrandInfo(
        name: '白山眼鏡店',
        description: '1946年創業の日本の眼鏡店・ブランド。1975年よりオリジナルフレームを製作。「デザインしすぎないこと」をコンセプトに、長く愛用できるフレームを展開。',
        url: 'https://hakusan-megane.co.jp/',
        foundationYear: 1946,
        country: '日本'),
    'JINS': BrandInfo(
        name: 'JINS',
        description: '日本のアイウェアブランド・小売店。2001年より事業開始。企画から販売まで一貫して行い、高品質なメガネを低価格・短時間で提供するSPAモデルを確立。',
        url: 'https://www.jins.com/jp/',
        foundationYear: 2001,
        country: '日本'),
    'Zoff': BrandInfo(
        name: 'Zoff',
        description: '日本のアイウェアブランド・小売店。2001年創業。JINSと共にメガネの低価格化を牽引。多様なデザインとコラボレーションで人気。',
        url: 'https://www.zoff.co.jp/',
        foundationYear: 2001,
        country: '日本'),
    'OWNDAYS': BrandInfo(
        name: 'OWNDAYS',
        description: '日本発のアイウェアブランド・小売店。SPAモデルを採用し、世界中に店舗を展開。どんな度数でも追加料金0円のシステムが特徴。',
        url: 'https://www.owndays.com/jp/ja',
        country: '日本'),

    // electronics
    'パナソニック': BrandInfo(
        name: 'パナソニック',
        description: '日本を代表する総合電機メーカー。1918年松下幸之助により創業。家電から住宅、BtoBソリューションまで幅広い事業を展開。',
        url: 'https://panasonic.jp/',
        foundationYear: 1918,
        founder: '松下幸之助',
        country: '日本'),
    'ソニー': BrandInfo(
        name: 'ソニー',
        description: '日本の総合電機メーカー。1946年井深大、盛田昭夫により創業。ウォークマンやプレイステーションなど、革新的な製品で世界中のライフスタイルを変えてきた。',
        url: 'https://www.sony.jp/',
        foundationYear: 1946,
        founder: '井深大、盛田昭夫',
        country: '日本'),
    '日立': BrandInfo(
        name: '日立',
        description: '日本の総合電機メーカー。1910年創業。社会イノベーション事業を中核とし、IT、エネルギー、産業、モビリティ、ライフの各分野で事業を展開。',
        url: 'https://www.hitachi.co.jp/products/electronics/',
        foundationYear: 1910,
        country: '日本'),
    '三菱電機': BrandInfo(
        name: '三菱電機',
        description: '日本の総合電機メーカー。1921年設立。FAシステム、昇降機、タービン発電機、人工衛星など重電分野に強みを持つ。',
        url: 'https://www.mitsubishielectric.co.jp/home/',
        foundationYear: 1921,
        country: '日本'),
    'シャープ': BrandInfo(
        name: 'シャープ',
        description: '日本の電機メーカー。1912年早川徳次により創業。世界初のシャープペンシルや電卓を開発。液晶技術に強みを持つ。',
        url: 'https://jp.sharp/',
        foundationYear: 1912,
        founder: '早川徳次',
        country: '日本'),
    'ダイソン': BrandInfo(
        name: 'ダイソン',
        description: 'イギリスの家電メーカー。1991年ジェームズ・ダイソンにより創業。サイクロン式掃除機や羽根のない扇風機など、革新的な技術とデザインで知られる。',
        url: 'https://www.dyson.co.jp/',
        foundationYear: 1991,
        founder: 'ジェームズ・ダイソン',
        country: 'イギリス'),
    'バルミューダ': BrandInfo(
        name: 'バルミューダ',
        description: '日本の家電メーカー。2003年寺尾玄により創業。独自の技術と美しいデザインで、扇風機やトースターなどの製品で新たな価値を提案。',
        url: 'https://www.balmuda.com/',
        foundationYear: 2003,
        founder: '寺尾玄',
        country: '日本'),
    'Apple': BrandInfo(
        name: 'Apple',
        description: 'アメリカのテクノロジー企業。1976年スティーブ・ジョブズらにより創業。iPhone, Mac, iPadなど、ハードウェア、ソフトウェア、サービスを統合したエコシステムを構築。',
        url: 'https://www.apple.com/jp/',
        foundationYear: 1976,
        founder: 'スティーブ・ジョブズ',
        country: 'アメリカ'),
    'Samsung': BrandInfo(
        name: 'Samsung',
        description: '韓国最大の多国籍コングロマリット。1938年創業。スマートフォン「Galaxy」や半導体、家電など幅広い分野で世界トップクラスのシェアを誇る。',
        url: 'https://www.samsung.com/jp/',
        foundationYear: 1938,
        country: '韓国'),
    'LG': BrandInfo(
        name: 'LG',
        description: '韓国の多国籍コングロマリット。1947年創業。家電、化学、通信など幅広い事業を展開。有機ELテレビなどで高い技術力を持つ。',
        url: 'https://www.lg.com/jp',
        foundationYear: 1947,
        country: '韓国'),

    // audiodevices
    'ボーズ': BrandInfo(
        name: 'ボーズ',
        description: 'アメリカの音響機器メーカー。1964年アマー・ボーズにより創業。独自の音響技術に基づいたスピーカーやヘッドホンで、高品質なサウンドを提供。',
        url: 'https://www.bose.co.jp/',
        foundationYear: 1964,
        founder: 'アマー・ボーズ',
        country: 'アメリカ'),
    'ゼンハイザー': BrandInfo(
        name: 'ゼンハイザー',
        description: 'ドイツの音響機器メーカー。1945年創業。プロ用のマイクやヘッドホンで高い評価を得ており、コンシューマー向け製品も人気。',
        url: 'https://www.sennheiser.com/ja-jp',
        foundationYear: 1945,
        country: 'ドイツ'),
    'オーディオテクニカ': BrandInfo(
        name: 'オーディオテクニカ',
        description: '日本の音響機器メーカー。1962年創業。レコード針の製造から始まり、ヘッドホンやマイクなど幅広い製品で国内外に知られる。',
        url: 'https://www.audio-technica.co.jp/',
        foundationYear: 1962,
        country: '日本'),
    'JBL': BrandInfo(
        name: 'JBL',
        description: 'アメリカの音響機器メーカー。1946年ジェームス・B・ランシングにより創業。プロ用から家庭用、ポータブルまで、パワフルなサウンドのスピーカーで有名。',
        url: 'https://jp.jbl.com/',
        foundationYear: 1946,
        founder: 'ジェームス・B・ランシング',
        country: 'アメリカ'),
    'Bang & Olufsen': BrandInfo(
        name: 'Bang & Olufsen',
        description: 'デンマークの高級オーディオ・ビジュアルブランド。1925年創業。優れた音響技術と、洗練されたミニマルなデザインで知られる。',
        url: 'https://www.bang-olufsen.com/ja/jp',
        foundationYear: 1925,
        country: 'デンマーク'),
    'Shure': BrandInfo(
        name: 'Shure',
        description: 'アメリカの音響機器メーカー。1925年創業。プロ用のマイクやイヤホンで絶大な信頼を得ており、特にマイク「SM58」は業界標準となっている。',
        url: 'https://www.shure.com/ja-JP',
        foundationYear: 1925,
        country: 'アメリカ'),
    'AKG': BrandInfo(
        name: 'AKG',
        description: 'オーストリア・ウィーン発祥の音響機器メーカー。1947年創業。スタジオ用マイクやヘッドホンで世界的に有名。現在はハーマン・インターナショナル傘下。',
        url: 'https://jp.akg.com/',
        foundationYear: 1947,
        country: 'オーストリア',
        city: 'ウィーン'),
    'Beats by Dr. Dre': BrandInfo(
        name: 'Beats by Dr. Dre',
        description: 'アメリカのオーディオブランド。2006年Dr. Dreとジミー・アイオヴィンにより創業。パワフルな低音とファッション性の高いデザインで人気を博し、現在はApple傘下。',
        url: 'https://www.beatsbydre.com/jp',
        foundationYear: 2006,
        founder: 'Dr. Dre, ジミー・アイオヴィン',
        country: 'アメリカ'),
    'ヤマハ': BrandInfo(
        name: 'ヤマハ',
        description: '日本の総合楽器・音響機器メーカー。1887年山葉寅楠により創業。ピアノから管楽器、電子楽器、AV機器まで幅広い製品で世界トップクラスのシェアを誇る。',
        url: 'https://jp.yamaha.com/products/audio_visual/',
        foundationYear: 1887,
        founder: '山葉寅楠',
        country: '日本'),

    // cameras
    'キヤノン': BrandInfo(
        name: 'キヤノン',
        description: '日本の精密機器メーカー。1937年創業。カメラ、ビデオカメラ、プリンター、複写機などで世界的なブランド。EOSシリーズのデジタル一眼レフカメラが有名。',
        url: 'https://canon.jp/',
        foundationYear: 1937,
        country: '日本'),
    'ニコン': BrandInfo(
        name: 'ニコン',
        description: '日本の光学機器メーカー。1917年創業。カメラや双眼鏡、半導体露光装置などを製造。キヤノンと並ぶカメラ業界の二大巨頭。',
        url: 'https://www.nikon-image.com/products/',
        foundationYear: 1917,
        country: '日本'),
    '富士フイルム': BrandInfo(
        name: '富士フイルム',
        description: '日本の精密化学・光学機器メーカー。1934年創業。写真フィルムで培った技術を活かし、Xシリーズなどの高性能デジタルカメラで人気。',
        url: 'https://fujifilm-x.com/ja-jp/',
        foundationYear: 1934,
        country: '日本'),
    'オリンパス': BrandInfo(
        name: 'オリンパス',
        description: '日本の光学機器メーカー。1919年創業。顕微鏡や内視鏡で世界トップシェア。カメラ事業は2021年にOMデジタルソリューションズへ譲渡されたが、ブランドは継続。',
        url: 'https://om-systems.com/ja-jp/',
        foundationYear: 1919,
        country: '日本'),
    'ライカ': BrandInfo(
        name: 'ライカ',
        description: 'ドイツの高級カメラメーカー。1914年初の35mm判カメラ「ウル・ライカ」を開発。卓越した描写性能のレンズと、精密なレンジファインダーカメラで知られる。',
        url: 'https://leica-camera.com/ja-JP',
        foundationYear: 1914,
        country: 'ドイツ'),
    'GoPro': BrandInfo(
        name: 'GoPro',
        description: 'アメリカのウェアラブルカメラメーカー。2002年ニック・ウッドマンにより創業。小型・高耐久のアクションカメラで、スポーツやアクティビティの撮影に革命をもたらした。',
        url: 'https://gopro.com/ja/jp/',
        foundationYear: 2002,
        founder: 'ニック・ウッドマン',
        country: 'アメリカ'),
    'DJI': BrandInfo(
        name: 'DJI',
        description: '中国・深圳発のドローン・カメラ技術会社。2006年創業。コンシューマー向けドローン市場で世界シェア7割を占めるトップ企業。ジンバルカメラも人気。',
        url: 'https://www.dji.com/jp',
        foundationYear: 2006,
        country: '中国',
        city: '深圳'),
    'リコー': BrandInfo(
        name: 'リコー',
        description: '日本の事務機器・光学機器メーカー。1936年創業。複写機やプリンターが主力。GRシリーズなど、スナップ撮影に特化した高性能コンパクトデジタルカメラも製造。',
        url: 'https://www.ricoh-imaging.co.jp/japan/',
        foundationYear: 1936,
        country: '日本'),

    // stationery
    'コクヨ': BrandInfo(
        name: 'コクヨ',
        description: '日本の文房具・オフィス家具メーカー。1905年創業。「Campusノート」は学生の定番。使いやすさと機能性を追求した製品を多数展開。',
        url: 'https://www.kokuyo.co.jp/',
        foundationYear: 1905,
        country: '日本'),
    'パイロット': BrandInfo(
        name: 'パイロット',
        description: '日本の筆記具メーカー。1918年創業。万年筆の国産化に成功し、フリクションシリーズなど革新的な製品を開発。',
        url: 'https://www.pilot.co.jp/',
        foundationYear: 1918,
        country: '日本'),
    '三菱鉛筆': BrandInfo(
        name: '三菱鉛筆',
        description: '日本の筆記具メーカー。1887年創業。「uni」ブランドで知られ、ジェットストリームなどのボールペンや鉛筆で高いシェアを誇る。',
        url: 'https://www.mpuni.co.jp/',
        foundationYear: 1887,
        country: '日本'),
    'ゼブラ': BrandInfo(
        name: 'ゼブラ',
        description: '日本の筆記具メーカー。1897年創業。「マッキー」や「サラサ」など、数々のロングセラー・ヒット商品を持つ。',
        url: 'https://www.zebra.co.jp/',
        foundationYear: 1897,
        country: '日本'),
    'ぺんてる': BrandInfo(
        name: 'ぺんてる',
        description: '日本の文房具メーカー。1946年創業。世界初のサインペンや、シャープペンシル替芯「Ain STEIN」など、独創的な製品で知られる。',
        url: 'https://www.pentel.co.jp/',
        foundationYear: 1946,
        country: '日本'),
    'トンボ鉛筆': BrandInfo(
        name: 'トンボ鉛筆',
        description: '日本の文房具メーカー。1913年創業。鉛筆「MONO」と消しゴムはデザインと品質で長年愛されている。スティックのり「ピット」も有名。',
        url: 'https://www.tombow.com/products/',
        foundationYear: 1913,
        country: '日本'),
    'デザインフィル': BrandInfo(
        name: 'デザインフィル',
        description: '日本の文具・雑貨メーカー。「ミドリ」ブランドで知られ、手帳「トラベラーズノート」やデザイン性の高いレターセットなどが人気。',
        url: 'https://www.designphil.co.jp/',
        country: '日本'),
    '伊東屋': BrandInfo(
        name: '伊東屋',
        description: '1904年創業の日本の文房具専門店。銀座本店が有名。オリジナル製品も開発しており、赤いクリップのロゴで知られる。',
        url: 'https://www.ito-ya.co.jp/',
        foundationYear: 1904,
        country: '日本'),
    'キングジム': BrandInfo(
        name: 'キングジム',
        description: '日本の事務用品・文房具メーカー。1927年創業。ファイル製品の「キングファイル」や、ラベルライター「テプラ」が代表的な商品。',
        url: 'https://www.kingjim.co.jp/',
        foundationYear: 1927,
        country: '日本'),

    // musicalinstruments
    'ローランド': BrandInfo(
        name: 'ローランド',
        description: '日本の電子楽器メーカー。1972年創業。シンセサイザーや電子ドラム、デジタルピアノなど、世界の音楽シーンに影響を与えた製品を多数開発。',
        url: 'https://www.roland.com/jp/',
        foundationYear: 1972,
        country: '日本'),
    'コルグ': BrandInfo(
        name: 'コルグ',
        description: '日本の電子楽器・音響機器メーカー。1963年創業。チューナーやシンセサイザーで知られ、独創的な製品でプロからアマチュアまで支持される。',
        url: 'https://www.korg.com/jp/',
        foundationYear: 1963,
        country: '日本'),
    'フェンダー': BrandInfo(
        name: 'フェンダー',
        description: 'アメリカの楽器メーカー。1946年レオ・フェンダーにより創業。テレキャスターやストラトキャスターなど、エレキギターのスタンダードを確立。',
        url: 'https://www.fender.com/ja-JP/',
        foundationYear: 1946,
        founder: 'レオ・フェンダー',
        country: 'アメリカ'),
    'ギブソン': BrandInfo(
        name: 'ギブソン',
        description: 'アメリカの楽器メーカー。1902年オーヴィル・ギブソンにより創業。レスポールやES-335など、数々の伝説的なエレキギターやアコースティックギターを製造。',
        url: 'https://www.gibson.com/ja-JP/',
        foundationYear: 1902,
        founder: 'オーヴィル・ギブソン',
        country: 'アメリカ'),
    'マーティン': BrandInfo(
        name: 'マーティン',
        description: 'アメリカのアコースティックギターメーカー。1833年創業。ドレッドノート型など、アコースティックギターの基本形を確立した老舗中の老舗。',
        url: 'https://www.martinclubjp.com/guitar/',
        foundationYear: 1833,
        country: 'アメリカ'),
    'パール': BrandInfo(
        name: 'パール',
        description: '日本の打楽器メーカー。1946年創業。ドラムセットで世界トップクラスのシェアを誇り、多くのトップドラマーに愛用されている。',
        url: 'https://pearldrum.com/',
        foundationYear: 1946,
        country: '日本'),
    'タマ': BrandInfo(
        name: 'タマ',
        description: '星野楽器が展開する日本のドラムブランド。1974年誕生。革新的なハードウェアや、パワフルなサウンドのドラムで世界的に有名。',
        url: 'https://www.tama.com/jp/',
        foundationYear: 1974,
        country: '日本'),
    'カワイ': BrandInfo(
        name: 'カワイ',
        description: '日本の楽器メーカー。1927年河合小市により創業。ピアノ製造でヤマハと並ぶ国内大手。電子ピアノやシンセサイザーも製造。',
        url: 'https://www.kawai.jp/',
        foundationYear: 1927,
        founder: '河合小市',
        country: '日本'),
    'スタインウェイ': BrandInfo(
        name: 'スタインウェイ',
        description: 'ドイツ・アメリカのピアノ製造会社。1853年創業。「コンサートグランドピアノの代名詞」とされ、世界中の主要ホールに設置されている。',
        url: 'https://www.steinway.co.jp/',
        foundationYear: 1853,
        country: 'ドイツ, アメリカ'),

    // beauty
    '資生堂': BrandInfo(
        name: '資生堂',
        description: '日本最大の化粧品メーカー。1872年福原有信により創業。高品質なスキンケア、メイクアップ製品を国内外で展開。「SHISEIDO」「クレ・ド・ポー ボーテ」など多数のブランドを持つ。',
        url: 'https://www.shiseido.co.jp/',
        foundationYear: 1872,
        founder: '福原有信',
        country: '日本'),
    '花王': BrandInfo(
        name: '花王',
        description: '日本の大手化学・日用品メーカー。1887年創業。「ソフィーナ」「キュレル」などの化粧品ブランドや、「ビオレ」などのスキンケア製品を展開。',
        url: 'https://www.kao.com/jp/',
        foundationYear: 1887,
        country: '日本'),
    'コーセー': BrandInfo(
        name: 'コーセー',
        description: '日本の化粧品メーカー。1946年創業。「雪肌精」「コスメデコルテ」など、個性豊かなブランドを多数展開し、高い開発力で知られる。',
        url: 'https://www.kose.co.jp/',
        foundationYear: 1946,
        country: '日本'),
    'ポーラ': BrandInfo(
        name: 'ポーラ',
        description: '日本の化粧品メーカー。1929年創業。訪問販売から始まり、エイジングケアに強みを持つ。「B.A」「リンクルショット」などが有名。',
        url: 'https://www.pola.co.jp/',
        foundationYear: 1929,
        country: '日本'),
    'SK-II': BrandInfo(
        name: 'SK-II',
        description: 'P&Gが保有する高級スキンケアブランド。日本で開発され、独自成分「ピテラ」を配合した化粧水「フェイシャル トリートメント エッセンス」が象徴的。',
        url: 'https://www.sk-ii.jp/',
        country: '日本'),
    'ランコム': BrandInfo(
        name: 'ランコム',
        description: 'フランス発祥のロレアル傘下の高級化粧品ブランド。1935年創業。スキンケア、メイクアップ、香水など、フレンチエレガンスを体現する製品を展開。',
        url: 'https://www.lancome.jp/',
        foundationYear: 1935,
        country: 'フランス'),
    'エスティローダー': BrandInfo(
        name: 'エスティローダー',
        description: 'アメリカの化粧品ブランド。1946年エスティ・ローダー夫人により創業。美容液「アドバンス ナイト リペア」は世界的なベストセラー。',
        url: 'https://www.esteelauder.jp/',
        foundationYear: 1946,
        founder: 'エスティ・ローダー',
        country: 'アメリカ'),
    'シャネル': BrandInfo(
        name: 'シャネル',
        description: 'フランスのファッションブランド。コスメ・香水部門も展開。「No.5」などの香水や、高品質なメイクアップ製品で知られる。',
        url: 'https://www.chanel.com/ja_JP/fragrance-beauty/',
        foundationYear: 1910,
        founder: 'ココ・シャネル',
        country: 'フランス',
        city: 'パリ'),
    'ディオール': BrandInfo(
        name: 'ディオール',
        description: 'フランスのファッションブランド。コスメ・香水部門も展開。「ミス ディオール」などの香水や、ファッションと連動したメイクアップ製品が人気。',
        url: 'https://www.dior.com/ja_jp/beauty',
        foundationYear: 1946,
        founder: 'クリスチャン・ディオール',
        country: 'フランス'),
    'イヴ・サンローラン': BrandInfo(
        name: 'イヴ・サンローラン',
        description: 'フランスのファッションブランド。コスメ・香水部門も展開。「ラディアント タッチ」やリップ製品など、革新的なヒット商品を多数生み出している。',
        url: 'https://www.yslb.jp/',
        foundationYear: 1961,
        founder: 'イヴ・サン＝ローラン',
        country: 'フランス'),

    // healthcare
    'オムロン': BrandInfo(
        name: 'オムロン',
        description: '日本の電子機器メーカー。ヘルスケア事業では、血圧計や体温計で世界トップクラスのシェアを誇る。',
        url: 'https://www.healthcare.omron.co.jp/',
        foundationYear: 1933,
        country: '日本'),
    'タニタ': BrandInfo(
        name: 'タニタ',
        description: '日本の計測機器メーカー。世界で初めて家庭用体脂肪計を開発したことで知られ、健康づくりをサポートする製品やサービスを提供。',
        url: 'https://www.tanita.co.jp/',
        foundationYear: 1944,
        country: '日本'),
    'テルモ': BrandInfo(
        name: 'テルモ',
        description: '日本の医療機器・医薬品メーカー。体温計や血圧計などの家庭用医療機器も製造しており、高い品質と信頼性で知られる。',
        url: 'https://www.terumo.co.jp/consumer/',
        foundationYear: 1921,
        country: '日本'),
    'パナソニック ヘルスケア': BrandInfo(
        name: 'パナソニック ヘルスケア',
        description: 'パナソニックが展開するヘルスケア・美容家電の製品群。血圧計や電動歯ブラシ、マッサージ機器など多岐にわたる。',
        url: 'https://panasonic.jp/health/',
        country: '日本'),
    'フィリップス': BrandInfo(
        name: 'フィリップス',
        description: 'オランダの多国籍テクノロジー企業。ヘルスケア分野では、電動歯ブラシ「ソニッケアー」やシェーバーで高いシェアを持つ。',
        url: 'https://www.philips.co.jp/c-m-hs/health-care',
        foundationYear: 1891,
        country: 'オランダ'),
    'ブラウン': BrandInfo(
        name: 'ブラウン',
        description: 'ドイツの小型電気器具メーカー。P&G傘下。シェーバーや電動歯ブラシ「オーラルB」など、優れたデザインと機能性で知られる。',
        url: 'https://www.braun.jp/',
        foundationYear: 1921,
        country: 'ドイツ'),
    'ドクターエア': BrandInfo(
        name: 'ドクターエア',
        description: '日本の健康・美容機器ブランド。スタイリッシュなデザインのマッサージツールやフィットネス機器で人気。',
        url: 'https://www.dr-air.com/',
        foundationYear: 2013,
        country: '日本'),
    'シックスパッド': BrandInfo(
        name: 'シックスパッド',
        description: 'MTGが展開するトレーニング・ギアブランド。EMS（筋電気刺激）技術を用いたウェアラブルトレーニング機器で知られる。',
        url: 'https://www.mtgec.jp/wellness/sixpad/',
        country: '日本'),
    'ファイテン': BrandInfo(
        name: 'ファイテン',
        description: '日本の健康サポート用品メーカー。独自の技術「アクアチタン」を用いたネックレスや衣料品で、多くのアスリートから支持されている。',
        url: 'https://www.phiten.com/',
        foundationYear: 1983,
        country: '日本'),
    'ガーミン': BrandInfo(
        name: 'ガーミン',
        description: 'アメリカのGPS機器メーカー。GPS技術を活かしたスマートウォッチやアクティビティトラッカーで、ランニングやフィットネス分野で高い人気を誇る。',
        url: 'https://www.garmin.co.jp/',
        foundationYear: 1989,
        country: 'アメリカ'),

    // petsupplies
    'アイリスオーヤマ': BrandInfo(
        name: 'アイリスオーヤマ',
        description: '宮城県仙台市発の生活用品メーカー。ペット事業では、ペットシーツやケージ、キャットタワーなど、ユーザー視点の幅広い製品を低価格で提供。',
        url: 'https://www.irisohyama.co.jp/pet/',
        foundationYear: 1958,
        country: '日本',
        city: '宮城県仙台市'),
    'ユニ・チャーム ペット': BrandInfo(
        name: 'ユニ・チャーム ペット',
        description: 'ユニ・チャームのペットケア事業。「デオトイレ」「マナーウェア」など、衛生用品を中心に高いシェアを持つ。',
        url: 'https://jp.unicharmpet.com/',
        country: '日本'),
    'いなばペットフード': BrandInfo(
        name: 'いなばペットフード',
        description: '日本のペットフードメーカー。特に猫用おやつ「CIAOちゅ〜る」は爆発的なヒット商品となり、国内外で人気。',
        url: 'https://www.inaba-petfood.co.jp/',
        country: '日本'),
    'ピュリナ': BrandInfo(
        name: 'ピュリナ',
        description: 'ネスレが展開する世界的なペットフードブランド。「ピュリナ ワン」「モンプチ」など、科学的根拠に基づいた多様な製品ラインナップを持つ。',
        url: 'https://nestle.jp/brand/purina/',
        country: 'アメリカ'),
    'ロイヤルカナン': BrandInfo(
        name: 'ロイヤルカナン',
        description: 'フランス発のペットフードメーカー。犬と猫の品種、年齢、健康状態に合わせた栄養学的なフード「ヘルス ニュートリション」を提唱。',
        url: 'https://www.royalcanin.com/jp',
        foundationYear: 1968,
        country: 'フランス'),
    'ヒルズ': BrandInfo(
        name: 'ヒルズ',
        description: 'アメリカ発のペットフードメーカー。獣医師と栄養学者が開発する「サイエンス・ダイエット」や、療法食「プリスクリプション・ダイエット」で知られる。',
        url: 'https://www.hills.co.jp/',
        foundationYear: 1939,
        country: 'アメリカ'),
    'ペティオ': BrandInfo(
        name: 'ペティオ',
        description: '大阪府発のペット用品総合メーカー。おもちゃ、おやつ、ケア用品、首輪など、犬猫向けの幅広い製品を企画・販売。',
        url: 'https://www.petio.com/',
        foundationYear: 1986,
        country: '日本',
        city: '大阪府'),
    'ドギーマン': BrandInfo(
        name: 'ドギーマン',
        description: '大阪府発のペット用品総合メーカー。「ドギーマン」ブランドで犬用品、「キャティーマン」ブランドで猫用品を展開。',
        url: 'https://www.doggyman.com/',
        foundationYear: 1963,
        country: '日本',
        city: '大阪府'),
    'リッチェル': BrandInfo(
        name: 'リッチェル',
        description: '富山県発のプラスチック製品メーカー。ペット事業では、サークルやキャリー、食器など、機能的で使いやすい樹脂製ペット用品を製造。',
        url: 'https://www.richell.co.jp/pet/',
        foundationYear: 1956,
        country: '日本',
        city: '富山県'),
    'GEX': BrandInfo(
        name: 'GEX',
        description: '大阪府発の観賞魚・小動物・犬猫用品メーカー。特に水槽やフィルターなどのアクアリウム用品で高いシェアを誇る。',
        url: 'https://www.gex-fp.co.jp/',
        foundationYear: 1977,
        country: '日本',
        city: '大阪府'),

    // apparelHighBrand
    'エルメス': BrandInfo(
        name: 'エルメス',
        description: 'フランス・パリ発の高級馬具・ファッションブランド。1837年創業。最高品質の素材と職人技によるバッグ「バーキン」「ケリー」は世界的アイコン。',
        url: 'https://www.hermes.com/jp/ja/',
        foundationYear: 1837,
        country: 'フランス',
        city: 'パリ'),
    'ルイ・ヴィトン': BrandInfo(
        name: 'ルイ・ヴィトン',
        description: 'フランスのファッションブランド。1854年創業。旅行鞄専門店として始まり、モノグラム・キャンバスのバッグや財布は世界中で愛されている。',
        url: 'https://jp.louisvuitton.com/jpn-jp/homepage',
        foundationYear: 1854,
        country: 'フランス'),
    'グッチ': BrandInfo(
        name: 'グッチ',
        description: 'イタリア・フィレンツェ発のファッションブランド。1921年グッチオ・グッチにより創業。GGロゴやウェブストライプが特徴で、革新的なデザインで人気を博す。',
        url: 'https://www.gucci.com/jp/ja/',
        foundationYear: 1921,
        founder: 'グッチオ・グッチ',
        country: 'イタリア',
        city: 'フィレンツェ'),
    'プラダ': BrandInfo(
        name: 'プラダ',
        description: 'イタリア・ミラノ発のファッションブランド。1913年創業。工業用防水ナイロン素材「ポコノ」を使用したバッグで世界的に有名に。ミニマルで洗練されたデザインが特徴。',
        url: 'https://www.prada.com/jp/ja.html',
        foundationYear: 1913,
        country: 'イタリア',
        city: 'ミラノ'),
    'サンローラン': BrandInfo(
        name: 'サンローラン',
        description: 'フランスのファッションブランド。1961年イヴ・サン=ローランにより創業。エレガントでモダンなスタイルを確立。現在はアンソニー・ヴァカレロがデザインを担う。',
        url: 'https://www.ysl.com/ja-jp',
        foundationYear: 1961,
        founder: 'イヴ・サン＝ローラン',
        country: 'フランス'),
    'バレンシアガ': BrandInfo(
        name: 'バレンシアガ',
        description: 'スペイン発祥、パリを拠点とするファッションブランド。1917年創業。現在はデムナ・ヴァザリアによる、ストリート感覚とクチュール技術が融合したデザインで人気。',
        url: 'https://www.balenciaga.com/ja-jp',
        foundationYear: 1917,
        country: 'スペイン'),
    'セリーヌ': BrandInfo(
        name: 'セリーヌ',
        description: 'フランスのファッションブランド。1945年創業。上品で実用的なデザインが特徴。現在はエディ・スリマンがクリエイティブ・ディレクターを務める。',
        url: 'https://www.celine.com/ja-jp/',
        foundationYear: 1945,
        country: 'フランス'),
    'フェンディ': BrandInfo(
        name: 'フェンディ',
        description: 'イタリア・ローマ発のファッションブランド。1925年創業。毛皮工房として始まり、「FF」ロゴ（ズッカ柄）やバッグ「バゲット」が有名。',
        url: 'https://www.fendi.com/jp-ja/',
        foundationYear: 1925,
        country: 'イタリア',
        city: 'ローマ'),

    // furnitureHighBrand
    'ポリフォーム': BrandInfo(
        name: 'ポリフォーム',
        description: 'イタリアの高級モダン家具ブランド。1970年創業。システム収納やワードローブに定評があり、洗練されたトータルインテリアを提案。',
        url: 'https://www.poliform.it/ja/',
        foundationYear: 1970,
        country: 'イタリア'),
    'ミノッティ': BrandInfo(
        name: 'ミノッティ',
        description: 'イタリアの高級家具ブランド。1948年創業。洗練されたモダンデザインと、上質な素材、卓越した仕立てで世界的に評価されている。',
        url: 'https://www.minotti.com/',
        foundationYear: 1948,
        country: 'イタリア'),
    'フレックスフォルム': BrandInfo(
        name: 'フレックスフォルム',
        description: 'イタリアの高級家具ブランド。1959年創業。アントニオ・チッテリオら有名デザイナーとの協業で、控えめなエレガンスと快適性を備えた家具を製造。',
        url: 'https://www.flexform.it/ja',
        foundationYear: 1959,
        country: 'イタリア'),
    'デパドヴァ': BrandInfo(
        name: 'デパドヴァ',
        description: 'イタリアの家具ブランド。1956年創業。ヴィコ・マジストレッティらとの協業で知られ、スカンジナビアデザインの影響を受けたモダンな製品が特徴。',
        url: 'https://www.depadova.com/ja/',
        foundationYear: 1956,
        country: 'イタリア'),
    'ポルトローナ・フラウ': BrandInfo(
        name: 'ポルトローナ・フラウ',
        description: 'イタリアの高級家具メーカー。1912年創業。上質な革「ペレ・フラウ」を使用した家具で知られ、フェラーリの内装なども手掛ける。',
        url: 'https://www.poltronafrau.com/ja',
        foundationYear: 1912,
        country: 'イタリア'),
    'リーン・ロゼ': BrandInfo(
        name: 'リーン・ロゼ',
        description: 'フランスのコンテンポラリー家具ブランド。1860年創業。高密度ウレタンのみで構成されたソファ「TOGO」はブランドの象徴的存在。',
        url: 'https://www.ligne-roset.jp/',
        foundationYear: 1860,
        country: 'フランス'),

    // bagHighBrand
    'ロエベ': BrandInfo(
        name: 'ロエベ',
        description: 'スペイン発の高級ファッションブランド。1846年創業。元は皮革工房で、卓越したクラフトマンシップと上質なレザー製品で知られる。「パズル」「ハンモック」などのバッグが人気。',
        url: 'https://www.loewe.com/jap/ja/home',
        foundationYear: 1846,
        country: 'スペイン'),
    'ゴヤール': BrandInfo(
        name: 'ゴヤール',
        description: 'フランスの高級トランク・バッグブランド。1853年創業。杉綾模様の「ゴヤールディン」キャンバスが特徴。宣伝をほとんど行わないことでも知られる。',
        url: 'https://www.goyard.com/jp_ja/',
        foundationYear: 1853,
        country: 'フランス'),
    'デルヴォー': BrandInfo(
        name: 'デルヴォー',
        description: 'ベルギー発の世界最古の高級レザーグッズメゾン。1829年創業。ベルギー王室御用達。「ブリヨン」などの象徴的なバッグを持つ。',
        url: 'https://www.delvaux.com/ja/',
        foundationYear: 1829,
        country: 'ベルギー'),
    'ヴァレクストラ': BrandInfo(
        name: 'ヴァレクストラ',
        description: 'イタリア・ミラノ発の高級レザーグッズブランド。1937年創業。「イタリアのエルメス」とも称され、ミニマルで洗練されたデザインと品質が特徴。',
        url: 'https://www.valextra.jp/',
        foundationYear: 1937,
        country: 'イタリア',
        city: 'ミラノ'),

    // jewelryHighBrand
    'グラフ': BrandInfo(
        name: 'グラフ',
        description: 'イギリス・ロンドン発のハイジュエリーブランド。1960年創業。大粒で極上のダイヤモンドを扱うことで知られ、「21世紀のキング・オブ・ダイヤモンド」と称される。',
        url: 'https://www.graff.com/jp-ja/home/',
        foundationYear: 1960,
        country: 'イギリス',
        city: 'ロンドン'),
    'ピアジェ': BrandInfo(
        name: 'ピアジェ',
        description: 'スイスの高級時計・宝飾ブランド。1874年創業。極薄ムーブメントの時計製造技術と、大胆で華やかなジュエリーデザインで知られる。',
        url: 'https://www.piaget.com/jp-ja',
        foundationYear: 1874,
        country: 'スイス'),
    'ショーメ': BrandInfo(
        name: 'ショーメ',
        description: 'フランス・パリ発の名門ジュエラー。1780年創業。ナポレオンの御用達ジュエラーとして歴史をスタート。ティアラの制作で特に有名。',
        url: 'https://www.chaumet.com/jp_ja',
        foundationYear: 1780,
        country: 'フランス',
        city: 'パリ'),

    // fitness
    'ルルレモン': BrandInfo(
        name: 'ルルレモン',
        description: 'カナダ・バンクーバー発のアスレティックウェアブランド。1998年創業。ヨガウェアから始まり、高機能でスタイリッシュなデザインで人気。',
        url: 'https://www.lululemon.co.jp/',
        foundationYear: 1998,
        country: 'カナダ',
        city: 'バンクーバー'),
    'ゴールドジム': BrandInfo(
        name: 'ゴールドジム',
        description: 'アメリカ発の世界最大級のフィットネスクラブチェーン。トレーニングウェアやサプリメントなどの関連グッズも販売。',
        url: 'https://www.goldsgym.jp/',
        foundationYear: 1965,
        country: 'アメリカ'),
    'MYPROTEIN': BrandInfo(
        name: 'MYPROTEIN',
        description: 'イギリス発のスポーツ栄養ブランド。プロテインやサプリメントをオンラインで直販し、高品質・低価格で世界的に人気。',
        url: 'https://www.myprotein.jp/',
        foundationYear: 2004,
        country: 'イギリス'),
    'DNS': BrandInfo(
        name: 'DNS',
        description: '日本のスポーツサプリメントブランド。高品質なプロテインを中心に、アスリートのパフォーマンス向上をサポートする製品を展開。',
        url: 'https://www.dnszone.jp/',
        foundationYear: 2000,
        country: '日本'),
    'SAVAS': BrandInfo(
        name: 'SAVAS',
        description: '明治が展開する日本のプロテインブランド。1980年発売。目的やレベルに合わせた豊富なラインナップで、国内トップシェアを誇る。',
        url: 'https://www.meiji.co.jp/sports/savas/',
        foundationYear: 1980,
        country: '日本'),
    'VALX': BrandInfo(
        name: 'VALX',
        description: '日本のフィットネスブランド。トレーナー山本義徳氏が監修するサプリメントや、トレーニング器具、アパレルなどを展開。',
        url: 'https://valx.jp/',
        country: '日本'),

    // bicycle
    'ジャイアント': BrandInfo(
        name: 'ジャイアント',
        description: '台湾の世界最大の自転車メーカー。1972年創業。高い生産技術とコストパフォーマンスで、初心者からプロまで幅広い層に支持される。',
        url: 'https://www.giant.co.jp/',
        foundationYear: 1972,
        country: '台湾'),
    'トレック': BrandInfo(
        name: 'トレック',
        description: 'アメリカの自転車ブランド。1976年創業。高性能なロードバイクやマウンテンバイクで知られ、生涯保証など手厚いサポートも特徴。',
        url: 'https://www.trekbikes.com/jp/ja_JP/',
        foundationYear: 1976,
        country: 'アメリカ'),
    'スペシャライズド': BrandInfo(
        name: 'スペシャライズド',
        description: 'アメリカの自転車ブランド。1974年創業。「Innovate or Die（革新か、さもなくば死か）」を掲げ、革新的な製品を開発。',
        url: 'https://www.specialized.com/jp/ja/',
        foundationYear: 1974,
        country: 'アメリカ'),
    'ビアンキ': BrandInfo(
        name: 'ビアンキ',
        description: 'イタリアの老舗自転車ブランド。1885年創業。「チェレステ」と呼ばれる独特の青緑色がブランドカラーとして有名。',
        url: 'https://www.japan.bianchi.com/',
        foundationYear: 1885,
        country: 'イタリア'),
    'キャノンデール': BrandInfo(
        name: 'キャノンデール',
        description: 'アメリカの自転車ブランド。1971年創業。アルミフレーム製造に定評があり、独創的な技術やデザインで知られる。',
        url: 'https://www.cannondale.com/ja-jp',
        foundationYear: 1971,
        country: 'アメリカ'),
    'スコット': BrandInfo(
        name: 'スコット',
        description: 'スイスのスポーツ用品ブランド。自転車、スキー、モータースポーツなど多岐にわたる。軽量なカーボンフレーム技術で有名。',
        url: 'https://www.scott-japan.com/',
        foundationYear: 1958,
        country: 'スイス'),
    'ピナレロ': BrandInfo(
        name: 'ピナレロ',
        description: 'イタリアの高級ロードバイクブランド。1952年創業。独特のフレーム形状と高い走行性能で、数々のトップレースで勝利を収めている。',
        url: 'https://pinarello.com/japan/',
        foundationYear: 1952,
        country: 'イタリア'),
    'サーヴェロ': BrandInfo(
        name: 'サーヴェロ',
        description: 'カナダのロードバイク・トライアスロンバイクブランド。1995年創業。エアロダイナミクス（空力）を追求した設計のパイオニア。',
        url: 'https://cervelo.com/ja_JP/',
        foundationYear: 1995,
        country: 'カナダ'),
    'コルナゴ': BrandInfo(
        name: 'コルナゴ',
        description: 'イタリアの高級ロードバイクブランド。1954年創業。高い品質と美しい塗装で知られ、ロードレース界の伝説的存在。',
        url: 'https://www.colnago.co.jp/',
        foundationYear: 1954,
        country: 'イタリア'),
    'メリダ': BrandInfo(
        name: 'メリダ',
        description: '台湾の自転車メーカー。1972年創業。ジャイアントと並ぶ台湾の二大ブランドで、高品質な自転車をOEM生産と自社ブランドで展開。',
        url: 'https://www.merida.jp/',
        foundationYear: 1972,
        country: '台湾'),

    // bicycleSports
    'シマノ': BrandInfo(
        name: 'シマノ',
        description: '日本の自転車部品・釣具メーカー。1921年創業。変速機やブレーキなどの自転車部品で世界シェア約8割を誇る圧倒的トップ企業。',
        url: 'https://bike.shimano.com/ja-JP/home.html',
        foundationYear: 1921,
        country: '日本'),
    'カンパニョーロ': BrandInfo(
        name: 'カンパニョーロ',
        description: 'イタリアの高級自転車部品メーカー。1933年創業。美しいデザインと高い性能で、シマノと並ぶコンポーネントブランドの雄。',
        url: 'https://www.campagnolo.com/JP/ja/',
        foundationYear: 1933,
        country: 'イタリア'),
    'SRAM': BrandInfo(
        name: 'SRAM',
        description: 'アメリカの自転車部品メーカー。1987年創業。グリップシフトで市場に参入し、現在ではシマノ、カンパニョーロと並ぶ三大コンポーネントメーカーの一つ。',
        url: 'https://www.sram.com/en/sram',
        foundationYear: 1987,
        country: 'アメリカ'),
    'マヴィック': BrandInfo(
        name: 'マヴィック',
        description: 'フランスの自転車ホイール・部品メーカー。1889年創業。完組ホイールを世界で初めて製品化し、黄色のサポートカー「マヴィックカー」でも有名。',
        url: 'https://www.mavic.com/ja-jp',
        foundationYear: 1889,
        country: 'フランス'),
    'DT Swiss': BrandInfo(
        name: 'DT Swiss',
        description: 'スイスの自転車部品メーカー。スポークやハブなどの高性能なホイール関連部品で知られる。',
        url: 'https://www.dtswiss.com/en/',
        foundationYear: 1994,
        country: 'スイス'),
    'ZIPP': BrandInfo(
        name: 'ZIPP',
        description: 'アメリカの高性能ホイール・部品メーカー。SRAM傘下。カーボンホイールのパイオニアで、空力性能に優れた製品でトライアスロンやロードレースで人気。',
        url: 'https://www.sram.com/en/zipp',
        foundationYear: 1988,
        country: 'アメリカ'),
    'エンヴィ': BrandInfo(
        name: 'エンヴィ',
        description: 'アメリカの高級カーボン製自転車部品メーカー。ホイールやハンドルなどを製造。高い空力性能と品質で評価が高い。',
        url: 'https://www.enve.com/',
        foundationYear: 2007,
        country: 'アメリカ'),
    'フルクラム': BrandInfo(
        name: 'フルクラム',
        description: 'イタリアの自転車ホイールブランド。カンパニョーロの子会社として2004年設立。カンパニョーロとは異なる独自の技術や設計思想を持つ。',
        url: 'https://www.fulcrumwheels.com/ja',
        foundationYear: 2004,
        country: 'イタリア'),
    'ボントレガー': BrandInfo(
        name: 'ボントレガー',
        description: 'トレック傘下のパーツ・アクセサリーブランド。ヘルメット、シューズ、ホイールなど、幅広い製品を展開。',
        url: 'https://www.trekbikes.com/jp/ja_JP/bontrager/',
        country: 'アメリカ'),
    'オークリー': BrandInfo(
        name: 'オークリー',
        description: 'アメリカのスポーツ・ライフスタイルブランド。1975年創業。高性能なサングラスでスポーツ界を席巻。アパレルやゴーグルも展開。',
        url: 'https://www.oakley.com/ja-jp',
        foundationYear: 1975,
        country: 'アメリカ'),

    // vintageClothing (Shops)
    'BerBerJin': BrandInfo(
        name: 'BerBerJin',
        description: '東京・原宿を代表するヴィンテージ古着の名店。1997年オープン。特にヴィンテージデニムの品揃えは世界トップクラス。',
        url: 'https://berberjin.com/',
        foundationYear: 1997,
        country: '日本',
        city: '東京・原宿'),
    'JANTIQUES': BrandInfo(
        name: 'JANTIQUES',
        description: '東京・中目黒にあるヴィンテージショップ。衣類から雑貨、家具まで、オーナーが国内外で買い付けた年代・ジャンルレスなアイテムが揃う。',
        url: 'https://jantiques05.buyshop.jp/',
        country: '日本',
        city: '東京・中目黒'),
    'Santa Monica': BrandInfo(
        name: 'Santa Monica',
        description: '東京・原宿、渋谷などに店舗を構える古着屋。1979年創業。アメリカ西海岸の雰囲気を感じさせる、リーズナブルで質の良い古着が人気。',
        url: 'https://www.harajuku-santamonica.com/',
        foundationYear: 1979,
        country: '日本'),
    'KINJI': BrandInfo(
        name: 'KINJI',
        description: '大阪発祥の大型古着店。原宿にも店舗を構える。膨大な商品量と手頃な価格帯が特徴で、メンズ・レディース問わず幅広いアイテムが見つかる。',
        url: 'https://www.kinji.jp/',
        country: '日本',
        city: '大阪'),
    'WEGO VINTAGE': BrandInfo(
        name: 'WEGO VINTAGE',
        description: 'アパレルチェーンWEGOが展開するヴィンテージ専門ライン。手頃な価格でトレンドに合わせたヴィンテージアイテムを提案。',
        url: 'https://wego.jp/collections/vintage',
        country: '日本'),
    'FLAMINGO': BrandInfo(
        name: 'FLAMINGO',
        description: '原宿や下北沢に店舗を持つ古着屋。アメリカから直接買い付けた40〜90年代の古着を中心に、バイヤーが厳選したアイテムが並ぶ。',
        url: 'https://www.flamingo-online.jp/',
        country: '日本'),
    'NEW YORK JOE EXCHANGE': BrandInfo(
        name: 'NEW YORK JOE EXCHANGE',
        description: '東京・下北沢、吉祥寺にあるリサイクルショップ。トレード（物々交換）も可能なユニークなシステムが特徴。',
        url: 'https://newyorkjoeexchange.com/',
        country: '日本'),
    'RAGTAG': BrandInfo(
        name: 'RAGTAG',
        description: 'ブランド古着のセレクトショップ。国内外のデザイナーズブランドを中心に、コンディションの良い中古衣料品を販売・買取。',
        url: 'https://www.ragtag.jp/',
        foundationYear: 1985,
        country: '日本'),
    'Desert Snow': BrandInfo(
        name: 'Desert Snow',
        description: '東京・町田や下北沢などに店舗を持つ古着屋。アメリカ直輸入の古着を大量にストックし、リーズナブルな価格で提供。',
        url: 'https://desertsnow.jp/',
        country: '日本'),
    'Pigsty': BrandInfo(
        name: 'Pigsty',
        description: '大阪・アメ村や東京・渋谷に店舗を構える古着屋。1999年創業。バイヤーがアメリカで買い付けた良質なヴィンテージ＆レギュラー古着が揃う。',
        url: 'https://pigsty-web.com/',
        foundationYear: 1999,
        country: '日本'),

    // antiques (Shops)
    'THE GLOBE ANTIQUES': BrandInfo(
        name: 'THE GLOBE ANTIQUES',
        description: '東京・三宿にある大型アンティークショップ。イギリスを中心にヨーロッパで買い付けた家具や雑貨、食器などが3フロアにわたって並ぶ。',
        url: 'https://www.globe-antiques.com/',
        country: '日本',
        city: '東京・三宿'),
    'Lloyd\'s Antiques': BrandInfo(
        name: 'Lloyd\'s Antiques',
        description: '1988年創業のアンティーク家具店。イギリスの伝統的なアンティーク家具から北欧のモダンデザインまで、質の高いアイテムをセレクト。',
        url: 'https://www.lloyds.co.jp/',
        foundationYear: 1988,
        country: '日本'),
    'DEMODE KEY STATION': BrandInfo(
        name: 'DEMODE KEY STATION',
        description: '福生や渋谷にあるインテリアショップ。アメリカのヴィンテージ家具やインダストリアル系のアイテムを中心に扱う。',
        url: 'https://demode-key.com/',
        country: '日本'),
    'ANTRO': BrandInfo(
        name: 'ANTRO',
        description: '東京・目黒通りにあるヴィンテージ家具・雑貨店。北欧やアメリカのミッドセンチュリー期のアイテムを中心に、ユニークな品揃えが特徴。',
        url: 'https://antro.jp/',
        country: '日本',
        city: '東京・目黒'),
    'CEROTE ANTIQUES': BrandInfo(
        name: 'CEROTE ANTIQUES',
        description: '東京・幡ヶ谷や大阪に店舗を持つアンティーク＆ヴィンテージショップ。ヨーロッパやアメリカのインダストリアル家具や照明が豊富。',
        url: 'https://cerote-antiques.com/',
        country: '日本'),
    'PTAH': BrandInfo(
        name: 'PTAH',
        description: '東京・吉祥寺にある小さなアンティークショップ。フランスやイギリスの古道具や雑貨など、生活に寄り添う味わい深いアイテムを扱う。',
        url: 'http://ptah.jp/',
        country: '日本',
        city: '東京・吉祥寺'),
    'GALLUP': BrandInfo(
        name: 'GALLUP',
        description: '東京・世田谷にショールームを持つ、ヴィンテージ建材やDIYパーツの専門店。古材やアイアンパーツなど、空間作りのための素材が揃う。',
        url: 'https://www.thegallup.com/',
        country: '日本'),
    'アンティークモール銀座': BrandInfo(
        name: 'アンティークモール銀座',
        description: '東京・銀座にある日本最大級のアンティークモール。約25のディーラーが出店し、和骨董から西洋アンティーク、宝飾品まで幅広く扱う。',
        url: 'https://www.antiques-jp.com/',
        country: '日本',
        city: '東京・銀座'),
    'BROCANTE': BrandInfo(
        name: 'BROCANTE',
        description: '東京・自由が丘などにあるフレンチアンティークの店。フランスで買い付けたシャビーシックな家具や雑貨、リネン類などが人気。',
        url: 'https://brocante-jp.com/',
        country: '日本'),
    'Found': BrandInfo(
        name: 'Found',
        description: '東京・吉祥寺にあるアンティーク・古道具店。日本の古い家具や道具を中心に、シンプルで美しい生活骨董をセレクト。',
        url: 'https://www.found-f.com/',
        country: '日本',
        city: '東京・吉祥寺'),

    // streetStyle
    'Supreme': BrandInfo(
        name: 'Supreme',
        description: '1994年ニューヨーク発のスケートボードショップ・ブランド。ストリートカルチャーのアイコン的存在で、毎週の新作発売（ドロップ）は世界的な話題となる。',
        url: 'https://jp.supreme.com/',
        foundationYear: 1994,
        country: 'アメリカ',
        city: 'ニューヨーク'),
    'Stussy': BrandInfo(
        name: 'Stussy',
        description: '1980年南カリフォルニア発のストリートブランド。創設者のショーン・ステューシーのサインがロゴの原型。サーフカルチャーを原点に持つ。',
        url: 'https://stussy.jp/',
        foundationYear: 1980,
        founder: 'ショーン・ステューシー',
        country: 'アメリカ',
        city: 'カリフォルニア'),
    'A BATHING APE': BrandInfo(
        name: 'A BATHING APE',
        description: '1993年NIGO®により東京・原宿で設立されたストリートブランド。「BAPE」の略称で知られ、猿の顔をモチーフにしたロゴやカモフラージュ柄が象徴的。',
        url: 'https://bape.com/',
        foundationYear: 1993,
        founder: 'NIGO®',
        country: '日本',
        city: '東京・原宿'),
    'Off-White': BrandInfo(
        name: 'Off-White',
        description: '2013年ヴァージル・アブローにより設立されたファッションブランド。ラグジュアリーとストリートを融合させたスタイルで、世界的な人気を博す。',
        url: 'https://www.off---white.com/',
        foundationYear: 2013,
        founder: 'ヴァージル・アブロー',
        country: 'イタリア',
        city: 'ミラノ'),
    'Palace Skateboards': BrandInfo(
        name: 'Palace Skateboards',
        description: '2009年ロンドン発のスケートボードブランド。三角形のロゴ「Tri-Ferg」が特徴で、ユーモアのあるデザインと本格的なスケートカルチャーが融合。',
        url: 'https://www.palaceskateboards.com/',
        foundationYear: 2009,
        country: 'イギリス',
        city: 'ロンドン'),
    'KITH': BrandInfo(
        name: 'KITH',
        description: '2011年ロニー・ファイグによりニューヨークで設立されたスニーカーセレクトショップ・ブランド。数々の有名ブランドとのコラボレーションで知られる。',
        url: 'https://kithtokyo.com/',
        foundationYear: 2011,
        founder: 'ロニー・ファイグ',
        country: 'アメリカ',
        city: 'ニューヨーク'),
    'HUF': BrandInfo(
        name: 'HUF',
        description: '2002年プロスケーターのキース・ハフナゲルによりサンフランシスコで設立されたブランド。スケートボードとストリートカルチャーを反映したアパレルやスニーカーを展開。',
        url: 'https://hufworldwide.jp/',
        foundationYear: 2002,
        founder: 'キース・ハフナゲル',
        country: 'アメリカ',
        city: 'サンフランシスコ'),
    'Carhartt WIP': BrandInfo(
        name: 'Carhartt WIP',
        description: 'アメリカのワークウェアブランドCarharttを、ヨーロッパの視点で再解釈したライン。「Work In Progress」の略。よりファッション性の高いデザインが特徴。',
        url: 'https://carhartt-wip.jp/',
        foundationYear: 1989,
        country: 'ドイツ'),
    'X-LARGE': BrandInfo(
        name: 'X-LARGE',
        description: '1991年ロサンゼルス発のストリートブランド。ゴリラのロゴ「O.G.ゴリラ」が象徴的。音楽やアートなど様々なカルチャーを融合したスタイルを提案。',
        url: 'https://xlarge.jp/',
        foundationYear: 1991,
        country: 'アメリカ',
        city: 'ロサンゼルス'),
    'Undefeated': BrandInfo(
        name: 'Undefeated',
        description: '2002年ロサンゼルス発のスニーカーブティック・ブランド。「勝利」を意味するブランド名で、スポーツやミリタリーの要素を取り入れたデザインが特徴。',
        url: 'https://undefeated.jp/',
        foundationYear: 2002,
        country: 'アメリカ',
        city: 'ロサンゼルス'),

    // gyaruStyle
    'CECIL McBEE': BrandInfo(
        name: 'CECIL McBEE',
        description: '1980年代後半に誕生した日本のレディースファッションブランド。ギャル文化を象徴するブランドの一つとして、モテを意識したフェミニンでセクシーなスタイルを提案。',
        url: 'https://cecilmcbee.jp/',
        foundationYear: 1987,
        country: '日本'),
    'EGOIST': BrandInfo(
        name: 'EGOIST',
        description: '1999年に誕生した日本のレディースファッションブランド。渋谷109を拠点に、グラマラスでエッジの効いたスタイルを提案。',
        url: 'https://egoist-store.jp/',
        foundationYear: 1999,
        country: '日本'),
    'rienda': BrandInfo(
        name: 'rienda',
        description: '2006年に誕生した日本のレディースファッションブランド。セクシーでありながらも上品さを失わない「センシュアル」なスタイルが特徴。',
        url: 'https://www.rienda.vc/',
        foundationYear: 2006,
        country: '日本'),
    'LIP SERVICE': BrandInfo(
        name: 'LIP SERVICE',
        description: '2000年に誕生した日本のレディースファッションブランド。「強さと色気」をコンセプトに、セクシーでクールなスタイルを提案。',
        url: 'https://lipservice.jp/',
        foundationYear: 2000,
        country: '日本'),
    'Delyle NOIR': BrandInfo(
        name: 'Delyle NOIR',
        description: '日本のレディースファッションブランド。ラグジュアリーでセクシーな「お姉さん系」スタイルを提案し人気だったが、現在はブランド休止中。',
        url: 'https://delyle.jp/',
        country: '日本'),
    'DaTuRa': BrandInfo(
        name: 'DaTuRa',
        description: '日本のレディースファッションブランド。「天使の羽」シリーズなど、デコラティブで甘めなセクシーさが特徴の「悪羅ギャル」系ブランドとして人気だったが、現在はブランド休止中。',
        url: 'https://datura.jp/',
        country: '日本'),
    'RESEXXY': BrandInfo(
        name: 'RESEXXY',
        description: '2012年に誕生した日本のレディースファッションブランド。「異性からの視線を意識した、女性らしいシルエットやディテール」をコンセプトとする。',
        url: 'https://resexxy.runway-webstore.com/',
        foundationYear: 2012,
        country: '日本'),
    'GYDA': BrandInfo(
        name: 'GYDA',
        description: '2011年に誕生した日本のレディースファッションブランド。西海岸LAの空気感をイメージソースに、ヘルシーでセクシーなカジュアルスタイルを提案。',
        url: 'https://gyda.jp/',
        foundationYear: 2011,
        country: '日本'),
    'MOUSSY': BrandInfo(
        name: 'MOUSSY',
        description: '2000年に誕生した日本のレディースファッションブランド。デニムを軸とした、クールでスタイリッシュなカジュアルスタイルが特徴。「マウジーデニム」は一世を風靡した。',
        url: 'https://www.moussy.ne.jp/',
        foundationYear: 2000,
        country: '日本'),
    'SLY': BrandInfo(
        name: 'SLY',
        description: '2003年に誕生したMOUSSYの姉妹ブランド。「セクシーで新しい」をコンセプトに、よりモードでエッジの効いたスタイルを提案。',
        url: 'https://sly.jp/',
        foundationYear: 2003,
        country: '日本'),

    // japaneseDesigner
    'COMME des GARÇONS': BrandInfo(
        name: 'COMME des GARÇONS',
        description: '1969年川久保玲により設立された日本のファッションブランド。既存の美の概念を覆す前衛的なデザインで、世界のファッション界に衝撃を与え続けている。',
        url: 'https://www.comme-des-garcons.com/',
        foundationYear: 1969,
        founder: '川久保玲',
        country: '日本'),
    'Yohji Yamamoto': BrandInfo(
        name: 'Yohji Yamamoto',
        description: '1981年山本耀司がパリコレデビューした日本のファッションブランド。「黒」を基調とし、身体と服の間に生まれる「間」を重視した、アシンメトリーでドレープ豊かなデザインが特徴。',
        url: 'https://www.yohjiyamamoto.co.jp/',
        foundationYear: 1981,
        founder: '山本耀司',
        country: '日本'),
    'ISSEY MIYAKE': BrandInfo(
        name: 'ISSEY MIYAKE',
        description: '1971年三宅一生により設立された日本のファッションブランド。「一枚の布」という考え方を基本に、プリーツ加工など独自の素材開発と機能的なデザインで世界的に知られる。',
        url: 'https://www.isseymiyake.com/',
        foundationYear: 1971,
        founder: '三宅一生',
        country: '日本'),
    'sacai': BrandInfo(
        name: 'sacai',
        description: '1999年阿部千登勢により設立された日本のファッションブランド。「日常の上に成り立つデザイン」をコンセプトに、異素材の組み合わせや斬新なシルエットが特徴。',
        url: 'https://www.sacai.jp/',
        foundationYear: 1999,
        founder: '阿部千登勢',
        country: '日本'),
    'UNDERCOVER': BrandInfo(
        name: 'UNDERCOVER',
        description: '1990年高橋盾により設立された日本のファッションブランド。パンクやアートなど、様々なカルチャーを反映した、破壊的でありながら繊細な美しさを持つデザインで評価が高い。',
        url: 'https://undercoverism.com/',
        foundationYear: 1990,
        founder: '高橋盾',
        country: '日本'),
    'TOGA': BrandInfo(
        name: 'TOGA',
        description: '1997年古田泰子により設立された日本のファッションブランド。異素材ミックスやウエスタン調のメタルパーツが特徴で、独創的で複雑なカッティングが魅力。',
        url: 'https://toga.jp/',
        foundationYear: 1997,
        founder: '古田泰子',
        country: '日本'),
    'beautiful people': BrandInfo(
        name: 'beautiful people',
        description: '2007年熊切秀典らにより設立された日本のファッションブランド。「ライダースジャケット」や、大人と子供が共有できる「キッズシリーズ」が有名。',
        url: 'https://beautiful-people.jp/',
        foundationYear: 2007,
        founder: '熊切秀典',
        country: '日本'),
    'kolor': BrandInfo(
        name: 'kolor',
        description: '2004年阿部潤一により設立された日本のファッションブランド。素材やパターンのバランスにこだわり、独創的でありながらリアルクローズとして成立するデザインが特徴。',
        url: 'https://kolor.jp/',
        foundationYear: 2004,
        founder: '阿部潤一',
        country: '日本'),
    'N.HOOLYWOOD': BrandInfo(
        name: 'N.HOOLYWOOD',
        description: '2001年尾花大輔により設立された日本のファッションブランド。古着やヴィンテージウェアをデザインソースに、現代的なシルエットやディテールで再構築したコレクションを展開。',
        url: 'https://n-hoolywood.com/',
        foundationYear: 2001,
        founder: '尾花大輔',
        country: '日本'),
    'White Mountaineering': BrandInfo(
        name: 'White Mountaineering',
        description: '2006年相澤陽介により設立された日本のアウトドアウェアブランド。「服を着るフィールドは全てアウトドア」をコンセプトに、デザイン、実用性、技術を融合。',
        url: 'https://whitemountaineering.com/',
        foundationYear: 2006,
        founder: '相澤陽介',
        country: '日本'),
    'HYKE': BrandInfo(
        name: 'HYKE',
        description: '2013年吉原秀明と大出由紀子により設立された日本のファッションブランド。「HERITAGE AND EVOLUTION」をコンセプトに、古着やミリタリーウェアを現代的に再構築。',
        url: 'https://hyke.jp/',
        foundationYear: 2013,
        founder: '吉原秀明, 大出由紀子',
        country: '日本'),
    'Mame Kurogouchi': BrandInfo(
        name: 'Mame Kurogouchi',
        description: '2010年黒河内真衣子により設立された日本のファッションブランド。伝統的な技術や繊細な刺繍を取り入れた、女性の曲線美を引き立てるエレガントで知的なデザインが特徴。',
        url: 'https://www.mamekurogouchi.com/',
        foundationYear: 2010,
        founder: '黒河内真衣子',
        country: '日本'),
    'visvim': BrandInfo(
  name: 'visvim',
  description: '2001年に中村ヒロキによって設立された日本のファッションブランド。「タイムレスな、オーセンティックなプロダクト」作りを追求し、世界中から集めた天然素材や伝統技法を駆使した、こだわり抜かれたウェアやシューズを展開。FBTスニーカーはブランドの象徴的存在。',
  url: 'https://www.visvim.tv/',
  foundationYear: 2001,
  founder: '中村ヒロキ',
  country: '日本',
),
  };

  /// BrandInfoオブジェクトを取得するヘルパーメソッド
  static BrandInfo getBrandInfo(String brandName) {
    if (allBrands.containsKey(brandName)) {
      return allBrands[brandName]!;
    }
    // allBrandsに未定義のブランドがあった場合、空の情報を返す
    return BrandInfo(name: brandName, description: '詳細情報が未登録です。');
  }

  /// 全ジャンルのリストを返す
  static List<SearchGenre> getAllGenres() {
    return SearchGenre.values;
  }

  /// 指定されたジャンルのブランド情報リストを返す
  static List<BrandInfo> getBrandInfosForGenre(SearchGenre genre) {
    final brandNames = getBrandNamesForGenre(genre);
    return brandNames.map((name) => getBrandInfo(name)).toList();
  }

    static Map<String, String> get brandTopPageUrls {
    return {
      for (var entry in allBrands.entries)
        if (entry.value.url.isNotEmpty) // URLが設定されているものだけを対象
          entry.key: entry.value.url
    };
  }

  /// 指定されたジャンルのブランド名リストを返す (内部利用)
  static List<String> getBrandNamesForGenre(SearchGenre genre) {
    switch (genre) {
      case SearchGenre.lifestyle:
        return _availableLifestyleBrands;
      case SearchGenre.apparel:
        return _availableApparelBrands;
      case SearchGenre.outdoor:
        return _availableOutdoorBrands;
      case SearchGenre.bag:
        return _availableBagBrands;
      case SearchGenre.sports:
        return _availableSportsBrands;
      case SearchGenre.sneakers:
        return _availableSneakersBrands;
      case SearchGenre.furniture:
        return _availableFurnitureBrands;
      case SearchGenre.kitchenware:
        return _availableKitchenwareBrands;
      case SearchGenre.homedecor:
        return _availableHomedecorBrands;
      case SearchGenre.beddingbath:
        return _availableBeddingbathBrands;
      case SearchGenre.jewelry:
        return _availableJewelryBrands;
      case SearchGenre.watches:
        return _availableWatchesBrands;
      case SearchGenre.eyewear:
        return _availableEyewearBrands;
      case SearchGenre.electronics:
        return _availableElectronicsBrands;
      case SearchGenre.audiodevices:
        return _availableAudiodevicesBrands;
      case SearchGenre.cameras:
        return _availableCamerasBrands;
      case SearchGenre.stationery:
        return _availableStationeryBrands;
      case SearchGenre.musicalinstruments:
        return _availableMusicalinstrumentsBrands;
      case SearchGenre.beauty:
        return _availableBeautyBrands;
      case SearchGenre.healthcare:
        return _availableHealthcareBrands;
      case SearchGenre.petsupplies:
        return _availablePetsuppliesBrands;
      case SearchGenre.apparelHighBrand:
        return _availableApparelHighBrandBrands;
      case SearchGenre.furnitureHighBrand:
        return _availableFurnitureHighBrandBrands;
      case SearchGenre.bagHighBrand:
        return _availableBagHighBrandBrands;
      case SearchGenre.jewelryHighBrand:
        return _availableJewelryHighBrandBrands;
      case SearchGenre.fitness:
        return _availableFitnessBrands;
      case SearchGenre.bicycle:
        return _availableBicycleBrands;
      case SearchGenre.bicycleSports:
        return _availableBicycleSportsBrands;
      case SearchGenre.vintageClothing:
        return _availableVintageClothingShops;
      case SearchGenre.antiques:
        return _availableAntiquesShops;
      case SearchGenre.streetStyle:
        return _availableStreetStyleBrands;
      case SearchGenre.gyaruStyle:
        return _availableGyaruStyleBrands;
      case SearchGenre.japaneseDesigner:
        return _availableJapaneseDesignerBrands;
    }
  }

  /// ジャンルの表示名を返す
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
      case SearchGenre.vintageClothing:
        return "ヴィンテージ古着";
      case SearchGenre.antiques:
        return "アンティーク";
      case SearchGenre.streetStyle:
        return "ストリート";
      case SearchGenre.gyaruStyle:
        return "ギャル系";
      case SearchGenre.japaneseDesigner:
        return "日本人デザイナーズ";
    }
  }

  // 各ジャンルのブランド名リスト (内部利用)
  static const List<String> _availableLifestyleBrands = ['無印良品', 'イケア', 'ニトリ','seria','Francfranc','LOWYA','ベルメゾン','LOFT','東急ハンズ', 'ACTUS'];
  static const List<String> _availableApparelBrands = ['ユニクロ', 'GU', 'ZARA', 'H&M', 'BEAMS', 'しまむら', 'Right-on', 'GAP', 'アーバンリサーチ', 'ユナイテッドアローズ', 'ナノユニバース', 'ジャーナルスタンダード'];
  static const List<String> _availableOutdoorBrands = ['コールマン', 'スノーピーク', 'ロゴス', 'モンベル', 'パタゴニア', 'ザ・ノース・フェイス', 'キャプテンスタッグ', 'DOD', 'ヘリノックス', 'チャムス', 'マムート', 'ミレー'];
  static const List<String> _availableBagBrands = ['ポーター', 'マンハッタンポーテージ', 'グレゴリー', 'アークテリクス', 'ミステリーランチ', 'ケルティ', 'オスプレー', 'カリマー', 'ブリーフィング', 'トゥミ'];
  static const List<String> _availableSportsBrands = ['ナイキ', 'アディダス', 'プーマ', 'アシックス', 'ミズノ', 'アンダーアーマー', 'ニューバランス', 'デサント', 'ルコックスポルティフ', 'ヨネックス'];
  static const List<String> _availableSneakersBrands = ['ナイキ', 'アディダス', 'ニューバランス', 'コンバース', 'バンズ', 'リーボック', 'プーマ', 'アシックス', 'オニツカタイガー', 'サッカニー'];
  static const List<String> _availableFurnitureBrands = ['カリモク家具', 'マルニ木工', '天童木工', 'ハーマンミラー', 'ヴィトラ', 'カッシーナ', 'B&B Italia', 'アルフレックス', 'フリッツ・ハンセン', 'イデー'];
  static const List<String> _availableKitchenwareBrands = ['ル・クルーゼ', 'ストウブ', 'WMF', 'フィスラー', 'ビタクラフト', 'ツヴィリング J.A. ヘンケルス', 'グローバル', '野田琺瑯', '柳宗理', 'イッタラ'];
  static const List<String> _availableHomedecorBrands = ['HAY', 'menu', 'ferm LIVING', 'Normann Copenhagen', 'Muuto', '&Tradition', 'GUBI', 'MOHEIM', 'イデー', 'ザラホーム'];
  static const List<String> _availableBeddingbathBrands = ['西川', 'エアウィーヴ', 'テンピュール', 'シモンズ', 'サータ', 'フランスベッド', '内野', '今治タオル', 'ホットマン', 'テネリータ'];
  static const List<String> _availableJewelryBrands = ['ティファニー', 'カルティエ', 'ブルガリ', 'ヴァンクリーフ＆アーペル', 'ハリー・ウィンストン', 'ショパール', 'ブシュロン', 'ミキモト', 'タサキ', '4℃'];
  static const List<String> _availableWatchesBrands = ['ロレックス', 'オメガ', 'タグ・ホイヤー', 'ブライトリング', 'IWC', 'セイコー', 'シチズン', 'カシオ', 'グランドセイコー', 'パネライ'];
  static const List<String> _availableEyewearBrands = ['レイバン', 'オリバーピープルズ', 'トムフォード', 'アイヴァン', 'フォーナインズ', '金子眼鏡', '白山眼鏡店', 'JINS', 'Zoff', 'OWNDAYS'];
  static const List<String> _availableElectronicsBrands = ['パナソニック', 'ソニー', '日立', '三菱電機', 'シャープ', 'ダイソン', 'バルミューダ', 'Apple', 'Samsung', 'LG'];
  static const List<String> _availableAudiodevicesBrands = ['ソニー', 'ボーズ', 'ゼンハイザー', 'オーディオテクニカ', 'JBL', 'Bang & Olufsen', 'Shure', 'AKG', 'Beats by Dr. Dre', 'ヤマハ'];
  static const List<String> _availableCamerasBrands = ['キヤノン', 'ニコン', 'ソニー', '富士フイルム', 'オリンパス', 'パナソニック', 'ライカ', 'GoPro', 'DJI', 'リコー'];
  static const List<String> _availableStationeryBrands = ['コクヨ', 'パイロット', '三菱鉛筆', 'ゼブラ', 'ぺんてる', 'トンボ鉛筆', 'デザインフィル', '伊東屋', 'LOFT', 'キングジム'];
  static const List<String> _availableMusicalinstrumentsBrands = ['ヤマハ', 'ローランド', 'コルグ', 'フェンダー', 'ギブソン', 'マーティン', 'パール', 'タマ', 'カワイ', 'スタインウェイ'];
  static const List<String> _availableBeautyBrands = ['資生堂', '花王', 'コーセー', 'ポーラ', 'SK-II', 'ランコム', 'エスティローダー', 'シャネル', 'ディオール', 'イヴ・サンローラン'];
  static const List<String> _availableHealthcareBrands = ['オムロン', 'タニタ', 'テルモ', 'パナソニック ヘルスケア', 'フィリップス', 'ブラウン', 'ドクターエア', 'シックスパッド', 'ファイテン', 'ガーミン'];
  static const List<String> _availablePetsuppliesBrands = ['アイリスオーヤマ', 'ユニ・チャーム ペット', 'いなばペットフード', 'ピュリナ', 'ロイヤルカナン', 'ヒルズ', 'ペティオ', 'ドギーマン', 'リッチェル', 'GEX'];
  static const List<String> _availableApparelHighBrandBrands = ['シャネル', 'エルメス', 'ルイ・ヴィトン', 'グッチ', 'プラダ', 'ディオール', 'サンローラン', 'バレンシアガ', 'セリーヌ', 'フェンディ'];
  static const List<String> _availableFurnitureHighBrandBrands = ['カッシーナ', 'B&B Italia', 'ポリフォーム', 'アルフレックス', 'ミノッティ', 'フレックスフォルム', 'デパドヴァ', 'ポルトローナ・フラウ', 'リーン・ロゼ', 'フリッツ・ハンセン'];
  static const List<String> _availableBagHighBrandBrands = ['エルメス', 'シャネル', 'ルイ・ヴィトン', 'グッチ', 'プラダ', 'セリーヌ', 'ロエベ', 'ゴヤール', 'デルヴォー', 'ヴァレクストラ'];
  static const List<String> _availableJewelryHighBrandBrands = ['ハリー・ウィンストン', 'ヴァンクリーフ＆アーペル', 'カルティエ', 'ブルガリ', 'ティファニー', 'ショパール', 'グラフ', 'ブシュロン', 'ピアジェ', 'ショーメ'];
  static const List<String> _availableFitnessBrands = ['ルルレモン', 'ナイキ', 'アディダス', 'アンダーアーマー', 'リーボック', 'ゴールドジム', 'MYPROTEIN', 'DNS', 'SAVAS', 'VALX'];
  static const List<String> _availableBicycleBrands = ['ジャイアント', 'トレック', 'スペシャライズド', 'ビアンキ', 'キャノンデール', 'スコット', 'ピナレロ', 'サーヴェロ', 'コルナゴ', 'メリダ'];
  static const List<String> _availableBicycleSportsBrands = ['シマノ', 'カンパニョーロ', 'SRAM', 'マヴィック', 'DT Swiss', 'ZIPP', 'エンヴィ', 'フルクラム', 'ボントレガー', 'オークリー'];
  static const List<String> _availableVintageClothingShops = ['BerBerJin', 'JANTIQUES', 'Santa Monica', 'KINJI', 'WEGO VINTAGE', 'FLAMINGO', 'NEW YORK JOE EXCHANGE', 'RAGTAG', 'Desert Snow', 'Pigsty'];
  static const List<String> _availableAntiquesShops = ['THE GLOBE ANTIQUES', "Lloyd's Antiques", 'DEMODE KEY STATION', 'ANTRO', 'CEROTE ANTIQUES', 'PTAH', 'GALLUP', 'アンティークモール銀座', 'BROCANTE', 'Found'];
  static const List<String> _availableStreetStyleBrands = ['Supreme', 'Stussy', 'A BATHING APE', 'Off-White', 'Palace Skateboards', 'KITH', 'HUF', 'Carhartt WIP', 'X-LARGE', 'Undefeated'];
  static const List<String> _availableGyaruStyleBrands = ['CECIL McBEE', 'EGOIST', 'rienda', 'LIP SERVICE', 'Delyle NOIR', 'DaTuRa', 'RESEXXY', 'GYDA', 'MOUSSY', 'SLY'];
  static const List<String> _availableJapaneseDesignerBrands = ['COMME des GARÇONS', 'Yohji Yamamoto', 'ISSEY MIYAKE', 'sacai', 'UNDERCOVER', 'TOGA', 'beautiful people', 'kolor', 'N.HOOLYWOOD', 'White Mountaineering', 'HYKE', 'Mame Kurogouchi', 'visvim'];
}