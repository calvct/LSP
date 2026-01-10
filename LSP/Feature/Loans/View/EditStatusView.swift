//
//  EditStatusView.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 10/01/26.
//

import SwiftUI

struct EditStatusView: View {
    // 1. Terima data item yang sedang diedit
    let loanItem: viewPeminjaman // Sesuaikan nama struct model Anda
    
    // 2. Terima VM untuk eksekusi fungsi
    @ObservedObject var vm: CatalogViewModel
    
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Info Buku
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
                
                // Status Saat Ini
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
                
                // Tombol Aksi
                if loanItem.status != "Dikembalikan" {
                    Button(action: {
                        Task {
                            isLoading = true
                            await vm.updateStatusLoans(idPeminjaman: loanItem.id)
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { dismiss() }
                }
            }
        }
        // Supaya modalnya tidak full screen (setengah layar)
        .presentationDetents([.medium])
    }
}
