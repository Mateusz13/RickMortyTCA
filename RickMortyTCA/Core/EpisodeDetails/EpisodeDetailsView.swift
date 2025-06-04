//
//  EpisodeDetailsView.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 04/06/2025.
//

import SwiftUI
import ComposableArchitecture

struct EpisodeDetailsView: View {
    var store: StoreOf<EpisodeDetailsReducer>

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                // Content Section
                ScrollView {
                    VStack(spacing: 24) {
                        episodeInfoCard
                        characterCountCard
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        HStack {
            Spacer()
            closeButton
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
    
    // MARK: - Episode Info Card
    private var episodeInfoCard: some View {
        VStack(spacing: 20) {
            // Episode Title
            VStack(spacing: 8) {
                Text(store.episode.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                Text(store.episode.episode)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            // Episode Details Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                DetailCard(
                    icon: "calendar",
                    title: "Air Date",
                    value: store.episode.airDate,
                    color: .orange
                )
                
                DetailCard(
                    icon: "tv",
                    title: "Episode",
                    value: store.episode.episode,
                    color: .blue
                )
            }
        }
        .padding(24)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Character Count Card
    private var characterCountCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person.3")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.purple)
                
                Text("Characters")
                    .font(.headline)
                
                Spacer()
                
                Text("\(store.episode.characters.count)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.purple)
                    .clipShape(Circle())
            }
            
            Text("This episode features \(store.episode.characters.count) characters from the Rick and Morty universe.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Close Button
    private var closeButton: some View {
        Button {
            store.send(.closeButtonTapped)
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 30, height: 30)
                .background(Color.gray.opacity(0.5))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: false)
    }
}

// MARK: - Preview
#Preview {
    EpisodeDetailsView(
        store: Store(
            initialState: EpisodeDetailsReducer.State(
                episode: Episode(
                    id: 1,
                    name: "Pilot",
                    airDate: "December 2, 2013",
                    episode: "S01E01",
                    characters: [
                        "https://rickandmortyapi.com/api/character/1",
                        "https://rickandmortyapi.com/api/character/2",
                        "https://rickandmortyapi.com/api/character/35"
                    ]
                )
            ),
            reducer: {
                EpisodeDetailsReducer()
            }
        )
    )
}
