//
//  StructClassActorBootcamp.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 10/9/23.
//

/*
 
 Links:
 
 https://blog.onewayfirst.com/ios/posts/2019-03-19-class-vs-struct/
 https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language
 https://medium.com/@vinajakkini/swift-basics-struct-vs-class-31b44ade28ae
 https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language/59219141#59219141
 https://stackoverflow.com/questions/27441456/swift-stack-and-heap-understanding
 https://stackoverflow.com/questions/24232799/why-choose-struct-over-class/24232845
 https://www.backblaze.com/blog/whats-the-diff-programs-processes-and-threads/
 
 
 VALUE TYPES:
 
 - Struct, Enum, String, Int, etc
 - Stored in the Stack
 - Faster than Referent types
 - Thread Safe!
 - When you assign or pass value type a new copy of data is created
 
 --------------------------------------------------------------------------------------------------------------------------
 
 REFERENCE TYPES:
 
 - Class, Functions, Actor
 - Stored in the Heap
 - Slower, but synchronized (Heap is synchronized across all threads)
 - Not Thread safe
 - When you assign or pass reference type a new refernce to original instance will be created (pointer)
 
 --------------------------------------------------------------------------------------------------------------------------
 
 STACK:
 
 - Store Value Types
 - Variables allocated on the stack are stored directly to the memory , and access to htis memory is very fast
 - Each Thread has it's own stack!
 
 --------------------------------------------------------------------------------------------------------------------------
 
 HEAP:
 
 - Store Reference types
 - Shared across threads!
 
 --------------------------------------------------------------------------------------------------------------------------
 
 STRUCT:
 
 - Based on VALUES
 - Can be mutated
 - Stored in the Stack!
 
 --------------------------------------------------------------------------------------------------------------------------
 
 CLASS:
 
 - Based on REFERENCES (INSTANCES)
 - Stored in the Heap!
 - Inherit from other Classes
 
 --------------------------------------------------------------------------------------------------------------------------
 
 ACTORS:
 
 - Same as Class, but thread safe!
 - Need to be in a async enviroment
 
 --------------------------------------------------------------------------------------------------------------------------
 
 Sturcts: Data Models, Views
 Clases: View Models
 Actors: Data Manager Classes , especially singletons, will be use from alot of threads in the app, shared manager and Data store classes
 
 --------------------------------------------------------------------------------------------------------------------------
 
 EXAMPLE OF MVVM STRUCTURE
 
 
 actor StructClassActorBootCampDataManager {
     
     func getDataFromDataBase() {}
 }

 class StructClassActorBootcampViewModel: ObservableObject {
     @Published var title: String = ""

 }

 struct StructClassActorBootcamp: View {
     var body: some View {
         Text("Hello, World!")
             .onAppear {
                 runTest()
             }
     }
 }

 
 */



import SwiftUI


actor StructClassActorBootCampDataManager {
    
    func getDataFromDataBase() {}
}

class StructClassActorBootcampViewModel: ObservableObject {
    @Published var title: String = ""

    
    init() {
        print("ViewModel INIT")
    }
    
}





struct StructClassActorBootcamp: View {
    
    @StateObject private var viewModel = StructClassActorBootcampViewModel()
    let isActive: Bool
    
    init(isActive: Bool) {
        self.isActive = isActive
        print("View INIT")
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(isActive ? Color.red : Color.blue)
            .onAppear {
               // runTest()
                
        }
    }
}


struct StructClassActorBootcampHomeView: View {
    
    @State private var isActive: Bool = false
    
    var body: some View {
       StructClassActorBootcamp(isActive: isActive)
            .onTapGesture {
                isActive.toggle()
            }
    }
    
}

#Preview {
    StructClassActorBootcamp(isActive: true)
}
















extension StructClassActorBootcamp {
    
    private func runTest() {
        print("Test Started!")
               structTest1()
                printDiveder()
                classTest1()
        
        printDiveder()
        actorTest1()
        
//        structTest2()
//        printDiveder()
//        classTest2()
    }
    
