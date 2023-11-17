//
//  SendableBootcamp.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 10/23/23.
//

import SwiftUI


actor CurrentUserManager {
    
    func updateDatabase(userInfo: MyClassUserInfo) {
        
    }
    
}

// struct conform to sendable by default but is better to especified it. 
struct MyUserInfo: Sendable {
    var name: String
}

// @unchecked really dangerous

final class MyClassUserInfo: @unchecked Sendable {
    
    
   private var name : String
    
    let queue = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
    
    init(name: String) {
        self.name = name
    }
    
    
    func updateName (name: String) {
        queue.async {
            self.name = name
        }
    }
    
}

@Observable
class SendableBootcampViewModel {
    let manager = CurrentUserManager()
    
    
    func updateCurrentUserInfo() async {
        
        let info = MyClassUserInfo(name: "info")
        await manager.updateDatabase(userInfo: info)
    }
    
    
}



struct SendableBootcamp: View {
    
    private var viewModel = SendableBootcampViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                
            }
    }
}

#Preview {
    SendableBootcamp()
}
