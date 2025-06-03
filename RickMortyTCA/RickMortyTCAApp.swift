//
//  RickMortyTCAApp.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 02/06/2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct RickMortyTCAApp: App {
    static let store = Store(
        initialState: CharactersListReducer.State()
    ) {
        CharactersListReducer()
    }
    var body: some Scene {
        WindowGroup {
            CharactersListView(store: Self.store)
                .onAppear {
                     setupAppAppearance()
                 }
        }
    }
}

private func setupAppAppearance() {
    // Force light mode for entire app
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        windowScene.windows.forEach { window in
            window.overrideUserInterfaceStyle = .light
        }
    }
}
