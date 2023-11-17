//
//  ActorsBootcamp.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 10/16/23.
//

import SwiftUI


// 1. What is the problem that actor are solving? It solve data racing
// 2. How was this problem soved prior to actors? Using custom Dispatchqueqs and completion Handlers
// 3. Actor can solve the problm! actor solv the problem with les code and cleaner code, thread safe by default



class MyDataManager {
    
    static let instatnce = MyDataManager()
    private init() {}
    
    var data: [String] = []
    
    // This solution is for before actor where inplemented
    
    private let queue = DispatchQueue(label: "com.MyApp.MyDataManager")
    
    func getRandomData(  completionHandler: @escaping (_ title: String?)-> Void) {
        
        queue.async {
            self.data.append(UUID().uuidString)
                   print(Thread.current)
            
            completionHandler(self.data.randomElement())
        }
    }
}


//MARK: - Solution using Actors

actor MyActorDataManager {
    
    static let instatnce = MyActorDataManager()
    private init() {}
    
    var data: [String] = []
    
   nonisolated let myRandomText = "Something"
    
    func getRandomData() -> String?  {
        
      
            self.data.append(UUID().uuidString)
                   print(Thread.current)
                   return data.randomElement()
        
    }
    
    
  nonisolated func getSaveData() -> String {
        return "New Data"
    }
}


//MARK: - HomeView

struct HomeView: View {
    
    let manager = MyActorDataManager.instatnce
    
    @State private var text: String = ""
    
    let timer = Timer.publish(every: 0.1, tolerance: nil ,on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onAppear(perform: {
           let newString = manager.getSaveData()
            
        })

        .onReceive(timer) { _ in
            
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
            
            
            
            
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                 
//                    }
//                }
//            }
          
        }
    }
}

//MARK: - BrowserView

struct BrowseView: View {
    
    let manager = MyActorDataManager.instatnce
    
    @State private var text: String = ""
    
    let timer = Timer.publish(every: 0.01, tolerance: nil ,on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
            
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                 
//                    }
//                }
//            }
        }
    }
}
    
    
    //MARK: - Main View
    
    struct ActorsBootcamp: View {
        var body: some View {
            TabView {
                HomeView()
                    .tabItem {
                        Label ("Home", systemImage: "house.fill")
                    }
                
                BrowseView()
                    .tabItem {
                        Label ("Browse", systemImage: "magnifyingglass")
                    }
            }
        }
    }
    
    







//MARK: - Preview
#Preview {
    ActorsBootcamp()
}
