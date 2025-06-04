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
        var episodeDetails: EpisodeDetailsReducer.State?
        let character: Character
        var episode: Episode?
        var isFavorite: Bool
        var episodeDetailsIsPresented = false
    }
    
    @Dependency(\.coreDataService) var favoriteRepository

    enum Action {
        
        case episodeDetails(EpisodeDetailsReducer.Action)
        case presentEpisodeDetails(isPresented: Bool)
        
        case episodeTapped(episode: String)
        case episodeLoaded(episode: Episode)
        
        case errorOccurred(NetworkServiceErrors)
        case alert(PresentationAction<Alert>)
        
        case favoriteButtonTapped
        case favoriteUpdated(Bool)
        
        enum Alert {
            case cancelButtonTapped
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .episodeDetails(.closeButtonTapped):
                return .run { send in
                    await send(.presentEpisodeDetails(isPresented: false))
                }

            case .presentEpisodeDetails(isPresented: true):
                guard let episode = state.episode else { return .none }
                state.episodeDetails = EpisodeDetailsReducer.State(episode: episode)
                state.episodeDetailsIsPresented = true
                return .none

            case .presentEpisodeDetails(isPresented: false):
                state.episodeDetailsIsPresented = false
                state.episodeDetails = nil
                return .none

            case .episodeTapped(episode: let episode):
                return .run { send in
                    do {
                        let episode = try await NetworkService.fetchEpisodeDetails(for: episode)
                        await send(.episodeLoaded(episode: episode))
                    } catch {
                        if let error = error as? NetworkServiceErrors {
                            await send(.errorOccurred(error))
                        }
                    }
                }

            case .episodeLoaded(episode: let episode):
                state.episode = episode

                return .run { send in
                    await send(.presentEpisodeDetails(isPresented: true))
                }
                
            case .favoriteButtonTapped:
                let characterID = state.character.id
                let currentlyFavorite = state.isFavorite

                return .run { send in
                    do {
                        if currentlyFavorite {
                            try await self.favoriteRepository.removeFavorite(id: characterID)
                        } else {
                            try await self.favoriteRepository.addFavorite(id: characterID)
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
    }
}
