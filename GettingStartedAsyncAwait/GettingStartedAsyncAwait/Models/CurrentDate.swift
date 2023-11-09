//
//  CurrentDate.swift
//  GettingStartedAsyncAwait
//
//  Created by Vishnu Prabhu Rama Chandran on 9/11/23.
//

import Foundation

struct CurrentDate: Decodable, Identifiable {
    let id = UUID()
    let date: String
    
    private enum CodingKeys: String, CodingKey {
        case date = "date"
    }
}
