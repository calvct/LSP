//
//  ContentView.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 17/12/25.
//

import SwiftUI
import Supabase

struct ContentView: View {
    @StateObject private var catalogVM = CatalogViewModel()
    @StateObject private var loanVM = LoanViewModel()
    @State private var searchText: String = ""
    
    
    var body: some View {
        TabView{
            Tab("Catalog", systemImage: "books.vertical"){
                CatalogView()
                    .environmentObject(catalogVM)
                    
            }
            Tab("Loans", systemImage: "book.badge.plus"){
                LoansView()
                    .environmentObject(loanVM)
            }
        }
        .task {
            await catalogVM.loadData()
            await loanVM.loadData()
        }
    }
}
