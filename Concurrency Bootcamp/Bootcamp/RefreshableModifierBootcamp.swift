//
//  RefreshableModifierBootcamp.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 11/6/23.
//

import SwiftUI

//MARK: - Data Service

final class RefreshableDataService {
    func getData() async throws -> [String] {
        
        try? await Task.sleep(nanoseconds: 5_000_000_000)
      return  ["apple", "orange", "banana"].shuffled()
    }
}


//MARK: - ViewModel

@MainActor
final class RefreshableBootCampViewModel: ObservableObject {
    
    @Published private(set) var items: [String] = []
    private let manager = RefreshableDataService()
    
    func loadData () async {
        
            do {
                items = try await manager.getData()
            } catch {
                print(error)
            }
        
    }
}


//MARK: - View

struct RefreshableModifierBootcamp: View {
    
  @StateObject private var viewModel = RefreshableBootCampViewModel()
    
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewModel.items, id: \.self) { item in
                        Text(item)
                            .font(.headline)
                    }
                }
            }
            .refreshable {
              
                    await viewModel.loadData()
                
                
            }
            .navigationTitle("Refreshable")
            .task {
                
                  await viewModel.loadData()
                
            }
        }
    }
}

#Preview {
    RefreshableModifierBootcamp()
}
