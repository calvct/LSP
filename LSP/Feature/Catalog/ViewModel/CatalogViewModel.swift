//
//  CatalogViewModel.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 09/01/26.
//

import SwiftUI
import Supabase
import Foundation
import Combine

@MainActor
class CatalogViewModel: ObservableObject {
    @Published var books: [Buku] = []
    @Published var kategori: [Kategori] = []
    @Published var anggota: [Anggota] = []
    @Published var peminjaman: [Peminjaman] = []
    @Published var viewPeminjaman: [viewPeminjaman] = []
    @Published var selectedKategoriId : Int = 0
    
    func fetchAnggota() async throws {
        do {
            let anggotaData: [Anggota] = try await supabase
                .from("anggota")
                .select()
                .execute()
                .value
            self.anggota = anggotaData
        }
        catch{
            debugPrint(error)
        }
    }
    
    func fetchBooks() async throws {
        do {
            let bookData: [Buku] = try await supabase
                .from("buku")
                .select("id_buku, judul_buku, jumlah_buku, penulis, tahun_terbit, id_kategori")
                .execute()
                .value
            self.books = bookData
        }
        catch{
            debugPrint(error)
        }
    }
    func fetchKategori() async throws {
        do {
            let kategoriData: [Kategori] = try await supabase
                .from("kategori")
                .select("id_kategori, nama_kategori")
                .execute()
                .value
            let kategoriSemua = Kategori(id: 0, nama_kategori: "Semua")
            self.kategori = [kategoriSemua] + kategoriData
        }
        catch{
            debugPrint(error)
        }
    }
    
    func fetchLoans() async throws {
        do {
            let peminjamanData: [Peminjaman] = try await supabase
                .from("peminjaman")
                .select()
                .execute()
                .value
            self.peminjaman = peminjamanData
        }
        catch{
            debugPrint(error)
        }
    }
    
    func fetchViewPeminjaman() async throws{
        do{
            let peminjamanData: [viewPeminjaman] = try await supabase
                .from("view_detail_peminjaman")
                .select()
                .execute()
                .value
            self.viewPeminjaman = peminjamanData
        }
        catch{
            debugPrint(error)
        }
    }
    
    var filteredBooks: [Buku] {
        if selectedKategoriId == 0 {
            return books
        }
        else{
            return books.filter{$0.id_kategori == selectedKategoriId}
        }
    }
    
}
