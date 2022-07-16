//
//  MoviesHomeList.swift
//  MovieSwift
//
//  Created by Thomas Ricouard on 07/06/2019.
//  Copyright © 2019 Thomas Ricouard. All rights reserved.
//

import SwiftUI
import Combine
import SwiftUIFlux

struct MoviesHomeList: ConnectedView {
    struct Props {
        let movies: [Int]
    }
    
    @Binding var menu: MoviesMenu
    @Binding var sortMode: SortMode
    
    
    let pageListener: MoviesMenuListPageListener

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        let movies: [Int]
        
        if let _movies = state.moviesState.moviesList[menu] {
            movies = sortedMovies(for: _movies, moviesState: state.moviesState)
        } else {
            movies = [0, 0, 0, 0]
        }
        
        return Props(movies: movies)
    }
    
    func body(props: Props) -> some View {
        MoviesList(movies: props.movies,
                   displaySearch: true,
                   pageListener: pageListener)
    }
    
    private func sortedMovies(for movies: [Int], moviesState: MoviesState) -> [Int] {
        let sortedFunc: (Int, Int) -> Bool
        switch sortMode {
            case .default:
                return movies
            case .time:
                sortedFunc = { id1, id2 in
                    guard let movie1 = moviesState.movies[id1],
                          let movie2 = moviesState.movies[id2] else
                    {
                        return false
                    }
                    
                    return movie1.releaseDate! > movie2.releaseDate!
                }
            case .name:
                sortedFunc = { id1, id2 in
                    guard let movie1 = moviesState.movies[id1],
                          let movie2 = moviesState.movies[id2] else
                    {
                        return false
                    }
                    
                    return movie1.title < movie2.title
                }
        }
        
        return movies.sorted {
            sortedFunc($0, $1)
        }
    }
}

#if DEBUG
struct MoviesHomeList_Previews : PreviewProvider {
    static var previews: some View {
        NavigationView {
            MoviesHomeList(menu: .constant(.popular),
                           sortMode: .constant(.default),
                           pageListener: MoviesMenuListPageListener(menu: .popular))
                .environmentObject(sampleStore)
        }
    }
}
#endif
