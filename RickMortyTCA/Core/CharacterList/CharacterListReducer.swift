//
//  CharacterListReducer.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 03/06/2025.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CharactersListReducer {
    @ObservableState
    struct State: Equatable {
        @Presents var alert: AlertState<Action.Alert>?
        var favoritesID = Set<Int>()
        var characters: IdentifiedArrayOf<Character> = []
        var showCharactersList = false
        var page = 1
        var searchText = ""
        
        var shouldAllowPagination: Bool {
            showCharactersList && !characters.isEmpty
        }
    }

    enum Action: Equatable, BindableAction {
        case alert(PresentationAction<Alert>)
        case showListButtonTapped
        case charactersLoaded([Character])
        case reachedBottomOnList
        case errorOccurred(NetworkServiceErrors)
        case searchTriggered
        case searchCleared
        case binding(BindingAction<State>)

        @CasePathable
        enum Alert: Equatable {
            case dismiss
        }
    }
    
    private enum CancelID: Hashable {
        case fetchCharacters
        case loadMoreCharacters
        case searchCharacters
    }

    var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .showListButtonTapped:
                withAnimation {
                    state.showCharactersList.toggle()
                }
                
                if state.showCharactersList {
                    state.page = 1
                    state.characters.removeAll()  //Clear previous data
                    
                    return .run { send in
                        await send(.charactersLoaded(try await fetchCharacters(page: 1)))
                    } catch: { error, send in
                        await send(.errorOccurred(error as? NetworkServiceErrors ?? .invalidData))
                    }
                    .cancellable(id: CancelID.fetchCharacters)
                } else {
                    state.characters = []
                    //Cancel ALL ongoing requests when hiding list
                    return .merge(
                        .cancel(id: CancelID.fetchCharacters),
                        .cancel(id: CancelID.loadMoreCharacters),
                        .cancel(id: CancelID.searchCharacters)
                    )
                }
                
            case .charactersLoaded(let response):
                response.forEach { state.characters.append($0) }
                return .none

            case .reachedBottomOnList:
                guard state.shouldAllowPagination else { return .none }
                
                let nextPage = state.page + 1
                let searchText = state.searchText
                state.page = nextPage

                return .run { send in
                    let characters = try await fetchCharacters(
                        page: nextPage,
                        filter: searchText.isEmpty ? nil : searchText
                    )
                    await send(.charactersLoaded(characters))
                } catch: { error, send in
                    await send(.errorOccurred(error as? NetworkServiceErrors ?? .invalidData))
                }
                .cancellable(id: CancelID.loadMoreCharacters)

            case .alert(.presented(.dismiss)):
                state.alert = nil
                return .none

            case .alert:
                return .none

            case .errorOccurred(let error):
                state.alert = AlertState {
                    TextState("Error occurred")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("OK")
                    }
                } message: {
                    TextState(error.errorDescription ?? "An unexpected error occurred. Please try again.")  // ✅ IMPROVED: Better error message
                }
                return .none
                
            case .binding:
                return .none
                
            case .searchCleared:
                state.searchText = ""
                return .cancel(id: CancelID.searchCharacters)

            case .searchTriggered:
                let searchText = state.searchText
                
                // Reset strony przy nowym wyszukiwaniu
                state.page = 1
                state.characters.removeAll()
                
                return .merge(
                    .cancel(id: CancelID.loadMoreCharacters),
                    .run { send in
                        let characters = try await fetchCharacters(
                            page: 1,
                            filter: searchText.isEmpty ? nil : searchText
                        )
                        await send(.charactersLoaded(characters))
                    } catch: { error, send in
                        await send(.errorOccurred(error as? NetworkServiceErrors ?? .invalidData))
                    }
                    .cancellable(id: CancelID.searchCharacters)
                )
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Helper functions to eliminate code duplication
private extension CharactersListReducer {
    
    func fetchCharacters(page: Int, filter: String? = nil) async throws -> [Character] {
        return try await NetworkService.fetchCharactersList(for: page, filter: filter)
    }
}
