//
//  PhotosPickerBootcamp.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 11/16/23.
//

import SwiftUI
import PhotosUI

//MARK: - View Model

@MainActor
final class PhotosPickerViewModel: ObservableObject {
    
    @Published private(set) var selectedImage: UIImage?
    @Published var imageSelection: PhotosPickerItem? {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    @Published private(set) var selectedImages: [UIImage] = []
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            setImages(from: imageSelections)
        }
    }
    
    
//MARK: - Multiple selected images
    
    private func setImages(from selections: [PhotosPickerItem]) {

        Task {
            var images = [UIImage]()
            for selection in selections {
                if let data = try? await selection.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        images.append(uiImage)
                    }
                }
            }
            
            selectedImages = images
            
        }
    }
    
    
    
    //MARK: - Single Image
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else {return}
        Task {
//            if let data = try? await selection.loadTransferable(type: Data.self) {
//                if let uiImage = UIImage(data: data) {
//                    selectedImage = uiImage
//                    return
//                }
//            }
            
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badURL)
                }
                
                selectedImage = uiImage
                
                
                
            } catch {
                print(error)
            }
            
            
        }
    }
    
}


//MARK: - View

struct PhotosPickerBootcamp: View {
    
    @StateObject private var vm = PhotosPickerViewModel()
    
    
    var body: some View {
        VStack (spacing: 40) {
            Text("Hello, World!")
            
            if let image = vm.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
            }
            
            // single image
            
            PhotosPicker(selection: $vm.imageSelection, matching: .images) {
                Text("Open the photo picker")
                    .foregroundStyle(.red)
            }
            
            
            if !vm.selectedImages.isEmpty {
                ScrollView (.horizontal) {
                    HStack {
                        ForEach(vm.selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // multiple images
            
            PhotosPicker(selection: $vm.imageSelections, matching: .images) {
                Text("Open the photo picker")
                    .foregroundStyle(.red)
            }
        }
    }
    
    
    
    //MARK: - end of view struct
}

//MARK: - Preview

#Preview {
    PhotosPickerBootcamp()
}
