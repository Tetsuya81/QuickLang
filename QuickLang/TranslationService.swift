//
//  TranslationService.swift
//  QuickLang
//
//  Created by Tokunaga Tetsuya on 2025/03/03.
//

import Foundation
import Translation

class TranslationService: ObservableObject {
    private let availability = LanguageAvailability()
    
    @Published var isCheckingAvailability = false
    @Published var availabilityStatus: LanguageAvailability.Status?
    @Published var errorMessage: String?
    
    /// Check if translation is available for the specified language pair
    func checkAvailability(from source: Locale.Language?, to target: Locale.Language) async {
        guard let source = source else {
            // When source is nil (auto-detect), we'll check a common language like English
            await checkAvailability(from: Locale.Language(languageCode: .english), to: target)
            return
        }
        
        do {
            await MainActor.run {
                isCheckingAvailability = true
                errorMessage = nil
                availabilityStatus = nil
            }
            
            let status = try await availability.status(from: source, to: target)
            
            await MainActor.run {
                self.availabilityStatus = status
                self.isCheckingAvailability = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isCheckingAvailability = false
            }
        }
    }
    
    /// Prepare translation by downloading the language model if needed
    func prepareTranslation(session: TranslationSession) async -> Bool {
        do {
            await MainActor.run {
                errorMessage = nil
            }
            
            try await session.prepareTranslation()
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
}
