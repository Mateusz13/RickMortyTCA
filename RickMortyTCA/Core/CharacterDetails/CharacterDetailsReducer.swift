//
//  CharacterDetailsReducer.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 04/06/2025.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CharacterDetailsReducer {
    @ObservableState
    struct State {
        @Presents var alert: AlertState<Action.Alert>?
        @Presents var episodeDetails: EpisodeDetailsReducer.State?
        let character: Character
        var episode: Episode?
        var isFavorite: Bool
    }
    
    @Dependency(\.coreDataClient) var favoriteRepository

    enum Action {
        case episodeTapped(episode: String)
        
        case errorOccurred(NetworkServiceErrors)
        case alert(PresentationAction<Alert>)
        
        case favoriteButtonTapped
        case favoriteUpdated(Bool)
        
        case navigateToEpisodeDetails(Episode)
        case episodeDetails(PresentationAction<EpisodeDetailsReducer.Action>)
        
        enum Alert {
            case cancelButtonTapped
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .episodeTapped(episode: let episode):
                return .run { send in
                    do {
                        let episode = try await NetworkService.fetchEpisodeDetails(for: episode)
                        await send(.navigateToEpisodeDetails(episode))
                    } catch {
                        if let error = error as? NetworkServiceErrors {
                            await send(.errorOccurred(error))
                        }
                    }
                }
                
            case .navigateToEpisodeDetails(let episode):
                state.episodeDetails = .init(episode: episode)
                return .none
                
            case .episodeDetails:
                return .none
                
            case .favoriteButtonTapped:
                let characterID = state.character.id
                let currentlyFavorite = state.isFavorite

                return .run { send in
                    do {
                        if currentlyFavorite {
                            try await self.favoriteRepository.removeFavorite(characterID)
                        } else {
                            try await self.favoriteRepository.addFavorite(characterID)
                        }
                        //Toggle only after success
                        await send(.favoriteUpdated(!currentlyFavorite))
                    } catch {
                        await send(.errorOccurred(.invalidData))
                    }
                }

            case .favoriteUpdated(let newValue):
                state.isFavorite = newValue
                return .none

            case .errorOccurred(let error):
                state.alert = AlertState {
                    TextState("Error occured!")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState(error.errorDescription ?? "Unknown error")
                }

                return .none
                
            case .alert(.presented(.cancelButtonTapped)):
                state.alert = nil
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$episodeDetails, action: \.episodeDetails) {
            EpisodeDetailsReducer()
        }
    }
}
