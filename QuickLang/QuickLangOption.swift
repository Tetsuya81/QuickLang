//
//  QuickLangOption.swift
//  QuickLang
//
//  Created by Tokunaga Tetsuya on 2025/03/03.
//

// LanguageOption.swift
import Foundation
import Translation

/// 言語選択オプションを表す列挙型
enum LanguageOption: Hashable, Identifiable {
    case auto // 自動検出
    case english // 英語
    case japanese // 日本語
    case spanish // スペイン語
    case french // フランス語
    case german // ドイツ語
    case chinese // 中国語（簡体字）
    case traditionalChinese // 中国語（繁体字）
    case korean // 韓国語
    case russian // ロシア語
    case arabic // アラビア語
    case portuguese // ポルトガル語
    case italian // イタリア語
    case turkish // トルコ語
    case thai // タイ語
    case vietnamese // ベトナム語
    case indonesian // インドネシア語
    
    var id: Self { self }
    
    /// 表示名
    var displayName: String {
        switch self {
        case .auto: return "自動検出"
        case .english: return "英語"
        case .japanese: return "日本語"
        case .spanish: return "スペイン語"
        case .french: return "フランス語"
        case .german: return "ドイツ語"
        case .chinese: return "中国語 (簡体字)"
        case .traditionalChinese: return "中国語 (繁体字)"
        case .korean: return "韓国語"
        case .russian: return "ロシア語"
        case .arabic: return "アラビア語"
        case .portuguese: return "ポルトガル語"
        case .italian: return "イタリア語"
        case .turkish: return "トルコ語"
        case .thai: return "タイ語"
        case .vietnamese: return "ベトナム語"
        case .indonesian: return "インドネシア語"
        }
    }
    
    /// Locale.Language型への変換
    var localeLanguage: Locale.Language? {
        switch self {
        case .auto: return nil // 自動検出の場合はnilを返す
        case .english: return Locale.Language(languageCode: .english)
        case .japanese: return Locale.Language(languageCode: .japanese)
        case .spanish: return Locale.Language(languageCode: .spanish)
        case .french: return Locale.Language(languageCode: .french)
        case .german: return Locale.Language(languageCode: .german)
        case .chinese: return Locale.Language(languageCode: .chinese)
        case .traditionalChinese: return Locale.Language(identifier: "zh-Hant")
        case .korean: return Locale.Language(languageCode: .korean)
        case .russian: return Locale.Language(languageCode: .russian)
        case .arabic: return Locale.Language(languageCode: .arabic)
        case .portuguese: return Locale.Language(languageCode: .portuguese)
        case .italian: return Locale.Language(languageCode: .italian)
        case .turkish: return Locale.Language(languageCode: .turkish)
        case .thai: return Locale.Language(languageCode: .thai)
        case .vietnamese: return Locale.Language(languageCode: .vietnamese)
        case .indonesian: return Locale.Language(languageCode: .indonesian)
        }
    }
    
    /// ソース言語として使用可能なオプション（自動検出を含む）
    static var sourceOptions: [LanguageOption] {
        return [.auto, .english, .japanese, .spanish, .french, .german, .chinese,
                .traditionalChinese, .korean, .russian, .arabic, .portuguese,
                .italian, .turkish, .thai, .vietnamese, .indonesian]
    }
    
    /// ターゲット言語として使用可能なオプション（自動検出を除く）
    static var targetOptions: [LanguageOption] {
        return [.english, .japanese, .spanish, .french, .german, .chinese,
                .traditionalChinese, .korean, .russian, .arabic, .portuguese,
                .italian, .turkish, .thai, .vietnamese, .indonesian]
    }
}
