//
//  SearchableBootcamp.swift
//  Concurrency Bootcamp
//
//  Created by Kevin Martinez on 11/15/23.
//

// left at minute 25:22 because of Maria Dolores


import SwiftUI
import Combine

//MARK: - Model

struct Restaurant: Identifiable, Hashable {
    let id: String
    let title: String
    var cuisine: CuisineOption
}

enum CuisineOption: String  {
    case american, italian, japanese
}

//MARK: - Data Manager

final class RestaurantManger {
    
    func getAllRestaurants() async throws -> [Restaurant] {
        [
            Restaurant(id: "1", title: "Burger Shack", cuisine: .american),
            Restaurant(id: "2", title: "Pasta Palace", cuisine: .italian),
            Restaurant(id: "3", title: "Sushi Heaven", cuisine: .japanese),
            Restaurant(id: "4", title: "Local Market", cuisine: .american)
        ]
    }
    
}

//MARK: - View Model

@MainActor
final class SearchableViewModel: ObservableObject {
    @Published private (set) var allRestaurants = [Restaurant]()
    @Published private (set) var filteredRestaurants = [Restaurant]()
    @Published var searchText: String = ""
    @Published var searchScope: SearchScopeOption = .all
    @Published private (set) var allSearchScopes = [SearchScopeOption]()
    
    
    let manager = RestaurantManger()
    private var cancellables = Set<AnyCancellable>()
    
    var isSearching: Bool  {
        !searchText.isEmpty
    }
    
    var showSearchSuggestions: Bool  {
        searchText.count < 5
    }
    
    enum SearchScopeOption: Hashable {
        case all
        case cuisine(option: CuisineOption)
        
        var title: String {
            switch self{
                
            case .all:
                return "All"
            case .cuisine(option: let option):
                return option.rawValue.capitalized
            }
        }
    }
    
    init() {
        addSubscribers()
    }
    

    
    private func addSubscribers() {
     $searchText
            .combineLatest($searchScope)
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .sink { [weak self] (searchText, searchScope) in
                self?.filterRestaurants(serachText: searchText, currentSearchScope: searchScope)
            }
            .store(in: &cancellables)
    }
    
    
    private func filterRestaurants(serachText: String, currentSearchScope: SearchScopeOption) {
        guard !searchText.isEmpty else {
            filteredRestaurants = []
            searchScope = .all
            return
        }

        // Filter on search scope
        var restaurantInScope = allRestaurants
        switch currentSearchScope {
            
        case .all:
            break
        case .cuisine(option: let option):
            restaurantInScope = allRestaurants.filter ({$0.cuisine == option})
            
            // long way
//            ({ restaurant in
//                return restaurant.cuisine == option
//            })
        }
        
        // Filter on search Texst
        let seach = searchText.lowercased()
        filteredRestaurants = restaurantInScope.filter({ restaurant in
            
                        let titleContainsSearch = restaurant.title.lowercased().contains(seach)
                        let cuisineContainsSearch = restaurant.cuisine.rawValue.lowercased().contains(seach)
            
                        print(titleContainsSearch.description.count)
            
                        return titleContainsSearch || cuisineContainsSearch
        })
            

        
    }
    
    func loadRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestaurants()
            
            // this is for the searchScopes
            
            let allCuisines = Set(allRestaurants.map { $0.cuisine })
            allSearchScopes = [.all] + allCuisines.map ({SearchScopeOption.cuisine(option: $0)})
            
            // long way
//            ({option in
//                SearchScopeOption.cuisine(option: option)
//            })
            
            
        } catch {
            print(error.localizedDescription)
        }
    }
    

    // search suggestion function
    
    func getSearchSuggestions() -> [String] {
        
        guard showSearchSuggestions else {return[]}
        
    
        var suggestions: [String] = []
        
        let search = searchText.lowercased()
        
        if search.contains("pa") {
            suggestions.append("Pasta")
        }
        
        if search.contains("su") {
            suggestions.append("Sushi")
        }
        
        if search.contains("bu") {
            suggestions.append("Burger")
        }
        

        suggestions.append("Markert")
        suggestions.append("Grocery")
        
        suggestions.append(CuisineOption.italian.rawValue.capitalized)
        suggestions.append(CuisineOption.japanese.rawValue.capitalized)
        suggestions.append(CuisineOption.american.rawValue.capitalized)
     
    
        return suggestions
        
    }
    
    func getRestaurandSuggestions() -> [Restaurant] {
        
        guard showSearchSuggestions else {return[]}
        
    
        var suggestions: [Restaurant] = []
        
        let search = searchText.lowercased()
        
        if search.contains("ita") {
            suggestions.append(contentsOf: allRestaurants.filter({$0.cuisine == .italian}))
        }
        
        if search.contains("jap") {
            suggestions.append(contentsOf: allRestaurants.filter({$0.cuisine == .japanese}))
        }
        
    
        return suggestions
    }
    
}

//MARK: - View

struct SearchableBootcamp: View {
    
    @StateObject private var viewModel = SearchableViewModel()
  
    
    var body: some View {
        ScrollView {
            
            VStack (spacing: 20) {
                ForEach (viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restaurant in
                    
                    NavigationLink (value: restaurant) {
                        restaurantRow(for: restaurant)
                    }
                    
                 
                }
            }
            .padding()
            
//            Text("ViewModel is searching: \(viewModel.isSearching.description)")
//            SearchChildView()
        }
        
        //MARK: - .searchable modifier
        
        .searchable(
            text:  $viewModel.searchText,
            placement: .automatic,
            prompt: "Search Restaurants...")
        
        //MARK: - searchScopes modifier this is like filters
        
        .searchScopes($viewModel.searchScope, scopes: {
            ForEach(viewModel.allSearchScopes, id: \.self) { scope in
                Text(scope.title)
                    .tag(scope)
            }
        })
        
        //MARK: - searchSuggestions modifier
        
        .searchSuggestions({
            ForEach (viewModel.getSearchSuggestions(), id: \.self) { suggestion in
                Text(suggestion)
                    .searchCompletion(suggestion)
            }
            
            
            ForEach (viewModel.getRestaurandSuggestions(), id: \.self) { suggestion in
                NavigationLink(value: suggestion) {
                    Text(suggestion.title)
                }
            }
            
            
            
        })
        
        
        .navigationTitle("Restaurants")
        .task {
            await viewModel.loadRestaurants()
        }
        .navigationDestination(for: Restaurant.self) { restaurant in
            Text(restaurant.title.uppercased())
        }
    }
}


struct SearchChildView: View {
     
    @Environment (\.isSearching) private var isSearching
    
    var body: some View {
        Text("Child View is Searching \(isSearching.description)")
    }
}

//MARK: - Preview

#Preview {
    NavigationStack {
        SearchableBootcamp()
    }
}



//MARK: - View Extention

extension SearchableBootcamp {
    
    private func  restaurantRow(for restaurant: Restaurant) -> some View {
        VStack (alignment: .leading, spacing: 10){
            Text(restaurant.title)
                .font(.headline)
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.black.opacity(0.05))
        .tint(.primary)
    }
    
    
}
