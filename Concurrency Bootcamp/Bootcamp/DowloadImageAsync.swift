//
//  DowloadImageAsync.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 9/3/23.
//

import SwiftUI
import Combine

class DowloadImageAsyncImageLoader {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    
    
    func dowloadWithEspcaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?)-> ()) {
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            let image = self?.handleResponse(data: data, response: response)
            
            /*
            guard
                let data = data,
                    let image = UIImage(data: data),
                let response = response as? HTTPURLResponse,
                response.statusCode >= 200 && response.statusCode < 300 else {
                completionHandler(nil, error)
                return
            }
             */
            
            completionHandler(image, error)

        }
        .resume()
    }
    
    func dowloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({$0})
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsync() async throws -> UIImage?{
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            return handleResponse(data: data, response: response)
            
        } catch {
            throw error
        }
        
        
    }
    
    
    
}

class DowloadImageAsyncViewModel: ObservableObject {
    @Published private(set) var image: UIImage?
    
    let loader = DowloadImageAsyncImageLoader()
    
    var cancellables = Set<AnyCancellable>()
    
    func fetchImage() async {
        
        //MARK: - Dowload using Completion Handler
        
//        loader.dowloadWithEspcaping { [weak self] image, error in
//            DispatchQueue.main.async {
//                self?.image = image
//            }
//        }
        
        //MARK: - Dowload using combine
        
//        loader.dowloadWithCombine()
//            .receive(on: DispatchQueue.main)
//            .sink{   _ in
//
//            } receiveValue: { [weak self] image in
//                    self?.image = image
//            }
//            .store(in: &cancellables)
        
        //MARK: - Dowload using async await
        
        do {
           let image = try await loader.downloadWithAsync()
          
            await MainActor.run { [weak self] in
                guard let self = self else {return}
                self.image = image
            }
        
            
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    
}


struct DowloadImageAsync: View {
    
    @StateObject private var viewModel = DowloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear{
            Task {
                await viewModel.fetchImage()
            }
        }
    }
}

struct DowloadImageAsync_Previews: PreviewProvider {
    static var previews: some View {
        DowloadImageAsync()
    }
}
