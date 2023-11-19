//
//  ContentView.swift
//  foo
//
//  Created by Mohammad Azam on 7/23/21.
//

import SwiftUI

enum AHBankError: Error {
    case insufficientFunds(Double)
}

actor AHBankAccount {
    
    let accountNumber: Int
    var balance: Double
    
    init(accountNumber: Int, balance: Double) {
        self.accountNumber = accountNumber
        self.balance = balance
    }
    
    nonisolated func getCurrentAPR() -> Double {
        return 0.2
    }
    
    func deposit(_ amount: Double) {
        balance += amount
    }
    
    func transfer(amount: Double, to other: AHBankAccount) async throws {
        if amount > balance {
            throw AHBankError.insufficientFunds(amount)
        }
        
        balance -= amount
        await other.deposit(amount)
        
        print(other.accountNumber)
        print("Current Account: \(balance), Other Account: \(await other.balance)")
    }
}


struct ActorHopingView: View {
    
    var body: some View {
        Button {
            
            let bankAccount = AHBankAccount(accountNumber: 123, balance: 500)
            let otherAccount = AHBankAccount(accountNumber: 456, balance: 100)
            
            let _ = bankAccount.getCurrentAPR()
            
            DispatchQueue.concurrentPerform(iterations: 100) { _ in
                Task {
                    try? await bankAccount.transfer(amount: 300, to: otherAccount)
                }
            }
            
        } label: {
            Text("Transfer")
        }

    }
}
