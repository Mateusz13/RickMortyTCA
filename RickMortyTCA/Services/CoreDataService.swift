//
//  CoreDataService.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 04/06/2025.
//

import Foundation
import CoreData
import Dependencies

final class CoreDataService: ObservableObject {
    
    private let coreDataStack: CoreDataStack
    
    @Published private(set) var favoritesList = Set<Int>()
    
    // MARK: - Initialization
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
        Task {
            await loadFavorites()
        }
    }
    
    // MARK: - Public Methods
    func addFavorite(id: Int) async throws {
        try await withCheckedThrowingContinuation { continuation in
            let backgroundContext = coreDataStack.backgroundContext()
            
            backgroundContext.perform {
                do {
                    // Check if already exists
                    let fetchRequest: NSFetchRequest<FavoriteCharacter> = FavoriteCharacter.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "characterID == %d", id)
                    
                    let existingFavorites = try backgroundContext.fetch(fetchRequest)
                    
                    if existingFavorites.isEmpty {
                        // Create new favorite
                        let favorite = FavoriteCharacter(context: backgroundContext)
                        favorite.characterID = Int32(id)
                        
                        try backgroundContext.save()
                        
                        // Update on main thread
                        Task { @MainActor in
                            self.favoritesList.insert(id)
                        }
                    }
                    
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: CoreDataError.saveFailed(error.localizedDescription))
                }
            }
        }
    }
    
    func removeFavorite(id: Int) async throws {
        try await withCheckedThrowingContinuation { continuation in
            let backgroundContext = coreDataStack.backgroundContext()
            
            backgroundContext.perform {
                do {
                    let fetchRequest: NSFetchRequest<FavoriteCharacter> = FavoriteCharacter.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "characterID == %d", id)
                    
                    let favoritesToDelete = try backgroundContext.fetch(fetchRequest)
                    
                    for favorite in favoritesToDelete {
                        backgroundContext.delete(favorite)
                    }
                    
                    try backgroundContext.save()
                    
                    // Update on main thread
                    Task { @MainActor in
                        self.favoritesList.remove(id)
                    }
                    
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: CoreDataError.deleteFailed(error.localizedDescription))
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadFavorites() async {
        do {
            let context = coreDataStack.context
            let fetchRequest: NSFetchRequest<FavoriteCharacter> = FavoriteCharacter.fetchRequest()
            
            let favorites = try context.fetch(fetchRequest)
            let favoriteIDs = Set(favorites.map { Int($0.characterID) })
            
            Task { @MainActor in
                self.favoritesList = favoriteIDs
            }
        } catch {
            print("Failed to load favorites: \(error)")
            // Fallback to empty set
            Task { @MainActor in
                self.favoritesList = Set<Int>()
            }
        }
    }
}

// MARK: - Favorites Dependency
private enum FavoritesDependency: DependencyKey {
    static let liveValue = CoreDataService(coreDataStack: .shared)
}

extension DependencyValues {
    var coreDataService: CoreDataService {
        get { self[FavoritesDependency.self] }
        set { self[FavoritesDependency.self] = newValue }
    }
}
