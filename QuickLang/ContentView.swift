// ContentView.swift
import SwiftUI
import Translation

struct ContentView: View {
    // 入力テキストと翻訳結果の状態
    @State private var sourceText: String = ""
    @State private var translatedText: String? = nil
    
    // 言語選択の状態
    @State private var selectedSourceLanguage: LanguageOption = .auto
    @State private var selectedTargetLanguage: LanguageOption = .japanese
    
    // 翻訳状態の管理
    @State private var isTranslating: Bool = false
    @State private var translationError: String? = nil
    @State private var config: TranslationSession.Configuration? = nil
    
    // コピー状態
    @State private var hasCopied: Bool = false
    
    // 設定画面の状態
    @State private var showLanguageAvailability: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            // ツールバー
            toolbarArea
            
            // 入力エリア
            sourceInputArea
            
            // 言語選択と翻訳ボタン
            languageSelectionArea
            
            // 翻訳結果エリア
            translationResultArea
        }
        .padding()
        // シートの表示設定
        .sheet(isPresented: $showLanguageAvailability) {
            LanguageAvailabilityView(
                sourceLanguage: selectedSourceLanguage,
                targetLanguage: selectedTargetLanguage,
                onDismiss: { showLanguageAvailability = false }
            )
        }
        // 翻訳タスクの設定
        .translationTask(config) { session in
            Task { @MainActor in
                do {
                    if !sourceText.isEmpty {
                        isTranslating = true
                        translationError = nil
                        
                        // 翻訳を実行
                        let response = try await session.translate(sourceText)
                        translatedText = response.targetText
                        
                        isTranslating = false
                    }
                } catch {
                    handleTranslationError(error)
                }
            }
        }
    }
    
    // 入力テキストエリア
    private var sourceInputArea: some View {
        VStack(alignment: .leading) {
            Text("翻訳するテキスト")
                .font(.headline)
            
            TextEditor(text: $sourceText)
                .font(.body)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(.textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    // 言語選択エリア
    private var languageSelectionArea: some View {
        HStack(spacing: 20) {
            // ソース言語選択
            VStack(alignment: .leading) {
                Text("元の言語")
                    .font(.headline)
                Picker("", selection: $selectedSourceLanguage) {
                    ForEach(LanguageOption.sourceOptions, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .frame(minWidth: 150)
            }
            
            // 矢印
            Image(systemName: "arrow.right")
                .foregroundColor(.secondary)
            
            // ターゲット言語選択
            VStack(alignment: .leading) {
                Text("翻訳先")
                    .font(.headline)
                Picker("", selection: $selectedTargetLanguage) {
                    ForEach(LanguageOption.targetOptions, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .frame(minWidth: 150)
            }
            
            Spacer()
            
            // 翻訳ボタン
            Button(action: toggleTranslation) {
                if isTranslating {
                    Text("キャンセル")
                } else {
                    Text("翻訳")
                }
            }
            .keyboardShortcut(.return, modifiers: .command)
            .buttonStyle(.borderedProminent)
            .disabled(sourceText.isEmpty)
        }
    }
    
    // 翻訳結果エリア
    private var translationResultArea: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("翻訳結果")
                    .font(.headline)
                
                Spacer()
                
                if let _ = translatedText, !isTranslating {
                    Button(action: copyToClipboard) {
                        Label(hasCopied ? "コピー済み" : "コピー", systemImage: hasCopied ? "checkmark" : "doc.on.doc")
                    }
                    .buttonStyle(.borderless)
                }
            }
            
            ZStack(alignment: .topLeading) {
                // 背景
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.textBackgroundColor))
                    .frame(minHeight: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                // コンテンツ
                Group {
                    if isTranslating {
                        VStack {
                            Spacer()
                            ProgressView("翻訳中...")
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    } else if let error = translationError {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else if let result = translatedText {
                        ScrollView {
                            Text(result)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                                .padding()
                        }
                    } else {
                        Text("翻訳結果がここに表示されます")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
        }
    }
    
    // 翻訳トグル機能
    private func toggleTranslation() {
        if isTranslating {
            // 翻訳中の場合はキャンセル
            config?.invalidate()
            config = nil
            isTranslating = false
        } else {
            // 新しい翻訳を開始
            startTranslation()
        }
    }
    
    // 翻訳開始
    private func startTranslation() {
        if sourceText.isEmpty {
            return
        }
        
        // 重要: いったん設定をnilにして値の変更をトリガーする
        config = nil
        
        // UIの更新を確実にするため、次のランループまで待つ
        DispatchQueue.main.async {
            // 源言語と対象言語のLocale.Languageオブジェクトを取得
            let sourceLang = self.selectedSourceLanguage.localeLanguage
            let targetLang = self.selectedTargetLanguage.localeLanguage
            
            // 新しいTranslationSession.Configurationを作成
            self.config = TranslationSession.Configuration(
                source: sourceLang,
                target: targetLang
            )
        }
    }
    
    // クリップボードにコピー
    private func copyToClipboard() {
        guard let textToCopy = translatedText else { return }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(textToCopy, forType: .string)
        
        // コピー通知を表示して数秒後に消す
        hasCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            hasCopied = false
        }
    }
    
    // ツールバーエリア
    private var toolbarArea: some View {
        HStack {
            Spacer()
            
            Button(action: {
                showLanguageAvailability = true
            }) {
                Label("言語の設定", systemImage: "gear")
            }
            .buttonStyle(.borderless)
        }
    }
    
    // エラーハンドリング
    private func handleTranslationError(_ error: Error) {
        isTranslating = false
        translationError = TranslationManager.userFriendlyErrorMessage(for: error)
    }
}

// プレビュー
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
