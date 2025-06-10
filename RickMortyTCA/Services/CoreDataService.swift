//
//  CoreDataService.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 04/06/2025.
//

import Foundation
import CoreData
import Dependencies

struct CoreDataClient {
    var favoritesList: @Sendable () -> Set<Int>
    var addFavorite: @Sendable (Int) async throws -> Void
    var removeFavorite: @Sendable (Int) async throws -> Void
}

extension CoreDataClient: DependencyKey {
    static var liveValue: Self {
        let coreDataStack = CoreDataStack.shared
        
        return CoreDataClient(
            favoritesList: {
                let context = coreDataStack.context
                let fetchRequest: NSFetchRequest<FavoriteCharacter> = FavoriteCharacter.fetchRequest()
                
                do {
                    let favorites = try context.fetch(fetchRequest)
                    return Set(favorites.map { Int($0.characterID) })
                } catch {
                    print("Failed to load favorites: \(error)")
                    return Set<Int>()
                }
            },
            
            addFavorite: { id in
                let backgroundContext = coreDataStack.backgroundContext()
                
                try await withCheckedThrowingContinuation { continuation in
                    backgroundContext.perform {
                        do {
                            let fetchRequest: NSFetchRequest<FavoriteCharacter> = FavoriteCharacter.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "characterID == %d", id)
                            
                            let existingFavorites = try backgroundContext.fetch(fetchRequest)
                            
                            if existingFavorites.isEmpty {
                                let favorite = FavoriteCharacter(context: backgroundContext)
                                favorite.characterID = Int32(id)
                                try backgroundContext.save()
                            }
                            
                            continuation.resume()
                        } catch {
                            continuation.resume(throwing: CoreDataError.saveFailed(error.localizedDescription))
                        }
                    }
                }
            },
            
            removeFavorite: { id in
                let backgroundContext = coreDataStack.backgroundContext()
                
                try await withCheckedThrowingContinuation { continuation in
                    backgroundContext.perform {
                        do {
                            let fetchRequest: NSFetchRequest<FavoriteCharacter> = FavoriteCharacter.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "characterID == %d", id)
                            
                            let favoritesToDelete = try backgroundContext.fetch(fetchRequest)
                            favoritesToDelete.forEach { backgroundContext.delete($0) }
                            
                            try backgroundContext.save()
                            continuation.resume()
                        } catch {
                            continuation.resume(throwing: CoreDataError.deleteFailed(error.localizedDescription))
                        }
                    }
                }
            }
        )
    }
}

extension DependencyValues {
    var coreDataClient: CoreDataClient {
        get { self[CoreDataClient.self] }
        set { self[CoreDataClient.self] = newValue }
    }
}
