//
//  AsyncAwaitBootCamp.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 9/5/23.
//

import SwiftUI

class AsyncAwaitBootCampViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("Title1: \(Thread.current)")
        }
    }
    
    
    
    func addtitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title = ("title2: \(Thread.current)")
            DispatchQueue.main.async {
                self.dataArray.append(title)
                
                let title3 = ("title3: \(Thread.current)")
                self.dataArray.append(title3 )
            }
        }
    }
    
    
    func addAuthor1() async {
        //
        //        let author1 = "Author1 : \(Thread.current)"
        //        self.dataArray.append(author1)
        //
        //       // try? await doSomething()
        //
        //       try? await Task.sleep(nanoseconds: 2_000_000_000)
        //
        //        let author2 = "Author2 : \(Thread.current)"
        //        await MainActor.run(body:  {
        //            self.dataArray.append(author2)
        //
        //
        //            let author3 = "Author3 : \(Thread.current)"
        //            self.dataArray.append(author3)
        //
        //        })
        //
        //        await addSomething()
    }
    
    func addSomething() async {
        //        try? await Task.sleep(nanoseconds: 2_000_000_000)
        //        let something1 = "Something1 : \(Thread.current)"
        //        await MainActor.run(body:  {
        //            self.dataArray.append(something1)
        //
        //
        //            let something2 = "Something2 : \(Thread.current)"
        //            self.dataArray.append(something2)
        //
        //        })
        //    }
        
    }
    
    
    
    struct AsyncAwaitBootCamp: View {
        
        @StateObject private var viewModel = AsyncAwaitBootCampViewModel()
        
        var body: some View {
            List {
                ForEach(viewModel.dataArray, id: \.self) {data in
                    Text(data)
                }
            }
            .onAppear{
                Task {
                    
                    await viewModel.addAuthor1()
                    
                    
                    //                let finalText = "Final Text: \(Thread.current)"
//                    viewModel.dataArray.append(finalText)
                }
                //            viewModel.addTitle1()
                //            viewModel.addtitle2()
            }
        }
    }
    
    struct AsyncAwaitBootCamp_Previews: PreviewProvider {
        static var previews: some View {
            AsyncAwaitBootCamp()
        }
    }
}
