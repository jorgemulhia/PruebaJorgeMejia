//
//  MainView.swift
//  PruebaJorgeMejia
//
//  Created by Jorge Mulhia on 6/5/25.
//

import Foundation
import SwiftUI

struct MainView: View {
    
    // MARK: - View
    
    var body: some View {
        TabView {
            VideoRecorderView()
                .tabItem {
                    Label("Grabar video", systemImage: "video")
                }
            
            CountryListView()
                .tabItem {
                    Label("Mapa", systemImage: "mappin.and.ellipse")
                }
        }
        .accentColor(.primary)
    }
}

// MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
