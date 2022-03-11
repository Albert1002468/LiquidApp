//
//  AddTransaction.swift
//  LIQUID
//
//  Created by Alberto Dominguez Fernandez on 3/7/22.
//

import SwiftUI

struct AddTransaction: View {
    @ObservedObject var transactionData: TransactionModel
    @Environment(\.dismiss) private var dismiss
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        
        return formatter
    }()
    @State var paymentTypeArray = ["Income", "Expense"]
    @State var amount = 0.0
    @State var type = "Income"
    @State var date = Date.now
    @State var cat = ""
    @State var note = ""
    @State var desc = ""
    @State var typeIndex = 0
    @State var categoryIndex = 0
    var body: some View {
        NavigationView {
            Form {
                TextField("Enter amount", value: self.$amount, formatter: formatter)
                    .keyboardType(.decimalPad)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .foregroundColor(typeIndex == 0 ? .green : .black)
                
                Section {
                    Picker(selection: self.$typeIndex, label: Text("Select Transaction Type")) {
                        ForEach(0..<paymentTypeArray.count) {
                            Text(paymentTypeArray[$0])
                        }
                    }
                }
                
                Section {
                    Text("Description")
                    TextField("Enter Description", text: $desc)
                }
                
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section {
                    Picker(selection: $categoryIndex, label: Text("Select Category")) {
                        if (typeIndex == 0) {
                            ForEach(0..<transactionData.categoryIncomeArray.count){
                                Text(transactionData.categoryIncomeArray[$0])
                            }
                        }
                        else {
                            ForEach(0..<transactionData.categoryExpenseArray.count){
                                Text(transactionData.categoryExpenseArray[$0])
                            }
                        }
                    }
                }
                
                Section {
                    Text("Notes")
                    TextField("Enter Note", text: $note)
                }
                
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Save") {
                    AddNewTransaction()
                    transactionData.sortSections()
                    transactionData.filterSections(searchText: "")
                    dismiss()
                }
            }
        }
    }
    
    func AddNewTransaction() {
        
        var index = 0
        var found = false
        for arrayDate in transactionData.sections
        {
            if arrayDate.formatDate(date: arrayDate.date) == arrayDate.formatDate(date: date) {
                found = true
                break
            }
            index += 1
        }
        type = paymentTypeArray[typeIndex]
        if typeIndex == 0 {
            cat = transactionData.categoryIncomeArray[categoryIndex]
        }
        else {
            cat = transactionData.categoryExpenseArray[categoryIndex]
        }
        let singleTransaction = Transaction(type: type, date: date, description: desc, category: cat, notes: note, amount: amount)
        if found == true {
            transactionData.sections[index].transactionsOfMonth.append(singleTransaction)
        }
        else {
            transactionData.sections.append(Day(date: date, transactionsOfMonth: [singleTransaction]))
        }
    }
}

struct AddTransaction_Previews: PreviewProvider {
    static var previews: some View {
        AddTransaction(transactionData: TransactionModel())
    }
}
