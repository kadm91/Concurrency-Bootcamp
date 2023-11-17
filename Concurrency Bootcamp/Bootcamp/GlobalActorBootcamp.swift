//
//  GlobalActorBootcamp.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 10/20/23.
//

import SwiftUI


@globalActor final class MyFirstGlobalActor {
static var shared = MyNewDataManager()
}


actor MyNewDataManager {
    

    func getDataFromDataBase() -> [String] {
        ["One", "Two", "Three", "Four", "Five", "Six", "Seven"]
    }
    
}




@Observable

class GlobalActorViewModel {
    
    
    // @MainActor can be in the struct insted of each poperty 
    
    
    @MainActor    var dataArray: [String] = []
    let manager = MyFirstGlobalActor.shared
    
  
    @MyFirstGlobalActor
  //  @MainActor
    func getData() async {
        
        // HEAVY COMPLEX METHODS
        
        let data = await manager.getDataFromDataBase()
        await MainActor.run {
            self.dataArray = data
        }
    }
}





struct GlobalActorBootcamp: View {
    
    private var viewModel = GlobalActorViewModel()
    
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
            await viewModel.getData()
        }
    }
}

#Preview {
    GlobalActorBootcamp()
}
