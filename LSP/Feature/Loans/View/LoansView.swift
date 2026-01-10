//
//  LoansView.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 10/01/26.
//

import SwiftUI

/// Tampilan daftar peminjaman aktif. Menampilkan ringkasan peminjaman dan menyediakan aksi untuk menambah atau mengubah status.
struct LoansView: View {
    /// Menentukan apakah modal peminjaman baru ditampilkan.
    @State var isLoanModalPresented: Bool = false
    /// View model peminjaman yang menyediakan data dan aksi terkait peminjaman.
    @EnvironmentObject var vm: LoanViewModel
    /// Item peminjaman yang dipilih untuk diedit statusnya.
    @State private var selectedItem: viewPeminjaman? = nil
    /// Hierarki tampilan utama yang mencakup empty state, daftar peminjaman, toolbar, sheet, dan refresh.
    var body: some View{
        NavigationStack{
            VStack{
                // Empty state ketika belum ada peminjaman.
                if(vm.viewPeminjaman.isEmpty){
                    Text("Silahkan Pilih Buku Untuk Dipinjam")
                }
                else{
                    // Daftar peminjaman yang sedang berjalan.
                    ScrollView{
                        // Render setiap item peminjaman.
                        ForEach(vm.viewPeminjaman){ pinjam in
                            // Hanya tampilkan item dengan status "Dipinjam".
                            if(pinjam.status == "Dipinjam"){
                                VStack (alignment: .leading){
                                    HStack{
                                        Text(pinjam.nama_peminjam)
                                            .font(.title2)
                                            .bold(true)
                                        Spacer()
                                        Button(action:{
                                            selectedItem = pinjam
                                        }){
                                            Text("Edit")
                                        }
                                    }
                                    VStack(alignment: .leading){
                                        Text(pinjam.judul_buku)
                                            .font(.headline)
                                        HStack{
                                            Text(pinjam.tanggal_pengembalian, format: .dateTime.day().month().year())
                                            Spacer()
                                            Text(pinjam.statusPeminjaman)
                                                .padding(4)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(pinjam.warnaStatus.opacity(0.6))
                                                )
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.gray.opacity(0.5)))
                                        
                                    )
                                    
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGroupedBackground))
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            // Tombol untuk membuka modal peminjaman baru.
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action:{
                        isLoanModalPresented = true
                    }){
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle(Text("Loans"))
            // Modal untuk membuat peminjaman baru.
            .sheet(isPresented: $isLoanModalPresented){
                LoanModalView()
                    .environmentObject(vm)
            }
            // Modal untuk mengedit status peminjaman terpilih.
            .sheet(item: $selectedItem) { item in
                EditStatusView(loanItem: item)
                    .environmentObject(vm)
            }
            // Tarik untuk menyegarkan data peminjaman dari backend.
            .refreshable(action: {
                do{
                    try await vm.fetchViewPeminjaman()
                }catch{
                    debugPrint(error)
                }
            })
            
        }
        
        
    }
}

