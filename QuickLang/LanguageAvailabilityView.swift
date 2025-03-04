//
//  LanguageAvailabilityView.swift
//  QuickLang
//
//  Created by Tokunaga Tetsuya on 2025/03/03.
//

// LanguageAvailabilityView.swift
import SwiftUI
import Translation

/// 言語モデルの利用可能性を確認し、ダウンロードを促進するビュー
struct LanguageAvailabilityView: View {
    // 入力として言語ペアを受け取る
    var sourceLanguage: LanguageOption
    var targetLanguage: LanguageOption
    
    // クロージャを使って結果を親ビューに戻す
    var onDismiss: () -> Void
    
    // 内部状態
    @State private var isChecking = true
    @State private var isAvailable = false
    @State private var statusMessage = "言語モデルの確認中..."
    @State private var isDownloading = false
    @State private var config: TranslationSession.Configuration? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("翻訳モデルの確認")
                .font(.headline)
            
            if isChecking {
                ProgressView("言語モデルを確認しています...")
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("元の言語:")
                        Text(sourceLanguage.displayName)
                            .bold()
                    }
                    
                    HStack {
                        Text("翻訳先言語:")
                        Text(targetLanguage.displayName)
                            .bold()
                    }
                    
                    HStack {
                        Text("状態:")
                        Text(statusMessage)
                            .foregroundColor(isAvailable ? .green : .red)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.textBackgroundColor).opacity(0.5))
                .cornerRadius(8)
                
                if isAvailable {
                    if isDownloading {
                        ProgressView("モデルをダウンロード中...")
                    } else {
                        Button("翻訳モデルをダウンロード") {
                            downloadTranslationModel()
                        }
                        .disabled(statusMessage.contains("インストール済み"))
                    }
                }
                
                Button("閉じる") {
                    onDismiss()
                }
                .keyboardShortcut(.escape)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
        .onAppear {
            checkLanguageAvailability()
        }
        .translationTask(config) { session in
            Task { @MainActor in
                await downloadModel(session: session)
            }
        }
    }
    
    // 言語モデルの利用可能性をチェック
    private func checkLanguageAvailability() {
        Task { @MainActor in
            let sourceLang = sourceLanguage.localeLanguage
            let targetLang = targetLanguage.localeLanguage
            
            // ターゲット言語が必要
            guard let targetLang = targetLang else {
                isChecking = false
                isAvailable = false
                statusMessage = "ターゲット言語が無効です"
                return
            }
            
            // 利用可能性をチェック
            let (available, message) = await TranslationManager.checkAvailability(
                source: sourceLang,
                target: targetLang
            )
            
            isChecking = false
            isAvailable = available
            statusMessage = message
        }
    }
    
    // 翻訳モデルのダウンロードを開始
    private func downloadTranslationModel() {
        let sourceLang = sourceLanguage.localeLanguage
        let targetLang = targetLanguage.localeLanguage
        
        guard let targetLang = targetLang else { return }
        
        isDownloading = true
        
        // TranslationSessionの設定を作成してダウンロードを開始
        config = TranslationSession.Configuration(
            source: sourceLang,
            target: targetLang
        )
    }
    
    // モデルダウンロードプロセス
    private func downloadModel(session: TranslationSession) async {
        // 翻訳モデルを準備
        let (success, message) = await TranslationManager.prepareModel(session: session)
        
        // UI更新
        isDownloading = false
        statusMessage = message
        
        // 設定をクリア
        if success {
            config = nil
        }
    }
}

// プレビュー
struct LanguageAvailabilityView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageAvailabilityView(
            sourceLanguage: .auto,
            targetLanguage: .japanese,
            onDismiss: {}
        )
    }
}
