//
//  DetailCard.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 04/06/2025.
//

import SwiftUI

struct DetailCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DetailCard(icon: "tv",
               title: "Episode",
               value: "S01E07",
               color: .blue)
}
