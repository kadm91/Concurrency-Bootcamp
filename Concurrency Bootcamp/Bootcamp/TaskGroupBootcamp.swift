//
//  TaskGroupBootcamp.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 10/3/23.
//

import SwiftUI

class TaskGroupBootcampDataManager {
    
    let url =  "https://picsum.photos/300"
    
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        async let fetchImage1 = fetchImage(urlString: url)
        async let fetchImage2 = fetchImage(urlString: url)
        async let fetchImage3 = fetchImage(urlString: url)
        async let fetchImage4 = fetchImage(urlString: url)
        
        
        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
        
        return [image1, image2, image3, image4]
        
    }
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        
        let urlStrings = [
        
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300"
        
        ]
     
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            images.reserveCapacity(urlStrings.count)
            
//            group.addTask {
//                try await self.fetchImage(urlString: self.url)
//            }
//            
//            group.addTask {
//                try await self.fetchImage(urlString: self.url)
//            }
//            
//            group.addTask {
//                try await self.fetchImage(urlString: self.url)
//            }
//            
//            group.addTask {
//                try await self.fetchImage(urlString: self.url)
//            }
//            
//            group.addTask {
//                try await self.fetchImage(urlString: self.url)
//            }
            
            for urlString in urlStrings {
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            
//            for _ in 0...10 {
//                group.addTask {
//                    try await self.fetchImage(urlString: "https://picsum.photos/300")
//                }
//            }
            
            
            
            
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            

            return images
        }
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        
        
        guard let url = URL(string: urlString) else {throw URLError(.badURL)}
        
        
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
    
}


@Observable class TaskGroupBootCampViewModel {
    var images: [UIImage] = []
    let manager = TaskGroupBootcampDataManager()
    
    
    
    func getImagesWithAsyncLet () async {
        if let images = try? await manager.fetchImagesWithAsyncLet() {
            self.images.append(contentsOf: images)
        }
    }
    
    func getImagesWithTaskGroup() async {
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
    
    
    
}

struct TaskGroupBootcamp: View {
    
    var viewModel = TaskGroupBootCampViewModel()
    
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/300")!
    
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid (columns: columns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Task Group 🥳")
            .task {
               // await viewModel.getImagesWithAsyncLet()
                await viewModel.getImagesWithTaskGroup()
            }
        }
    }
}






#Preview{
    TaskGroupBootcamp()
        .preferredColorScheme(.dark)
}
