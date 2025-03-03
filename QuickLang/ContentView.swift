import SwiftUI
import Translation

struct ContentView: View {
    // Text input and output
    @State private var sourceText = ""
    @State private var translatedText: String?
    
    // Translation state
    @State private var isTranslating = false
    @State private var config: TranslationSession.Configuration? = nil
    
    // Language selection
    @State private var sourceLanguage: Locale.Language? = nil // nil means auto-detect
    @State private var targetLanguage: Locale.Language = Locale.current.language
    
    // Language model download
    @State private var showingLanguageDownloadPrompt = false
    @State private var languagePairToDownload: (source: Locale.Language?, target: Locale.Language)?
    
    // Translation service
    @StateObject private var translationService = TranslationService()
    
    // Available languages from utility
    let availableLanguages = LanguageUtils.getSupportedLanguages()
    
    var body: some View {
        VStack(spacing: 20) {
            // Language selection section
            HStack {
                LanguageSelectionView(
                    selectedLanguage: $sourceLanguage,
                    languages: availableLanguages,
                    includeAutoDetect: true,
                    title: "Source Language"
                )
                
                Spacer()
                
                // Swap languages button
                Button(action: {
                    let temp = sourceLanguage
                    sourceLanguage = targetLanguage
                    targetLanguage = temp ?? Locale.current.language
                }) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.title2)
                }
                .buttonStyle(.borderless)
                .disabled(sourceLanguage == nil)
                
                Spacer()
                
                LanguageSelectionView(
                    selectedLanguage: Binding(
                        get: { targetLanguage },
                        set: { if let lang = $0 { targetLanguage = lang } }
                    ),
                    languages: availableLanguages,
                    includeAutoDetect: false,
                    title: "Target Language"
                )
            }
            .padding([.horizontal, .top])
            
            // Source text input section
            VStack(alignment: .leading, spacing: 5) {
                Text("Enter text to translate")
                    .font(.headline)
                
                TextEditor(text: $sourceText)
                    .font(.body)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(.horizontal)
            
            // Translate button section
            HStack {
                Button(action: {
                    Task {
                        // Check language model availability first
                        let sourceToCheck = sourceLanguage ?? Locale.Language(languageCode: .english) // Default to English if auto-detect
                        
                        await translationService.checkAvailability(from: sourceToCheck, to: targetLanguage)
                        
                        if let status = translationService.availabilityStatus {
                            switch status {
                            case .installed:
                                // Model is installed, proceed with translation
                                config = TranslationSession.Configuration(source: sourceLanguage, target: targetLanguage)
                            case .supported:
                                // Model is supported but not installed, prompt for download
                                languagePairToDownload = (sourceLanguage, targetLanguage)
                                showingLanguageDownloadPrompt = true
                            case .unsupported:
                                // Language pair is not supported
                                translatedText = "This language pair is not supported for translation."
                            @unknown default:
                                break
                            }
                        }
                    }
                }) {
                    Text("Translate")
                        .frame(minWidth: 100)
                }
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(sourceText.isEmpty || isTranslating)
                
                if isTranslating {
                    Button(action: {
                        config?.invalidate()
                        config = nil
                        isTranslating = false
                    }) {
                        Text("Cancel")
                            .frame(minWidth: 100)
                    }
                }
            }
            
            // Translation result section
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Translation Result")
                        .font(.headline)
                    
                    Spacer()
                    
                    if let text = translatedText, !text.isEmpty {
                        Button(action: {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(text, forType: .string)
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        .buttonStyle(.borderless)
                    }
                }
                
                ZStack(alignment: .center) {
                    TextEditor(text: Binding(
                        get: { translatedText ?? "" },
                        set: { translatedText = $0 }
                    ))
                    .font(.body)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    
                    if isTranslating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom)
        .translationTask(config) { session in
            Task { @MainActor in
                do {
                    isTranslating = true
                    let response = try await session.translate(sourceText)
                    translatedText = response.targetText
                    isTranslating = false
                    config = nil // Reset config after successful translation
                } catch {
                    translatedText = "Translation error: \(error.localizedDescription)"
                    isTranslating = false
                    config = nil
                }
            }
        }
        .alert("Download Translation Model", isPresented: $showingLanguageDownloadPrompt) {
            Button("Download") {
                if let pair = languagePairToDownload {
                    let newConfig = TranslationSession.Configuration(source: pair.source, target: pair.target)
                    config = newConfig
                }
                showingLanguageDownloadPrompt = false
            }
            Button("Cancel", role: .cancel) {
                showingLanguageDownloadPrompt = false
            }
        } message: {
            Text("The translation model for this language pair needs to be downloaded. Would you like to download it now?")
        }
        .alert(
            "Translation Error",
            isPresented: Binding(
                get: { translationService.errorMessage != nil },
                set: { if !$0 { translationService.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(translationService.errorMessage ?? "An unknown error occurred")
        }
    }
}

#Preview {
    ContentView()
}
