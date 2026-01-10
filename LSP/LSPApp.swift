//
//  LSPApp.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 17/12/25.
//

import SwiftUI

@main
struct LSPApp: App {
    @StateObject private var vm = CatalogViewModel()
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .environmentObject(vm)
        }
    }
}
