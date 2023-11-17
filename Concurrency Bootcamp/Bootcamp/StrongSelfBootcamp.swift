//
//  StrongSelfBootcamp.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 11/1/23.
//

import SwiftUI

//MARK: - Data Manager

final class StrongSelfDataService {
    
    func getData() async -> String {
        "Updated Data"
    }
}

//MARK: - View Model

@Observable
final class StrongSelfBootcampViewModel {
    
    var data = "Some Title!"
    @ObservationIgnored let dataService = StrongSelfDataService()
    @ObservationIgnored private var someTask: Task<Void, Never>?
    @ObservationIgnored private var myTasks: [Task<Void, Never>] = []
    
    
    
    func cancelTasks() {
        someTask?.cancel()
        someTask = nil
        
        myTasks.forEach{$0.cancel()}
        myTasks = []
    }
    
    // This implies a strong reference....
    func updateData() {
        Task {
            data = await dataService.getData()
        }
    }
    
    // This is a strong reference....
    func updateData2() {
        Task {
            self.data = await dataService.getData()
        }
    }
    
    // This is a strong reference....
    func updateData3() {
        Task { [self] in
            self.data = await dataService.getData()
        }
    }
    
    //this is a weak reference
    func updateData4() {
        Task { [weak self] in
            if let data = await self?.dataService.getData() {
                self?.data = data
            }
        }
    }
    
    
    // We don't need to manage weak/strong
    // We can manage the Task!
    func updateData5() {
      someTask = Task {
            data = await dataService.getData()
        }
    }
    
    
    
    // We can manage the Task at the task level
    func updateData6() {
    
        let task1 = Task {
              data = await dataService.getData()
          }
        
        myTasks.append(task1)
        
        let task2 = Task {
              data = await dataService.getData()
          }
        
        myTasks.append(task2)
        
    }
    
    // We purposely do not cancel task to keep strong references
    func updateData7() {
     Task {
            data = await dataService.getData()
        }
        
        Task.detached {
            self.data = await self.dataService.getData()
        }
    }
    
    func updateData8() async {

            data = await dataService.getData()
        
    }
    
    
}

//MARK: - View

struct StrongSelfBootcamp: View {
    
    @State private var viewModel = StrongSelfBootcampViewModel()
    
    var body: some View {
        Text(viewModel.data)
            .onAppear {
                viewModel.updateData()
            }
            .onDisappear {
                viewModel.cancelTasks()
            }
            .task {
                await viewModel.updateData8()
            }
    }
}



//MARK: - Preview

#Preview {
    StrongSelfBootcamp()
}
