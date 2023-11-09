//
//  CurrentDateListViewModel.swift
//  GettingStartedAsyncAwait
//
//  Created by Vishnu Prabhu Rama Chandran on 9/11/23.
//

import Foundation

@MainActor
class CurrentDateListViewModel: ObservableObject {
    @Published var list: [CurrentDateViewModel] = []
    
    func populateDates() async {
        do {
            if let date = try await WebService().getDate() {
                let currDateVM = CurrentDateViewModel(currDate: date)
                list.append(currDateVM)
            }
        } catch {
            print(error)
        }
    }
}

internal struct CurrentDateViewModel {
    let currDate: CurrentDate
    
    var id: String {
        currDate.id.uuidString
    }
    
    var date: String {
        currDate.date
    }
}
