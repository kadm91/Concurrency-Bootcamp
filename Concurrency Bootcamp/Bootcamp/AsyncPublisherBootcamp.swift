//
//  AsyncPublisherBootcamp.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 10/26/23.
//

import SwiftUI
import Combine

//MARK: - Data Manager

class AsyncPublisherBootcampManager {
     
   @Published var myData: [ String] = []
   
    func addData() async {
        
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermodel")
    }
}


//MARK: - View Model


class AsyncPublisherBootcampViewModel: ObservableObject {
    
    @MainActor @Published var dataArray: [String] = []
    let manager = AsyncPublisherBootcampManager()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        Task {
            await MainActor.run {
                self.dataArray = ["One"]
            }
            
            
            // if we dont break the for loop it will never stop
            for await value in manager.$myData.values {
                await MainActor.run {
                    self.dataArray = value
                    
                }
               
            }
            
            await MainActor.run {
                self.dataArray = ["Two"]
            }
            
            
            
        }
      
        
        
        
//        manager.$myData
//            .receive(on: DispatchQueue.main, options: nil)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &cancellables)
    }
    
    func start() async {
      await manager.addData()
    }
    
}

//MARK: - View

struct AsyncPublisherBootcamp: View {
    
    
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
    
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

#Preview {
    AsyncPublisherBootcamp()
}
