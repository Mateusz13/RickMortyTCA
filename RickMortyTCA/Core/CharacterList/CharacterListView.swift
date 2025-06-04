//
//  CharacterLIstView.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 03/06/2025.
//

import SwiftUI
import ComposableArchitecture

struct CharactersListView: View {
    @Perception.Bindable var store: StoreOf<CharactersListReducer>
    
    private let gridColumns = [
        GridItem(.adaptive(minimum: 150.0, maximum: 200.0), spacing: 32),
        GridItem(.adaptive(minimum: 150.0, maximum: 200.0), spacing: 32)
    ]
    
    var body: some View {
        NavigationView {
            WithPerceptionTracking {
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    
                    if store.showCharactersList {
                        charactersListContent
                    } else {
                        welcomeContent
                    }
                    toggleButton
                }
                .onAppear {
                    store.send(.favoritesDataUpdated)
                }
                .alert($store.scope(state: \.alert, action: \.alert))
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private var charactersListContent: some View {
        VStack(spacing: 0) {
            navigationHeader
            searchField
            charactersGrid
        }
    }
    
    // MARK: - Navigation Header
    private var navigationHeader: some View {
        HStack {
            Text("Rick & Morty")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }
    
    private var charactersGrid: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(store.characters) { character in
                    characterRow(for: character)
                }
            }
            .padding()
        }
        .onChange(of: store.searchText) { _ in
            Task {
                await handleSearchDebounce()
            }
        }
    }
    
    private func characterRow(for character: Character) -> some View {

            NavigationLink {
                characterDetailsView(for: character)
            } label: {
                CharacterCard(
                    imageURL: character.image,
                    name: character.name,
                    isFavorite: store.favoritesID.contains(character.id)
                )
                .onAppear {
                    if character.id == store.characters.last?.id {
                        store.send(.reachedBottomOnList)
                    }
                }
            }
            .buttonStyle(.plain)
    }

    //Character details view
    private func characterDetailsView(for character: Character) -> some View {
        CharacterDetailsView(
            store: Store(
                initialState: CharacterDetailsReducer.State(
                    character: character,
                    isFavorite: store.favoritesID.contains(character.id)
                ),
                reducer: {
                    CharacterDetailsReducer()
                }
            )
        )
    }

    //Search debounce logic
    private func handleSearchDebounce() async {
        do {
            try await Task.sleep(nanoseconds: 300_000_000)
            await store.send(.searchTriggered).finish()
        } catch { }
    }
    
    //Search field
    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 16, weight: .medium))
        
            TextField("Search characters...", text: $store.searchText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            if !store.searchText.isEmpty {
                Button {
                    store.send(.searchCleared)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: store.searchText.isEmpty)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var welcomeContent: some View {
        VStack(spacing: 24) {
            Image(systemName: "tv")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("Rick and Morty")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Character Explorer")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Text("Tap the eye button below to discover characters from the Rick and Morty universe")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            // Feature highlights
            VStack(spacing: 12) {
                FeatureRow(icon: "magnifyingglass", title: "Search Characters", description: "Find your favorite characters")
                FeatureRow(icon: "heart", title: "Save Favorites", description: "Keep track of characters you love")
                FeatureRow(icon: "tv", title: "Episode Details", description: "Explore character appearances")
            }
            .padding(.vertical)
            .padding(.horizontal, 40)
        }
    }
    
    //Toggle button
    private var toggleButton: some View {
        Button {
            store.send(.showListButtonTapped)
        } label: {
            Circle()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
                .overlay {
                    Image(systemName: store.showCharactersList ? "eye.slash" : "eye")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(44)
    }
}

#Preview {
    CharactersListView(
        store: Store(
            initialState: CharactersListReducer.State()
        ) {
            CharactersListReducer()
        }
    )
}
