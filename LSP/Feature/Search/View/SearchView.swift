//
//  SearchView.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 10/01/26.
//
//
import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @StateObject private var vm = CatalogViewModel()
    let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
    var body: some View {
        NavigationStack{
            LazyVGrid(columns: columns) {
                ForEach(vm.kategori.dropFirst()) { index in
                    VStack(alignment: .center){
                        Text("📚")
                            .font(.system(size: 50))
                        Text(index.nama_kategori)
                            .font(Font.headline)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 180, height: 150)
//                    .padding()
                    
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.gray.opacity(0.1))
                    )
                    
                   
                }
               
            }
            .padding(.horizontal)
        }
        .searchable(text: $searchText, prompt: "Cari Buku")
        .navigationBarTitle("Search")
    }
}
#Preview {
    SearchView()
}
