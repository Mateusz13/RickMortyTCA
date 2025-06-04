//
//  CharacterCard.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 02/06/2025.
//

import SwiftUI

struct CharacterCard: View {
    let imageURL: String
    let name: String
    let isFavorite: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .scaleEffect(1.2)
                case .success(let image):
                    image.resizable()
                case .failure:
                    tryAgain()
                default:
                    Color(UIColor.systemGray5)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(.rect(cornerRadius: 16.0))
            .aspectRatio(contentMode: .fill)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            LinearGradient(colors: [.black.opacity(0.6), .black.opacity(0.3), .clear], startPoint: .bottom, endPoint: .center)
                .clipShape(.rect(cornerRadius: 16.0))

            RoundedRectangle(cornerRadius: 8.0)
                .fill(.ultraThinMaterial)
                .frame(maxHeight: 40.0)
                .overlay {
                    Text(name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16.0))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(alignment: .topTrailing) {
            if isFavorite {
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 30.0, height: 30.0)
                    .foregroundStyle(Color.green)
                    .padding(10.0)
                    .offset(x: 20.0, y: -20.0)
            }
        }
    }

    func tryAgain() -> some View {
        AsyncImage(url: URL(string: imageURL)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .scaleEffect(1.2)
            case .success(let image):
                image.resizable()
            case .failure:
                Color(UIColor.systemGray4)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
            default:
                Color(UIColor.systemGray4)
            }
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        CharacterCard(
            imageURL: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
            name: "Rick Sanchez",
            isFavorite: true
        )
        .frame(width: 150)
        
        CharacterCard(
            imageURL: "https://rickandmortyapi.com/api/character/avatar/2.jpeg",
            name: "Morty Smith",
            isFavorite: false
        )
        .frame(width: 150)
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
