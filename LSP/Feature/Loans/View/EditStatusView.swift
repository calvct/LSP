//
//  EditStatusView.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 10/01/26.
//

import SwiftUI

/// Tampilan untuk mengubah status peminjaman buku (mis. menandai sebagai dikembalikan).
/// Menampilkan detail ringkas buku dan peminjam, serta menyediakan aksi pembaruan status.
struct EditStatusView: View {
    /// Item peminjaman yang sedang diedit (hasil dari view/join backend).
    let loanItem: viewPeminjaman // Sesuaikan nama struct model Anda
    
    /// View model peminjaman untuk mengeksekusi pembaruan status dan pembaruan stok.
    @EnvironmentObject var vm: LoanViewModel
    
    /// Aksi untuk menutup tampilan setelah operasi selesai.
    @Environment(\.dismiss) var dismiss
    
    /// Menandai status pemrosesan saat aksi pembaruan status sedang berlangsung.
    @State private var isLoading = false
    
    /// Hierarki tampilan yang menampilkan informasi buku, status saat ini, dan tombol aksi untuk memperbarui status.
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Informasi ringkas buku dan peminjam.
                VStack(spacing: 8) {
                    Image(systemName: "book.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text(loanItem.judul_buku) // Sesuaikan nama property
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("Peminjam: \(loanItem.nama_peminjam)")
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                Divider()
                
                // Status peminjaman saat ini.
                HStack {
                    Text("Status Saat Ini:")
                    Spacer()
                    Text(loanItem.status)
                        .bold()
                        .foregroundColor(loanItem.status == "Dikembalikan" ? .green : .orange)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                Spacer()
                
                // Aksi untuk menandai peminjaman sebagai dikembalikan (meningkatkan stok dan memperbarui status).
                if loanItem.status != "Dikembalikan" {
                    Button(action: {
                        Task {
                            isLoading = true
                            // 1) Perbarui status peminjaman menjadi "Dikembalikan".
                            await vm.updateStatusLoans(idPeminjaman: loanItem.id)
                            // 2) Tambahkan kembali stok buku sebanyak 1.
                            await vm.addJumlahBuku(judulBuku: loanItem.judul_buku, penulis: loanItem.penulis, jumlahBuku: 1)
                            // 3) Tutup tampilan setelah selesai.
                            isLoading = false
                            dismiss()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Tandai Sudah Dikembalikan")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                } else {
                    Text("Buku ini sudah dikembalikan.")
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .padding()
            .navigationTitle("Edit Status")
            .navigationBarTitleDisplayMode(.inline)
            // Tombol untuk menutup tampilan tanpa mengubah status.
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { dismiss() }
                }
            }
        }
        // Menampilkan modal setengah layar (medium detent).
        .presentationDetents([.medium])
    }
}

