import Foundation

struct LanguageUtils {
    static func getDisplayName(for language: Locale.Language?) -> String {
        guard let language = language else {
            return "Auto Detect"
        }
        
        // Get a better language display name using Locale's method for language code
        if let langCode = language.languageCode?.identifier {
            return Locale.current.localizedString(forLanguageCode: langCode) ?? langCode
        }
        
        return "Unknown"
    }
    
    static func getSupportedLanguages() -> [Locale.Language] {
        // This is a subset of languages supported by the Translation framework
        // based on the documentation
        return [
            .init(languageCode: .english),
            .init(languageCode: .japanese),
            .init(languageCode: .spanish),
            .init(languageCode: .french),
            .init(languageCode: .german),
            .init(languageCode: .italian),
            .init(languageCode: .chinese),
            .init(languageCode: .russian),
            .init(languageCode: .korean),
            .init(languageCode: .arabic),
            .init(languageCode: .portuguese),
            .init(languageCode: .turkish),
            .init(languageCode: .thai),
            .init(languageCode: .indonesian),
            .init(languageCode: .polish),
            .init(languageCode: .ukrainian),
            .init(languageCode: .vietnamese),
            .init(languageCode: .hindi)
        ]
    }
}
