//
//  CharacterDetailsView.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 04/06/2025.
//

import SwiftUI
import ComposableArchitecture

struct CharacterDetailsView: View {
    @Perception.Bindable var store: StoreOf<CharacterDetailsReducer>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        WithPerceptionTracking {
            NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                        characterImageSection
                        characterInfoCard
                        episodesSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(Color(UIColor.systemGroupedBackground))
                .sheet(isPresented: $store.episodeDetailsIsPresented.sending(\.presentEpisodeDetails)) {
                    episodeDetailsSheet
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    favoriteButton
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    // MARK: - Character Image Section
    private var characterImageSection: some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: store.character.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemGray5))
                    .overlay {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
            }
            .frame(width: 280, height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            Text(store.character.name)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Character Info Card
    private var characterInfoCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Character Info")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                InfoCard(title: "Status", value: store.character.status, color: statusColor)
                InfoCard(title: "Gender", value: store.character.gender, color: .blue)
                InfoCard(title: "Origin", value: store.character.origin.name, color: .orange)
                InfoCard(title: "Location", value: store.character.location.name, color: .purple)
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Episodes Section
    private var episodesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Episodes")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(store.character.episode.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(UIColor.systemGray5))
                    .clipShape(Capsule())
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(store.character.episode, id: \.self) { episodeURL in
                    EpisodeCard(episodeNumber: episodeURL.mapEpisodeURLToNumber()) {
                        store.send(.episodeTapped(episode: episodeURL))
                    }
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Episode Details Sheet
    @ViewBuilder
    private var episodeDetailsSheet: some View {
        if let episodeStore = store.scope(state: \.episodeDetails, action: \.episodeDetails) {
            EpisodeDetailsView(store: episodeStore)
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Back Button
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.black.opacity(0.6))
                .clipShape(Circle())
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                )
        }
    }
    
    // MARK: - Favorite Button
    private var favoriteButton: some View {
        Button {
            store.send(.favoriteButtonTapped)
        } label: {
            Image(systemName: store.isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(store.isFavorite ? .white : .red)
                .frame(width: 32, height: 32)
                .background(store.isFavorite ? Color.red : Color.black.opacity(0.6))
                .clipShape(Circle())
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                )
        }
        .scaleEffect(store.isFavorite ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: store.isFavorite)
    }
    
    // MARK: - Helper Properties
    private var statusColor: Color {
        switch store.character.status.lowercased() {
        case "alive": return .green
        case "dead": return .red
        default: return .gray
        }
    }
}

// MARK: - Info Card Component
struct InfoCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Episode Card Component
struct EpisodeCard: View {
    let episodeNumber: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("EP")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                
                Text(episodeNumber)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(UIColor.separator), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: false)
    }
}

// MARK: - Preview
#Preview {
    CharacterDetailsView(
        store: Store(
            initialState: CharacterDetailsReducer.State(
                character: Character(
                    id: 1,
                    name: "Rick Sanchez",
                    status: "Alive",
                    gender: "Male",
                    origin: Origin(name: "Earth (C-137)"),
                    location: LastKnownLocation(name: "Citadel of Ricks"),
                    image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
                    episode: [
                        "https://rickandmortyapi.com/api/episode/1",
                        "https://rickandmortyapi.com/api/episode/2",
                        "https://rickandmortyapi.com/api/episode/3"
                    ]
                ),
                isFavorite: false
            ),
            reducer: {
                CharacterDetailsReducer()
            }
        )
    )
}
