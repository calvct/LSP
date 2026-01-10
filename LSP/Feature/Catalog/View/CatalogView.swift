//
//  CatalogView.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 09/01/26.
//

import SwiftUI
struct CatalogView: View {
    @EnvironmentObject var vm: CatalogViewModel
    @State private var searchText: String = ""
    
    var filteredItem : [Buku]{
        if searchText.isEmpty{
            return vm.filteredBooks
        }
        else{
            return vm.books.filter{
                book in
                book.judul_buku.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.horizontal, showsIndicators: false){
            HStack{
                ForEach(vm.kategori){ category in
                    Button(action:{
                        withAnimation {
                            vm.selectedKategoriId = category.id
                        }
                       
                        
                    }){
                        Text(category.nama_kategori)
                            .font(.headline)
                            .foregroundStyle(vm.selectedKategoriId == category.id ? .white : .primary)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(vm.selectedKategoriId == category.id ? Color.blue : Color.black.opacity(0.05))
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
            ScrollView{
                
                ForEach(filteredItem) { book in
                    HStack (spacing: 24){
                        Text("📕")
                            .font(.system(size: 64))
                        VStack(alignment: .leading) {
                            Text(book.judul_buku)
                                .font(.subheadline.bold())
                            Text(book.penulis ?? "")
                                .font(.footnote)
                            Text(book.tahun_terbit, format: .dateTime.year())
                                .font(.footnote)
                            if(book.jumlah_buku != 0){
                                Text("Tersedia: \(book.jumlah_buku)")
                                    .foregroundStyle(Color.white)
                                    .font(Font.footnote.bold())
                                    .padding(4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.green)
                                    )
                            }
                            else{
                                Text("Habis")
                                    .font(Font.footnote.bold())
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(.gray.opacity(0.1))
                    )
                    .padding(.vertical,4)
                    .padding(.horizontal)
                }
            }
            .navigationBarTitle("Katalog")
            
        }
    }
}
#Preview {
    @EnvironmentObject var vm: CatalogViewModel
    CatalogView()
        .environmentObject(vm)
}
