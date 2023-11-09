//
//  NewsSourceListViewModel.swift
//  NewsApp
//
//  Created by Mohammad Azam on 6/30/21.
//

import Foundation

@MainActor
class NewsSourceListViewModel: ObservableObject {
    
    @Published var newsSources: [NewsSourceViewModel] = []
    
    private let service = Webservice()
    
    func getSources() async {
        do {
            let news = try await service.fetchSources(url: Constants.Urls.sources)
            self.newsSources = news.map(NewsSourceViewModel.init)
        } catch {
            print(error)
        }
    }
}

struct NewsSourceViewModel {
    
    fileprivate var newsSource: NewsSource
    
    var id: String {
        newsSource.id
    }
    
    var name: String {
        newsSource.name
    }
    
    var description: String {
        newsSource.description
    }
    
    static var `default`: NewsSourceViewModel {
        let newsSource = NewsSource(id: "abc-news", name: "ABC News", description: "This is ABC news")
        return NewsSourceViewModel(newsSource: newsSource)
    }
}
