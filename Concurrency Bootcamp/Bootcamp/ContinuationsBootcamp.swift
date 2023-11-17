//
//  ContinuationsBootcamp.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 10/4/23.
//

import SwiftUI

//MARK: - Network Manager

class CheckedContinuationBootCampNetworkManager {
    
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            return data
        } catch {
            throw error
        }
    }
    
    func getData2 (url: URL) async throws -> Data {
        return try await withUnsafeThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
    
    func getHeartImageFromDataBase(completionHandler: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5 ) {
            completionHandler(UIImage(systemName: "heart.fill")!)
            
        }
    }
    
    func getHeartImageFromDataBase2() async -> UIImage {
        await withCheckedContinuation { continuation in
            getHeartImageFromDataBase { image in
                continuation.resume(returning: image)
            }
        }
    }
    
    
}

//MARK: - View Model

@Observable class CheckedContinuationBootCampViewModel {
    
    var image: UIImage? = nil
    let networkManager = CheckedContinuationBootCampNetworkManager()
    
    func getImage() async {
      
        guard let url = URL(string: "https://picsum.photos/300") else {return}
        do {
            let data = try await networkManager.getData(url: url)
            
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                }
            }
            
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getImage2() async {
        guard let url = URL(string: "https://picsum.photos/300") else {return}
        do {
            let data = try await networkManager.getData2(url: url)
            
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                }
            }
            
            
        } catch {
            print(error.localizedDescription)
        }

    }
    
    func getHeartImage() {
        networkManager.getHeartImageFromDataBase { [weak self] image in
            self?.image = image
        }
    }
    
    func getHeartImage2() async {
    
            self.image = await networkManager.getHeartImageFromDataBase2()
    
    }
    
}

//MARK: - UI

struct ContinuationsBootcamp: View {
    
    private var viewModel = CheckedContinuationBootCampViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                  
            }
        }
        .task {
            await viewModel.getHeartImage2()
        }
    }
}

//MARK: - Preview

#Preview {
    ContinuationsBootcamp()
}
