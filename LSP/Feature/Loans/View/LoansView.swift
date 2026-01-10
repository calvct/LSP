//
//  LoansView.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 10/01/26.
//

import SwiftUI

struct LoansView: View {
    @State var isLoanModalPresented: Bool = false
    @StateObject var vm : CatalogViewModel
    @State private var selectedItem: viewPeminjaman? = nil
    
    
    
    var body: some View{
        NavigationStack{
            VStack{
                if(vm.viewPeminjaman.isEmpty){
                    Text("Silahkan Pilih Buku Untuk Dipinjam")
                }
                else{
                    ScrollView{
                        ForEach(vm.viewPeminjaman){ pinjam in
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
                            }
                        }
                    }
                }
            }
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
            .sheet(isPresented: $isLoanModalPresented){
                LoanModalView(vm: vm)
            }
            .sheet(item: $selectedItem) { item in
                EditStatusView(loanItem: item, vm: vm)
            }
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
