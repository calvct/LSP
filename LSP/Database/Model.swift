//
//  Model.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 17/12/25.
//

import Supabase
import Foundation
import SwiftUI

/// Model anggota perpustakaan yang merepresentasikan entitas pengguna/anggota di backend (Supabase).
/// Menggunakan pemetaan kunci `id_anggota` dari backend ke properti `id`.
struct Anggota: Identifiable, Decodable, Sendable, Encodable {
    /// ID unik anggota (dipetakan dari kolom "id_anggota").
    var id: UUID
    /// Nama lengkap anggota.
    var nama_lengkap: String
    /// Nomor telepon anggota.
    var no_telpon: String
    /// Alamat anggota (opsional).
    var alamat: String?
    /// Tanggal pembuatan record (opsional).
    var created_at: Date?

    /// Pemetaan nama kolom dari backend ke properti lokal.
    enum CodingKeys: String, CodingKey {
        case id = "id_anggota"
        case nama_lengkap
        case no_telpon
        case alamat
        case created_at
    }
}

/// Model buku perpustakaan. Menyimpan informasi identitas buku, metadata, dan relasi kategori.
/// Kolom `id_buku` pada backend dipetakan ke properti `id`.
struct Buku: Identifiable, Decodable, Sendable, Encodable {
    /// ID unik buku (dipetakan dari kolom "id_buku").
    var id: String
    /// Judul buku.
    var judul_buku: String
    /// Jumlah eksemplar buku yang tersedia.
    var jumlah_buku: Int
    /// Nama penulis (opsional).
    var penulis: String?
    /// Nama penerbit (opsional).
    var penerbit: String?
    /// Tahun terbit buku. Gunakan decoder tanggal yang sesuai dengan format backend.
    var tahun_terbit: Date
    /// Tanggal pembuatan record (opsional).
    var created_at: Date?
    /// ID kategori terkait buku.
    var id_kategori: Int
    
    /// Pemetaan nama kolom dari backend ke properti lokal.
    enum CodingKeys: String, CodingKey {
        case id = "id_buku"
        case judul_buku
        case jumlah_buku
        case penulis
        case penerbit
        case tahun_terbit
        case created_at
        case id_kategori
    }
}

/// Model transaksi peminjaman buku. Menyimpan informasi siapa meminjam, buku yang dipinjam, dan tanggal terkait.
/// Kolom `id_peminjaman` pada backend dipetakan ke properti `id` (opsional saat create).
struct Peminjaman: Identifiable, Decodable, Sendable, Encodable {
    /// ID unik peminjaman (dipetakan dari kolom "id_peminjaman"; opsional saat belum tersimpan).
    var id: String?
    /// ID anggota yang meminjam.
    var id_anggota: UUID
    /// ID buku yang dipinjam.
    var id_buku: String
    /// Tanggal mulai peminjaman.
    var tanggal_pinjam: Date
    /// Tanggal jatuh tempo pengembalian.
    var tanggal_pengembalian: Date
    /// Tanggal pengembalian aktual (opsional).
    var tanggal_pengembalian_aktual: Date?
    /// Status peminjaman (mis. aktif, selesai, terlambat).
    var status: String
    /// Tanggal pembuatan record (opsional).
    var created_at: Date?
    
    /// Pemetaan nama kolom dari backend ke properti lokal.
    enum CodingKeys: String, CodingKey {
        case id = "id_peminjaman"
        case id_anggota
        case id_buku
        case tanggal_pinjam
        case tanggal_pengembalian
        case tanggal_pengembalian_aktual
        case status
        case created_at
    }
}

/// Model kategori buku. Menyimpan identitas dan nama kategori.
/// Kolom `id_kategori` pada backend dipetakan ke properti `id`.
struct Kategori: Identifiable, Decodable, Sendable {
    /// ID unik kategori (dipetakan dari kolom "id_kategori").
    var id: Int
    /// Nama kategori.
    var nama_kategori: String
    
    /// Pemetaan nama kolom dari backend ke properti lokal.
    enum CodingKeys: String, CodingKey {
        case id = "id_kategori"
        case nama_kategori
    }
}

/// View model terde-normalisasi untuk menampilkan ringkasan peminjaman.
/// Biasanya berasal dari view atau join di backend yang menyertakan nama peminjam dan info buku.
struct viewPeminjaman: Identifiable, Decodable, Sendable, Encodable {
    /// ID unik peminjaman (dipetakan dari kolom "id_peminjaman").
    var id: String
    /// Tanggal mulai peminjaman.
    var tanggal_pinjam : Date
    /// Tanggal jatuh tempo pengembalian.
    var tanggal_pengembalian: Date
    /// Tanggal pengembalian aktual (opsional).
    var tanggal_pengembalian_aktual: Date?
    /// Status peminjaman.
    var status: String
    /// Nama lengkap peminjam (hasil join dengan anggota).
    var nama_peminjam: String
    /// Judul buku yang dipinjam.
    var judul_buku: String
    /// Nama penulis buku.
    var penulis: String
    
    /// Pemetaan nama kolom dari backend ke properti lokal.
    enum CodingKeys: String, CodingKey{
        case id = "id_peminjaman"
        case tanggal_pinjam
        case tanggal_pengembalian
        case tanggal_pengembalian_aktual
        case status
        case nama_peminjam
        case judul_buku
        case penulis
    }
    
    /// Menghitung sisa hari antara tanggal pinjam dan tanggal jatuh tempo.
    /// Nilai positif berarti masih ada sisa hari; nilai 0 atau negatif menandakan jatuh tempo/hari ini atau terlambat.
    var hitungSisaHari: Int {
        let startOfDay = Calendar.current.startOfDay(for: tanggal_pinjam)
        let endOfDay = Calendar.current.startOfDay(for: tanggal_pengembalian)
        let components = Calendar.current.dateComponents([.day], from: startOfDay, to: endOfDay)
        return components.day ?? 0
    }
    
    /// Deskripsi status peminjaman berbasis sisa hari.
    /// Contoh: "Jatuh tempo: 3 hari lagi" atau "Terlambat".
    var statusPeminjaman: String {
        let sisaHari = hitungSisaHari
        if sisaHari > 0 {
            return "Jatuh tempo: \(sisaHari) hari lagi"
        } else {
            return "Terlambat"
        }
    }
    /// Warna indikator status peminjaman.
    /// Hijau: > 3 hari; Oranye: 1–3 hari; Merah: hari ini atau terlambat.
    var warnaStatus: Color {
            let sisa = hitungSisaHari
            
            if sisa > 3 {
                return .green // Masih lama (Aman)
            } else if sisa > 0 {
                return .orange // Mendekati deadline (Hati-hati)
            } else {
                return .red // Hari ini atau Terlambat (Bahaya)
            }
        }
}

