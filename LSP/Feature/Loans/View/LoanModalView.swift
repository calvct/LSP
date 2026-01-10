/// Tampilan modal untuk membuat peminjaman buku.
///
/// Pengguna memilih anggota dan buku, lalu menekan tombol ceklis untuk
/// menyimpan peminjaman dan mengurangi stok buku.
//

//  LoanModalView.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 10/01/26.
//

import SwiftUI

/// Form peminjaman: pilih anggota dan buku, lalu simpan peminjaman.
struct LoanModalView: View {
    /// ViewModel yang menyediakan data anggota & buku serta aksi peminjaman.
    @EnvironmentObject var vm: LoanViewModel
    /// Untuk menutup modal setelah peminjaman berhasil.
    @Environment(\.dismiss) var dismiss
    /// ID buku yang dipilih.
    @State private var selectedBookID: String = ""
    /// ID anggota yang dipilih.
    @State private var selectedMemberID: UUID? = nil
    /// Menentukan apakah sheet pencarian buku sedang tampil.
    @State private var isShowingBookSearch = false
    /// Teks pencarian judul buku pada sheet.
    @State private var searchText = ""
    
    /// Daftar buku yang difilter berdasarkan `searchText`.
    /// Jika kosong, menampilkan semua buku dari ViewModel.
    var filteredBooks: [Buku] {
        if searchText.isEmpty {
            return vm.books
        } else {
            return vm.books.filter { $0.judul_buku.localizedCaseInsensitiveContains(searchText) }
        }
    }
    /// Menampilkan judul buku yang dipilih atau placeholder.
    var selectedBookTitle: String {
        if let book = vm.books.first(where: { $0.id == selectedBookID }) {
            return book.judul_buku
        } else {
            return "Pilih Buku..."
        }
    }
    /// UI form peminjaman dan sheet pencarian buku.
    var body: some View {
        NavigationStack{
            Form{
                Section("Siapa yang meminjam?") {
                    Picker("Nama Anggota", selection: $selectedMemberID) {
                        Text("Pilih Anggota...").tag(nil as UUID?)
                        
                        ForEach(vm.anggota) { member in
                            Text(member.nama_lengkap).tag(member.id)
                        }
                    }
                }
                Section("Buku apa yang dipinjam?") {
                    Button {
                        isShowingBookSearch = true // Buka Sheet Pencarian
                    } label: {
                        HStack {
                            Text("Judul Buku")
                                .foregroundColor(.primary)
                            Spacer()
                            // Tampilkan judul buku atau placeholder
                            Text(selectedBookTitle)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .task {
                try? await vm.fetchBooks()
            }
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task{
                            if let idAnggota = selectedMemberID, !selectedBookID.isEmpty {
                                await vm.addLoans(bukuId: selectedBookID, anggotaId: idAnggota) // 1) Simpan data peminjaman
                                await vm.updateStock(bukuId: selectedBookID) // 2) Kurangi stok buku
                                dismiss()
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(selectedBookID.isEmpty || selectedMemberID == nil)
                    
                }
            }
            .sheet(isPresented: $isShowingBookSearch) {
                NavigationStack {
                    List(filteredBooks) { book in
                        Button {
                            selectedBookID = book.id // 1. Simpan ID
                            isShowingBookSearch = false // 2. Tutup Sheet
                            searchText = "" // 3. Reset search (opsional)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(book.judul_buku)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(book.penulis ?? "")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                // Tanda centang jika ini buku yang sedang dipilih
                                if book.id == selectedBookID {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                    .navigationTitle("Pilih Buku")
                    .navigationBarTitleDisplayMode(.inline)
                    .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Cari judul buku...")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Tutup") {
                                isShowingBookSearch = false
                            }
                        }
                    }
                }
            }
        }
    }
}

