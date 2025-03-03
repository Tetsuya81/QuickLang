import SwiftUI

struct LanguageSelectionView: View {
    @Binding var selectedLanguage: Locale.Language?
    let languages: [Locale.Language]
    let includeAutoDetect: Bool
    let title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            
            Picker(title, selection: $selectedLanguage) {
                if includeAutoDetect {
                    Text("Auto Detect").tag(nil as Locale.Language?)
                }
                
                ForEach(languages, id: \.self) { language in
                    Text(LanguageUtils.getDisplayName(for: language))
                        .tag(includeAutoDetect ? (language as Locale.Language?) : language)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
        }
    }
}
