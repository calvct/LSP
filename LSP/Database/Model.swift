//
//  Model.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 17/12/25.
//

import Supabase
import Foundation
import SwiftUI

struct Anggota: Identifiable, Decodable, Sendable, Encodable {
    var id: UUID
    var nama_lengkap: String
    var no_telpon: String
    var alamat: String?
    var created_at: Date?

    enum CodingKeys: String, CodingKey {
        case id = "id_anggota"
        case nama_lengkap
        case no_telpon
        case alamat
        case created_at
    }
}

struct Buku: Identifiable, Decodable, Sendable, Encodable {
    var id: String
    var judul_buku: String
    var jumlah_buku: Int
    var penulis: String?
    var penerbit: String?
    var tahun_terbit: Date
    var created_at: Date?
    var id_kategori: Int
    
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
struct Peminjaman: Identifiable, Decodable, Sendable, Encodable {
    var id: String?
    var id_anggota: UUID
    var id_buku: String
    var tanggal_pinjam: Date
    var tanggal_pengembalian: Date
    var tanggal_pengembalian_aktual: Date?
    var status: String
    var created_at: Date?
    
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

struct Kategori: Identifiable, Decodable, Sendable {
    var id: Int
    var nama_kategori: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id_kategori"
        case nama_kategori
    }
}

struct viewPeminjaman: Identifiable, Decodable, Sendable, Encodable {
    var id: String
    var tanggal_pinjam : Date
    var tanggal_pengembalian: Date
    var tanggal_pengembalian_aktual: Date?
    var status: String
    var nama_peminjam: String
    var judul_buku: String
    var penulis: String
    
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
    
    var hitungSisaHari: Int {
        let startOfDay = Calendar.current.startOfDay(for: tanggal_pinjam)
        let endOfDay = Calendar.current.startOfDay(for: tanggal_pengembalian)
        let components = Calendar.current.dateComponents([.day], from: startOfDay, to: endOfDay)
        return components.day ?? 0
    }
    
    var statusPeminjaman: String {
        let sisaHari = hitungSisaHari
        if sisaHari > 0 {
            return "Jatuh tempo: \(sisaHari) hari lagi"
        } else {
            return "Terlambat"
        }
    }
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

