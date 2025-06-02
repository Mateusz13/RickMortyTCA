//
//  Network.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 02/06/2025.
//

import Foundation

struct NetworkService {
    
    // MARK: - Response Models
    struct CharactersResponse: Codable {
        let results: [Character]
    }
    
    // MARK: - Constants
    private static let baseURL = "https://rickandmortyapi.com/api"
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    // MARK: - Public Methods
    static func fetchCharactersList(for page: Int, filter: String? = nil) async throws -> [Character] {
        let url = try buildCharactersURL(page: page, filter: filter)
        
        do {
            let response: CharactersResponse = try await performRequest(url: url)
            return response.results
        } catch NetworkServiceErrors.invalidResponse {
            if filter != nil {
                return []
            }
            throw NetworkServiceErrors.invalidResponse
        }
    }

    static func fetchEpisodeDetails(for episodeURL: String) async throws -> Episode {
        guard let url = URL(string: episodeURL) else {
            throw NetworkServiceErrors.wrongURL
        }
        
        return try await performRequest(url: url)
    }
}

// MARK: - Private Methods
private extension NetworkService {
    
    static func buildCharactersURL(page: Int, filter: String?) throws -> URL {
        var components = URLComponents(string: "\(baseURL)/character")!
        
        var queryItems = [URLQueryItem(name: "page", value: "\(page)")]
        
        if let filter = filter?.trimmingCharacters(in: .whitespacesAndNewlines), !filter.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: filter))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw NetworkServiceErrors.wrongURL
        }
        
        return url
    }
    
    static func performRequest<T: Codable>(url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard
            let response = response as? HTTPURLResponse,
            response.statusCode == 200
        else {
            throw NetworkServiceErrors.invalidResponse
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw NetworkServiceErrors.invalidData
        }
    }
}

enum NetworkServiceErrors: Error {
    case wrongURL, invalidResponse, invalidData
}

extension NetworkServiceErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .wrongURL:
            "Wrong URL. Cannot download data."
        case .invalidResponse:
            "Invalid response, check your internet connection."
        case .invalidData:
            "Data is invalid, try again."
        }
    }
}
