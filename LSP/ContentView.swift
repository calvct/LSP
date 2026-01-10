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
    @State private var searchText: String = ""
    
    
    var body: some View {
        TabView{
            Tab("Catalog", systemImage: "books.vertical"){
                CatalogView()
                    .environmentObject(catalogVM)
                    
            }
            Tab("Loans", systemImage: "book.badge.plus"){
                LoansView(vm: catalogVM)
            }
//            Tab(role: .search){
//                CatalogView()
//                    .searchable(
//                    text: $searchText,
//                    placement: .navigationBarDrawer(displayMode: .always),
//                    prompt: "Cari Buku"
//                    )
//            }
        }
        .environmentObject(catalogVM)
        .task {
            do{
                try await catalogVM.fetchBooks()
                try await catalogVM.fetchKategori()
                try await catalogVM.fetchViewPeminjaman()
                try await catalogVM.fetchAnggota()
            }catch{
                print(error)
            }
        }
    }
}
