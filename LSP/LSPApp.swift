//
//  LSPApp.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 17/12/25.
//

import SwiftUI

@main
struct LSPApp: App {
    @StateObject private var catalogVM = CatalogViewModel()
    @StateObject private var loanVM = LoanViewModel()
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .environmentObject(catalogVM)
                .environmentObject(loanVM)
                .preferredColorScheme(.light)
        }
    }
}
