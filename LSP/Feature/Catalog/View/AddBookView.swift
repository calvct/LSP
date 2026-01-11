//
//  AddBookView.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 10/01/26.
//

import SwiftUI

/// Tampilan untuk menambahkan buku baru ke katalog.
/// Menggunakan `CatalogViewModel` untuk menyimpan data ke backend.
struct AddBookView: View {
    /// View model katalog yang menangani operasi penambahan buku.
    @EnvironmentObject var vm: CatalogViewModel
    /// Input judul buku.
    @State var namaBuku : String = ""
    /// Input nama penulis.
    @State var namaPenulis : String = ""
    /// Input tanggal/tahun terbit buku.
    @State var tahunTerbit : Date = Date()
    /// ID kategori yang dipilih pengguna (opsional hingga dipilih).
    @State var selectedIdCategory : Int? = nil
    /// Jumlah eksemplar buku yang akan ditambahkan.
    @State var jumlahBuku: Int = 1
    /// Aksi untuk menutup tampilan setelah berhasil menyimpan.
    @Environment(\.dismiss) var dismiss
    
    /// Formulir input untuk menambahkan buku dengan bidang judul, penulis, kategori, tanggal terbit, dan jumlah.
    var body: some View {
        NavigationStack{
            Form{
                // Judul buku.
                TextField("Masukkan Judul Buku", text: $namaBuku)
                // Nama penulis.
                TextField("Penulis", text: $namaPenulis)
                // Pilihan kategori. Elemen pertama adalah placeholder "Pilih Kategori".
                Picker("Kategori", selection: $selectedIdCategory){
                    Text("Pilih Kategori").tag(nil as Int?)
                    ForEach(vm.kategori.indices.dropFirst(), id: \.self){i in
                        Text(vm.kategori[i].nama_kategori).tag(vm.kategori[i].id)
                    }
                }
                // Tanggal terbit buku.
                DatePicker("Tanggal Terbit", selection: $tahunTerbit, displayedComponents: .date)
                // Input jumlah eksemplar buku.
                HStack{
                    Text("Jumlah Buku")
                    Divider()
                    TextField("Jumlah Buku", value: $jumlahBuku, format: .number)
                        .keyboardType(.numberPad)
                }
            }
            // Tombol simpan untuk menambahkan buku baru.
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action:{
                        Task{
                            do{
                                // Mengirim data ke view model untuk disimpan ke Supabase, lalu menutup tampilan.
                                await vm.addBook(namaBuku: namaBuku, penulis: namaPenulis, tahunTerbit: tahunTerbit, jumlahBuku: jumlahBuku, idKategori: selectedIdCategory!)
                                dismiss()
                            } 
                        }
                    }){
                        Image(systemName: "checkmark")
                    }
                    // Validasi sederhana: judul/penulis tidak boleh kosong dan kategori harus dipilih.
                    .disabled(namaBuku.isEmpty || namaPenulis.isEmpty || selectedIdCategory == 0)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button{
                        dismiss()
                    }
                    label:{
                        Image(systemName:"xmark")
                    }
                }
            }
            .navigationTitle(Text("Tambah Buku"))
        }
    }
}

/// Pratinjau AddBookView dengan environment object dummy.
#Preview {
    let vm = CatalogViewModel()
    AddBookView()
        .environmentObject(vm)
}
