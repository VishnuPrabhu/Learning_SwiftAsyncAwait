import UIKit

enum NetworkError: Error {
    case badUrl
    case decodingError
}

struct CreditScore: Decodable {
    let score: Int
}

struct Constants {
    struct Urls {
        static func equifax(userId: Int) -> URL? {
            return URL(string: "https://ember-sparkly-rule.glitch.me/equifax/credit-score/\(userId)")
        }
        
        static func experian(userId: Int) -> URL? {
            return URL(string: "https://ember-sparkly-rule.glitch.me/experian/credit-score/\(userId)")
        }
        
    }
}

func calculateAPR(creditScores: [CreditScore]) -> Double {
    
    let sum = creditScores.reduce(0) { next, credit in
        return next + credit.score
    }
    // calculate the APR based on the scores
    return Double((sum/creditScores.count)/100)
}

func getAPR(userId: Int) async throws -> Double {
    
    if (userId % 2 == 0) {
        throw NetworkError.badUrl
    }
    
    guard let equifaxUrl = Constants.Urls.equifax(userId: userId),
          let experianUrl = Constants.Urls.experian(userId: userId) else {
        throw NetworkError.badUrl
    }
    func calculateAPR(creditScores: [CreditScore]) -> Double {
        
        let sum = creditScores.reduce(0) { next, credit in
            return next + credit.score
        }
        // calculate the APR based on the scores
        return Double((sum/creditScores.count)/100)
    }
    async let (equifaxData, _) =  URLSession.shared.data(from: equifaxUrl)
    async let (experianData, _) =  URLSession.shared.data(from: experianUrl)
    
    let equifaxCreditScore = try JSONDecoder().decode(CreditScore.self, from: try await equifaxData)
    let experianCreditScore = try JSONDecoder().decode(CreditScore.self, from: try await experianData)
    
    return calculateAPR(creditScores: [equifaxCreditScore, experianCreditScore])
}

let ids = [1,2,3,4,5]
var invalidIds: [Int] = []
/*Task {
//    do {
        for id in ids {
            do {
                try Task.checkCancellation()
                let result = try await getAPR(userId: id)
                print(result)
            } catch {
                print(error)
                invalidIds.append(id)
            }
        }
        print("invalidIds \(invalidIds)")
        print("end")
//    } catch {
//        print("1end")
//    }
//    print("2end")
}
print("hello")*/

Task {
    let group = try await withTaskGroup(of: Void.self) { group in
        group.async {
            await getAPR(userId: 1)
        }
    }
    for await g in group {
        print(g)
    }
}
