//
//  UberSwiftUITutorialApp.swift
//  UberSwiftUITutorial
//
//  Created by Tiziano Cialfi on 09/06/23.
//

import SwiftUI

@main
struct UberSwiftUITutorialApp: App {
    @StateObject var locationSearchViewViewModel = LocationSearchViewViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(locationSearchViewViewModel)
        }
    }
}
