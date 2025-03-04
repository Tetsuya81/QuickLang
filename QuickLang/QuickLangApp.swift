//
//  QuickLangApp.swift
//  QuickLang
//
//  Created by Tokunaga Tetsuya on 2025/03/03.
//

import SwiftUI

@main
struct QuickLangApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 600, minHeight: 500)
                .navigationTitle("QuickLang")
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("QuickLang について") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.applicationName: "QuickLang",
                            NSApplication.AboutPanelOptionKey.applicationVersion: "1.0.0",
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: "シンプルで高速な翻訳アプリ"
                            )
                        ]
                    )
                }
            }
        }
    }
}
