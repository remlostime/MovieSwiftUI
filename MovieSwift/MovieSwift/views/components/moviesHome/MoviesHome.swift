//
//  MoviesHome.swift
//  MovieSwift
//
//  Created by Thomas Ricouard on 22/06/2019.
//  Copyright © 2019 Thomas Ricouard. All rights reserved.
//

import SwiftUI
import Combine
import SwiftUIFlux

enum SortMode: String, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case `default`
    case time
    case name
}

struct MoviesHome : View {
    private enum HomeMode {
        case list, grid
        
        func icon() -> String {
            switch self {
            case .list: return "rectangle.3.offgrid.fill"
            case .grid: return "rectangle.grid.1x2"
            }
        }
    }

    @StateObject private var selectedMenu = MoviesSelectedMenuStore(selectedMenu: MoviesMenu.allCases.first!)
    @State private var isSettingPresented = false
    @State private var homeMode = HomeMode.list
    @State private var sortMode: SortMode = .default
        
    private var settingButton: some View {
        Button(action: {
            self.isSettingPresented = true
        }) {
            HStack {
                Image(systemName: "wrench").imageScale(.medium)
            }.frame(width: 30, height: 30)
        }
    }
    
    private var swapHomeButton: some View {
        Button(action: {
            self.homeMode = self.homeMode == .grid ? .list : .grid
        }) {
            HStack {
                Image(systemName: self.homeMode.icon()).imageScale(.medium)
            }.frame(width: 30, height: 30)
        }
    }
    
    private var sortButton: some View {
        Picker.init("Sort", selection: $sortMode) {
            ForEach.init(SortMode.allCases) { sortMode in
                Text.init(sortMode.rawValue)
                    .tag(sortMode)
            }
        }
    }
    
    @ViewBuilder
    private var homeAsList: some View {
        TabView(selection: $selectedMenu.menu) {
            ForEach(MoviesMenu.allCases, id: \.self) { menu in
                if menu == .genres {
                    GenresList()
                        .tag(menu)
                } else {
                    MoviesHomeList(menu: .constant(menu),
                                   sortMode: .constant(sortMode),
                                   pageListener: selectedMenu.pageListener)
                        .tag(menu)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
    
    private var homeAsGrid: some View {
        MoviesHomeGrid()
    }
        
    var body: some View {
        NavigationView {
            Group {
                switch homeMode {
                case .list:
                    homeAsList
                case .grid:
                    homeAsGrid
                }
            }
            .navigationBarTitle(selectedMenu.menu.title())
            .navigationBarTitleDisplayMode(homeMode == .list ? .inline : .automatic)
            .navigationBarItems(trailing:
                                    HStack {
                                        sortButton
                                        swapHomeButton
                                        settingButton
                                    }
            ).sheet(isPresented: $isSettingPresented,
                    content: { SettingsForm() })
        }
    }
}

#if DEBUG
struct MoviesHome_Previews : PreviewProvider {
    static var previews: some View {
        MoviesHome().environmentObject(sampleStore)
    }
}
#endif
