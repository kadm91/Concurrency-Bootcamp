//
//  DoCatchTryThrow.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 9/3/23.
//

import SwiftUI

class DoCatchTryThrowsBoodcampDataManager {
    
    let isActivve = true // simulates fetching error
    
    
    func getTitle() -> (title: String?, error: Error?) {
        
        if isActivve {
            return ("New Text!", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    
    func getTitle2() -> Result<String, Error> {
        
        if isActivve {
            return .success("New Text!")
        } else {
            return .failure(URLError(.appTransportSecurityRequiresSecureConnection))
        }
        
    }
    
    func getTitle3() throws ->  String {
//        if isActivve {
//            return "New Text!"
//        } else {
            throw URLError(.badServerResponse)
      //  }
    }
    
    func getTitle4() throws -> String {
        if isActivve {
            return "Final Text!"
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
    
    
    
    
}

class DoCatchTryThrowsBoodcamp: ObservableObject {
    
@Published private(set) var text = "Starting Text"
    let manager = DoCatchTryThrowsBoodcampDataManager()
    
    
    func fetchTitle() {
        
        /* getTitle()
        let returnedValue = manager.getTitle()
        if let newTitle = returnedValue.title {
            self.text = newTitle
        } else if let error = returnedValue.error {
            self.text = error.localizedDescription
        }
         */
        
        /*
        let result = manager.getTitle2()
        switch result {
            
        case .success(let newTitle):
            self.text = newTitle
        case .failure(let error):
            self.text = error.localizedDescription
        }
        
        */
        
//        let newTitle = try? manager.getTitle3()
//        if let newTitle = newTitle {
//            self.text = newTitle
//        }
        
        
        do {
            let newTitle = try? manager.getTitle3()
            if let newTitle = newTitle {
                self.text = newTitle
            }
           

            let finalTitle = try manager.getTitle4()
            self.text = finalTitle

        } catch {
            self.text = error.localizedDescription
        }
     
    }
    
}


struct DoCatchTryThrow: View {
    
    @StateObject private var viewModel = DoCatchTryThrowsBoodcamp()
    
    
    
    var body: some View {
        Text(viewModel.text)
            .font(.title)
            .bold()
            .frame(width: 300, height: 300)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

struct DoCatchTryThrow_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrow()
            .preferredColorScheme(.dark)
    }
}
