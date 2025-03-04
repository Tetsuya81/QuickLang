//
//  TranslationManager.swift
//  QuickLang
//
//  Created by Tokunaga Tetsuya on 2025/03/03.
//

// TranslationManager.swift
import Foundation
import Translation

/// 翻訳関連の補助機能を提供するクラス
class TranslationManager {
    
    /// 言語ペアの翻訳可能状態をチェック
    /// - Parameters:
    ///   - source: ソース言語（オプショナル、nilの場合は自動検出）
    ///   - target: ターゲット言語
    /// - Returns: 状態と詳細メッセージのタプル
    static func checkAvailability(
        source: Locale.Language?,
        target: Locale.Language
    ) async -> (available: Bool, message: String) {
        
        let availability = LanguageAvailability()
        
        do {
            // ソースがnilの場合（自動検出）、英語をダミーとして使用
            let sourceToCheck = source ?? Locale.Language(languageCode: .english)
            
            // 言語対の利用可能性をチェック
            let status = try await availability.status(
                from: sourceToCheck,
                to: target
            )
            
            switch status {
            case .installed:
                return (true, "翻訳モデルはインストール済みです")
            case .supported:
                return (true, "翻訳モデルは利用可能ですが、ダウンロードが必要です")
            case .unsupported:
                return (false, "指定された言語ペアはサポートされていません")
            @unknown default:
                return (false, "不明なステータスです")
            }
        } catch {
            return (false, "利用可能性の確認に失敗しました: \(error.localizedDescription)")
        }
    }
    
    /// 翻訳モデルを事前にダウンロード
    /// - Parameters:
    ///   - session: 翻訳セッション
    /// - Returns: 成功したかどうかと詳細メッセージのタプル
    static func prepareModel(session: TranslationSession) async -> (success: Bool, message: String) {
        do {
            // 翻訳モデルの準備を開始
            try await session.prepareTranslation()
            return (true, "翻訳モデルの準備が完了しました")
        } catch {
            return (false, "翻訳モデルの準備に失敗しました: \(error.localizedDescription)")
        }
    }
    
    /// エラーメッセージをユーザーフレンドリーに変換
    /// - Parameter error: 翻訳エラー
    /// - Returns: ユーザー向けエラーメッセージ
    static func userFriendlyErrorMessage(for error: Error) -> String {
        // エラーの種類に応じてカスタムメッセージを返す
        if let nsError = error as NSError? {
            switch nsError.domain {
            case "TranslationErrorDomain":
                switch nsError.code {
                case 1: // 適切なエラーコードに置き換えてください
                    return "言語モデルのダウンロードに失敗しました。ネットワーク接続を確認してください。"
                case 2: // 適切なエラーコードに置き換えてください
                    return "この言語ペアは翻訳できません。別の言語を選択してみてください。"
                default:
                    break
                }
            default:
                break
            }
        }
        
        // デフォルトエラーメッセージ
        return "翻訳中にエラーが発生しました: \(error.localizedDescription)"
    }
}