    private func printDiveder() {
        print ( """
        
        ---------------------------------
        
        """)
    }
    
    private func structTest1() {
        print("structTest1")
        let objectA = MyStruct(tile: "Starting Title!")
        print("ObjectA: ", objectA.tile)
        
        
        print("Pass the VALUES of objectA to objectB")
        
        var objectB = objectA
        print("ObjectB: ", objectB.tile)
        
        
        objectB.tile = "Secound Title!"
        print("ObjectB title changed.")
        print("ObjectA: ", objectA.tile)
        print("ObjectB: ", objectB.tile)
        
    }
    
    
    private func classTest1() {
        print("classTest1")
        let objectA = MyClass(tile: "Starting Title!")
        print("ObjectA: ", objectA.tile)
        
        print("Pass the REFERENCE of objectA to objectB")
        
        let objectB = objectA
        print("ObjectB: ", objectB.tile)
        
        objectB.tile = "Secound Title!"
        print("ObjectB title changed.")
        print("ObjectA: ", objectA.tile)
        print("ObjectB: ", objectB.tile)
        
        
    }
    
    private func actorTest1() {
        
        Task {
            print("actorTest1")
            let objectA = MyActor(tile: "Starting Title!")
         await print("ObjectA: ", objectA.tile)
            
            print("Pass the REFERENCE of objectA to objectB")
            
            let objectB = objectA
            await print("ObjectB: ", objectB.tile)
            
            await objectB.updateTitle(newTitle: "Secound Title!")
            
            print("ObjectB title changed.")
            await print("ObjectA: ", objectA.tile)
            await print("ObjectB: ", objectB.tile)
        }
        
    }
    
    
}

struct MyStruct {
    var tile: String
}

// Inmutable Struct
struct CustomStruct {
    let title: String
    
    func UpdateTitle(newTitle: String) -> CustomStruct {
        CustomStruct(title: newTitle)
    }
}


// Mutating Struct
struct MutatingStruct {
    private (set) var title: String
    
    init(title: String) {
        self.title = title
    }
    
    mutating func updateTitle(newTitle: String) {
        title = newTitle
    }
}


extension StructClassActorBootcamp {
    
    private func structTest2() {
        print ("structTest2")
        
        var struct1 = MyStruct(tile: "Title1")
        print("Struct1: ", struct1.tile)
        struct1.tile = "Title2"
        print("Struct1: ", struct1.tile)
        
        var struct2 = CustomStruct(title: "Title1")
        print("Struct2: ", struct2.title)
        struct2 = CustomStruct(title: "Title2")
        print("Struct2: ", struct2.title)
        
        var struct3 = CustomStruct(title: "Title1")
        print("Struct3: ", struct3.title)
        struct3 = struct3.UpdateTitle(newTitle: "Title2")
        print("Struct3: ", struct3.title)
        
        var struct4 = MutatingStruct(title: "Tilte1")
        print("Struct4: ", struct4.title)
        struct4.updateTitle(newTitle: "Title2")
        print("Struct4: ", struct4.title)
    }
}


class MyClass {
    var tile: String
    
    init(tile: String) {
        self.tile = tile
    }
    
     func updateTitle(newTitle: String) {
         tile = newTitle
    }
    
}


actor MyActor {
    var tile: String
    
    init(tile: String) {
        self.tile = tile
    }
    
     func updateTitle(newTitle: String) {
         tile = newTitle
    }
    
}



extension StructClassActorBootcamp {
    
    private func classTest2 () {
        print("classTest2")
        
        let class1 = MyClass(tile: "Title1")
        print("class1: ", class1.tile)
        class1.tile = "Title2"
        print("class1: ", class1.tile)
        
        let class2 = MyClass(tile: "Title1")
        print("class2: ", class2.tile)
        class2.updateTitle(newTitle: "Title2")
        print("class2: ", class2.tile)
        
    }
}
