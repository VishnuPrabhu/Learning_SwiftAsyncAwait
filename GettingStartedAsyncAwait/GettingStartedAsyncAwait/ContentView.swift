//
//  ContentView.swift
//  GettingStartedAsyncAwait
//
//  Created by Mohammad Azam on 7/9/21.
//

import SwiftUI

struct CurrentDate: Decodable, Identifiable {
    let id = UUID()
    let date: String
    
    private enum CodingKeys: String, CodingKey {
        case date = "date"
    }
}

struct ContentView: View {
    
    @State private var currentDates: [CurrentDate] = []
    
    var body: some View {
        NavigationView {
            List(currentDates) { now in
                Text("\(now.date)")
            }
            .listStyle(.plain)
            .navigationTitle("Dates")
            .navigationBarItems(trailing: Button(action: {
                Task {
                    await populateDate()
                }
            }, label: {
                Image(systemName: "arrow.clockwise.circle")
            }))
            .task {
                await populateDate()
            }
        }
    }
    
    private func getDate() async throws -> CurrentDate? {
        guard let url = URL(string: "https://ember-sparkly-rule.glitch.me/current-date") else {
            fatalError()
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try? JSONDecoder().decode(CurrentDate.self, from: data)
    }
    
    private func populateDate() async {
        do {
            if let date = try await getDate() {
                currentDates.append(date)
            }
        } catch {
            print(error)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
