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

/// View model untuk katalog buku. Mengelola pemuatan data buku dan kategori dari Supabase,
/// serta menyediakan filter berdasarkan kategori yang dipilih.
@MainActor
class CatalogViewModel: ObservableObject {
    /// Daftar buku yang ditampilkan pada katalog.
    @Published var books: [Buku] = []
    /// Daftar kategori buku yang tersedia. Elemen pertama berisi kategori khusus "Semua" dengan id 0.
    @Published var kategori: [Kategori] = []
    /// ID kategori yang sedang dipilih untuk filter. Nilai 0 berarti semua kategori.
    @Published var selectedKategoriId : Int = 0
    
    /// Memuat data buku dan kategori secara asinkron. Kesalahan pemuatan diabaikan (menggunakan try?).
    func loadData() async  {
        try? await fetchBooks()
        try? await fetchKategori()
    }
    /// Mengambil data buku dari tabel `buku` di Supabase dan memperbarui `books`.
    /// - Throws: Meneruskan kesalahan jaringan/decoding jika terjadi.
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
    /// Mengambil data kategori dari tabel `kategori` di Supabase dan menambahkan entri "Semua" di awal.
    /// - Throws: Meneruskan kesalahan jaringan/decoding jika terjadi.
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
    /// Menambahkan buku baru jika belum ada; jika sudah ada (judul & penulis sama), hanya menambah jumlah eksemplar.
    /// Setelah operasi berhasil, data buku akan dimuat ulang.
    /// - Parameters:
    ///   - namaBuku: Judul buku baru.
    ///   - penulis: Nama penulis.
    ///   - tahunTerbit: Tanggal/tahun terbit (akan diformat `yyyy-MM-dd` saat dikirim).
    ///   - jumlahBuku: Jumlah eksemplar yang akan ditambahkan.
    ///   - idKategori: ID kategori buku.
    func addBook(namaBuku: String, penulis: String, tahunTerbit: Date, jumlahBuku: Int, idKategori: Int) async {
        let sudahAda = await addJumlahBuku(judulBuku: namaBuku, penulis: penulis, jumlahBuku: jumlahBuku)
        if sudahAda{
            try? await fetchBooks()
            return
        }
        do{
            /// Payload untuk operasi insert buku ke Supabase.
            struct newBukuLoad: Encodable{
                let judul_buku: String
                let penulis: String
                let tahun_terbit: String
                let jumlah_buku: Int
                let id_kategori: Int
            }
            /// Formatter tanggal untuk mengubah `tahunTerbit` menjadi string `yyyy-MM-dd`.
            let formartter = DateFormatter()
            formartter.dateFormat = "yyyy-MM-dd"
            let newBuku = newBukuLoad(
                judul_buku: namaBuku,
                penulis: penulis,
                tahun_terbit: formartter.string(from: tahunTerbit),
                jumlah_buku: jumlahBuku,
                id_kategori: idKategori)
            do {
                try await supabase
                    .from("buku")
                    .insert(newBuku)
                    .execute()
                
                try await fetchBooks()
            }
        }
        catch{
            debugPrint(error)
        }
    }
    
    /// Menambah jumlah buku jika entri dengan judul dan penulis yang sama sudah ada.
    /// - Parameters:
    ///   - judulBuku: Judul buku yang dicek.
    ///   - penulis: Penulis buku yang dicek.
    ///   - jumlahBuku: Jumlah yang akan ditambahkan ke stok.
    /// - Returns: `true` jika buku sudah ada dan stok ditambah; `false` jika buku belum ada.
    func addJumlahBuku(judulBuku: String, penulis: String, jumlahBuku: Int) async -> Bool {
        let judul_lowered = judulBuku.lowercased()
        let penulis_lowered = penulis.lowercased()
        do{
            let cekBuku: [Buku] = try await supabase
                .from("buku")
                .select()
                .ilike("judul_buku", pattern: judul_lowered)
                .ilike("penulis", pattern: penulis_lowered)
                .execute()
                .value
            if let bukuAda = cekBuku.first{
                let idBuku = bukuAda.id
                do{
                    try await supabase
                        .from("buku")
                        .update(
                            ["jumlah_buku": bukuAda.jumlah_buku + jumlahBuku]
                        )
                        .eq("id_buku", value: idBuku)
                        .execute()
                    try await fetchBooks()
                    
                }
                return true
            }
            else{
                return false
            }
        }
        catch{
            debugPrint(error)
            return false
        }
    }
    /// Daftar buku yang telah difilter berdasarkan `selectedKategoriId`.
    /// Jika `selectedKategoriId` bernilai 0, semua buku akan ditampilkan.
    var filteredBooks: [Buku] {
        if selectedKategoriId == 0 {
            return books
        }
        else{
            return books.filter{$0.id_kategori == selectedKategoriId}
        }
    }
}

