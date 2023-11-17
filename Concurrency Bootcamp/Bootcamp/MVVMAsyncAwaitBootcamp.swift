//
//  MVVMAsyncAwaitBootcamp.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 11/6/23.
//

import SwiftUI

//MARK: - Data Manager

final class MyManagerClass {
    func getData() async throws -> String {
        "Some Data"
    }
}

//MARK: - Manager Actor

actor MyManagerActor {
    func getData() async throws -> String {
        "Some Data"
    }
}

//MARK: - View Model

//@MainActor
@Observable
final class MVVMBootCampViewModel {
    
    @ObservationIgnored let managerClass = MyManagerClass()
    @ObservationIgnored let managerActor = MyManagerActor()
    @ObservationIgnored private var tasks: [ Task<Void, Never>] = []
    
    @MainActor private (set) var myData: String = "Starting String"
    
    func cancelTask() {
        tasks.forEach {$0.cancel()}
        tasks = []
    }
    
    
    func onCallToActionButtonPress () {
        let task = Task { @MainActor in
            
            do {
                //myData = try await managerClass.getData()
                
                myData = try await managerActor.getData()
                
            } catch {
                print(error)
            }
            
            
        }
        tasks.append(task)
    }
    
}


//MARK: - View

struct MVVMAsyncAwaitBootcamp: View {
    
    @State private var viewModel = MVVMBootCampViewModel()
    
    var body: some View {
        
        VStack {
            
            Button(viewModel.myData) {
                viewModel.onCallToActionButtonPress()
            }
            
        }
        .onDisappear {
            viewModel.cancelTask()
        }
        
    }
}


//MARK: - Preview

#Preview {
    MVVMAsyncAwaitBootcamp()
}
