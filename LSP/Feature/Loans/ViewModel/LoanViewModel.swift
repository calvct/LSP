//
//  LoanViewModel.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 10/01/26.
//

import SwiftUI
import Supabase
import Foundation
import Combine

/// View model peminjaman yang memperluas CatalogViewModel.
/// Mengelola data anggota, transaksi peminjaman, dan view ringkasan peminjaman dari Supabase.
@MainActor
class LoanViewModel: CatalogViewModel {
    /// Daftar anggota yang terdaftar di sistem.
    @Published var anggota: [Anggota] = []
    /// Daftar transaksi peminjaman (raw) dari tabel `peminjaman`.
    @Published var peminjaman: [Peminjaman] = []
    /// Daftar ringkasan peminjaman hasil join/view `view_detail_peminjaman`.
    @Published var viewPeminjaman: [viewPeminjaman] = []
    
    /// Memuat data awal untuk layar peminjaman: buku/kategori (dari super) lalu anggota dan view peminjaman.
    /// Kesalahan pemuatan diabaikan (menggunakan try?).
    override func loadData() async{
        await super.loadData()
        try? await fetchAnggota()
        try? await fetchViewPeminjaman()
    }
    /// Mengambil data anggota dari tabel `anggota` di Supabase dan memperbarui `anggota`.
    /// - Throws: Meneruskan kesalahan jaringan/decoding jika terjadi.
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
    /// Mengambil data ringkasan peminjaman dari view `view_detail_peminjaman` di Supabase dan memperbarui `viewPeminjaman`.
    /// - Throws: Meneruskan kesalahan jaringan/decoding jika terjadi.
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
    /// Membuat transaksi peminjaman baru untuk sebuah buku oleh seorang anggota dengan jatuh tempo 7 hari.
    /// Setelah insert berhasil, data ringkasan peminjaman dimuat ulang.
    /// - Parameters:
    ///   - bukuId: ID buku yang dipinjam.
    ///   - anggotaId: ID anggota peminjam.
    func addLoans(bukuId: String, anggotaId: UUID) async  {
        /// Menghitung tanggal pengembalian (jatuh tempo) 7 hari dari tanggal hari ini.
        guard let tanggalKembali = Calendar.current.date(byAdding: .day, value: 7, to: Date()) else { return }

        let peminjaman = Peminjaman(
            id_anggota: anggotaId,
            id_buku: bukuId,
            tanggal_pinjam: Date(),
            tanggal_pengembalian: tanggalKembali,
            status: "Dipinjam"
        )

        do{
            try await supabase
                .from("peminjaman")
                .insert(peminjaman)
                .execute()

            try await fetchViewPeminjaman()
            print("Berhasil pinjam")
        }
        catch{
            print("Gagal pinjam: \(error)")
        }
    }
    /// Mengurangi stok buku sebanyak 1 untuk buku dengan ID tertentu, tanpa membiarkan nilai negatif.
    /// - Parameter bukuId: ID buku yang stoknya akan dikurangi.
    func updateStock(bukuId: String) async{
        if let current = books.first(where: { $0.id == bukuId }) {
            let newJumlah = max(0, (current.jumlah_buku) - 1)

            do{
                try await supabase
                    .from("buku")
                    .update(
                        ["jumlah_buku": newJumlah]
                    )
                    .eq("id_buku", value: bukuId)
                    .execute()
            }
            catch{
                debugPrint(error)
            }
        }
    }
    /// Memperbarui status peminjaman menjadi "Dikembalikan" untuk ID peminjaman tertentu dan memuat ulang view peminjaman.
    /// - Parameter idPeminjaman: ID peminjaman yang akan diperbarui statusnya.
    func updateStatusLoans(idPeminjaman: String) async {
        let newStatus = "Dikembalikan"
        do{
            try await supabase
                .from("peminjaman")
                .update(["status": newStatus])
                .eq("id_peminjaman", value: idPeminjaman)
                .execute()
            try await fetchViewPeminjaman()
        }
        catch{
            debugPrint(error)
        }
    }

}

