//
//  CatalogView.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 09/01/26.
//

import SwiftUI

/// Tampilan katalog buku. Menampilkan daftar buku yang dapat difilter berdasarkan kategori dan kata kunci pencarian.
struct CatalogView: View {
    /// View model katalog yang menyediakan data buku dan kategori.
    @EnvironmentObject var vm: CatalogViewModel
    /// Teks pencarian untuk memfilter judul buku.
    @State private var searchText: String = ""
    /// Status presentasi modal untuk menambahkan buku baru.
    @State private var isBookModalPresented: Bool = false
    /// Daftar buku yang sudah difilter berdasarkan kategori terpilih dan kata kunci `searchText`.
    /// Hasil akhir diurutkan berdasarkan `judul_buku` secara ascending.
    var filteredItem : [Buku]{
        let hasilFilter: [Buku]
        if searchText.isEmpty{
            hasilFilter =  vm.filteredBooks
        }
        else{
            hasilFilter = vm.filteredBooks.filter{
                book in
                book.judul_buku.localizedCaseInsensitiveContains(searchText)
            }
        }
        return hasilFilter.sorted { $0.judul_buku < $1.judul_buku }
    }
    
    /// Hierarki tampilan utama katalog, termasuk filter kategori, daftar buku, pencarian, refresh, dan tombol tambah buku.
    var body: some View {
        NavigationStack {
            ScrollView{
                // Deretan tombol kategori (chips) untuk memilih filter kategori.
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
                
                // Daftar buku hasil filter.
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
                                    .padding(4)
                                    .foregroundColor(.white)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.red)
                                    )
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
            // Pencarian berdasarkan judul buku.
            .searchable(text: $searchText, prompt: "Cari judul buku...")
            .navigationBarTitle("Katalog")
            // Memuat data buku saat tampilan muncul.
            .task {
                try? await vm.fetchBooks()
            }
            // Tarik untuk menyegarkan daftar buku.
            .refreshable {
                do{
                    try await vm.fetchBooks()
                }catch{
                    debugPrint(error)
                }
            }
            // Tombol untuk membuka modal tambah buku.
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action:{
                        isBookModalPresented = true
                    }){
                        Image(systemName: "plus")
                    }
                }
            }
            // Modal untuk menambahkan buku baru.
            .sheet(isPresented: $isBookModalPresented, content: {
                AddBookView()
                    .environmentObject(vm)
            }
            )
        }
    }
}

