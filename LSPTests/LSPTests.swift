//
//  LSPTests.swift
//  LSPTests
//
//  Created by Calvin Christian Tjong on 10/01/26.
//

import Testing
import Foundation
@testable import LSP

/// Kumpulan pengujian untuk logika katalog dan pencarian pada aplikasi LSP.
@MainActor
struct LSPTests {
    /// Helper untuk membuat `Date` dari string ISO8601 (format tanggal saja). Mengembalikan epoch jika parsing gagal.
    private func isoDate(_ string: String) -> Date {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f.date(from: string) ?? Date(timeIntervalSince1970: 0)
    }
    
    /// Membuat instance `CatalogViewModel` dengan data buku contoh untuk kebutuhan pengujian.
    func makeData() -> CatalogViewModel {
        let vm = CatalogViewModel()
        // Data dummy tiga buku dengan variasi kategori dan tahun terbit.
        vm.books = [
            Buku(id: "A1", judul_buku: "Hello", jumlah_buku: 5, penulis: "Allen", penerbit: "Allen", tahun_terbit: isoDate("2004-08-01"), created_at: isoDate("2026-01-10"), id_kategori: 2),
            Buku(id: "A2", judul_buku: "World", jumlah_buku: 3, penulis: "Berta", penerbit: "Beta", tahun_terbit: isoDate("2010-05-12"), created_at: isoDate("2025-12-31"), id_kategori: 4),
            Buku(id: "A3", judul_buku: "Swift", jumlah_buku: 7, penulis: "Chris", penerbit: "Gamma", tahun_terbit: isoDate("2019-09-20"), created_at: isoDate("2026-01-10"), id_kategori: 2)
        ]
        
        return vm
    }
    /// Memastikan filter kategori menampilkan hanya buku dengan kategori yang dipilih (ID 2).
    @Test("Kategori: Jika ID dipilih, hanya tampilkan buku ID tersebut")
        func testCategoryLogic() {
            let vm = makeData()
            
            // SKENARIO 1: Pilih Kategori ID 2
            vm.selectedKategoriId = 2
            
            // Kita panggil filteredBooks (asumsi logic ini ada di VM kamu)
            let hasil = vm.filteredBooks
            
            // Ekspektasi: ada 2 buku pada kategori 2.
            #expect(hasil.count == 2, "Harusnya ada 2 buku di kategori 2")
            #expect(hasil.first?.id_kategori == 2)
        }
    /// Memastikan ketika kategori 0 (Semua) dipilih, semua buku ditampilkan.
    @Test("Kategori: Jika ID 0, tampilkan semua buku")
        func testCategoryAll() {
            let vm = makeData()
            
            // SKENARIO 2: Pilih Kategori 0 (Semua)
            vm.selectedKategoriId = 0
            
            let hasil = vm.filteredBooks
            
            // Ekspektasi: seluruh buku (3 item) ditampilkan.
            #expect(hasil.count == 3)
        }
    /// Memastikan pencarian case-insensitive terhadap judul buku mengembalikan hasil yang sesuai.
    @Test("Search: Mencari buku berdasarkan teks (Case Insensitive)")
        func testSearchLogic() {
            let vm = makeData()
            
            // SKENARIO 1: User mengetik "swift" (huruf kecil)
            let searchText = "swift"
            
            // Kita simulasikan logic View kamu di sini
            let hasil: [Buku]
            if searchText.isEmpty {
                hasil = vm.books
            } else {
                hasil = vm.books.filter { $0.judul_buku.localizedCaseInsensitiveContains(searchText) }
            }
            
            // Ekspektasi: hanya 1 buku dengan judul yang mengandung "swift".
            #expect(hasil.count == 1)
            #expect(hasil.first?.judul_buku == "Belajar Swift")
        }
    /// Memastikan ketika teks pencarian kosong, semua buku ditampilkan.
    @Test("Search: Jika search kosong, tampilkan semua")
        func testSearchEmpty() {
            let vm = makeData()
            
            // SKENARIO 2: Search kosong
            let searchText = ""
            
            let hasil: [Buku]
            if searchText.isEmpty {
                hasil = vm.books
            } else {
                hasil = vm.books.filter { $0.judul_buku.localizedCaseInsensitiveContains(searchText) }
            }
            
            // Ekspektasi: kembali ke jumlah awal (3 buku).
            #expect(hasil.count == 3)
        }
        
        /// Memastikan ketika kata kunci tidak ditemukan, hasil pencarian kosong.
        @Test("Search: Jika tidak ketemu, hasil kosong")
        func testSearchNotFound() {
            let vm = makeData()
            let searchText = "Zebra" // Buku tidak ada
            
            let hasil = vm.books.filter { $0.judul_buku.localizedCaseInsensitiveContains(searchText) }
            
            // Ekspektasi: tidak ada hasil yang cocok.
            #expect(hasil.isEmpty)
        }
}

