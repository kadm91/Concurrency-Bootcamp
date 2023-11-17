//
//  TaskBootcamp.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 9/11/23.
//

import SwiftUI

class TaskBootcampViewModel: ObservableObject {
    
    @Published var image: UIImage?
    @Published var image2: UIImage?
    
    
    // Task.CheckForCancellation() it trows
    
    
    func fetchImage() async {
        
       try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        do{
            guard let url = URL(string: "https://picsum.photos/1000") else {return}
            
           let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run(body: {
                self.image =  UIImage(data: data)
                print("Image1 Returned Successfully!")
            })
           
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do{
            guard let url = URL(string: "https://picsum.photos/1000") else {return}
            
           let (data, _) = try await URLSession.shared.data(from: url)
        
            await MainActor.run(body: {
                self.image2 =  UIImage(data: data)
                print("Image2 Returned Successfully!")
            })
           
            
        } catch {
            print(error.localizedDescription)
        }
    }
}


struct TaskBootcampHomeView: View {
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                NavigationLink("Click Me!") {
                    TaskBootcamp()
                }
            }
        }
    }
}


struct TaskBootcamp: View {
    
    @StateObject private var viewModel = TaskBootcampViewModel()
    @State private var fetchImageTask1: Task<(), Never>? = nil
    @State private var fetchImageTask2: Task<(), Never>? = nil
    
    var body: some View {
        VStack (spacing: 40) {
            if let image = viewModel.image, let image2 = viewModel.image2 {
                Group {
                    Image(uiImage: image).resizable()
                    Image(uiImage: image2).resizable()
                }
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.fetchImage()
            await viewModel.fetchImage2()
        }

//        .onDisappear{
//            fetchImageTask1?.cancel()
//            fetchImageTask2?.cancel()
//        }
        
//        .onAppear {
//       fetchImageTask1 = Task {
//
//                await viewModel.fetchImage()
//
//            }
//
//    fetchImageTask2 = Task {
//
//                await viewModel.fetchImage2()
//            }
//
//
//
//
//
//
//
//
////            Task(priority: .high) {
////                //try? await Task.sleep(nanoseconds: 2_000_000_000)
////                await Task.yield()
////                print("High: \(Thread.current) : \(Task.currentPriority)")
////            }
////
////            Task(priority: .userInitiated) {
////                print("User Initiated: \(Thread.current) : \(Task.currentPriority)")
////            }
////
////            Task(priority: .medium) {
////                print("Medium: \(Thread.current) : \(Task.currentPriority)")
////            }
////
////            Task(priority: .low) {
////                print("Low: \(Thread.current) : \(Task.currentPriority)")
////            }
////
////            Task(priority: .utility) {
////                print("Utility: \(Thread.current) : \(Task.currentPriority)")
////            }
////
////            Task(priority: .background) {
////                print("Background: \(Thread.current) : \(Task.currentPriority)")
////            }
//
//
////
////            Task (priority: .userInitiated) {
////                print("UserInitiated: \(Thread.current) : \(Task.currentPriority)")
////
////                Task.detached{
////                    print("detached: \(Thread.current) : \(Task.currentPriority)")
////                }
////            }
//
//
//
//
//
//
//
//        }
    }
}

struct TaskBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskBootcamp()
    }
}
