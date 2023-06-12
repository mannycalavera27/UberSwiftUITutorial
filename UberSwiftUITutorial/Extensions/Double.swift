//
//  Double.swift
//  UberSwiftUITutorial
//
//  Created by Tiziano Cialfi on 12/06/23.
//

import Foundation

extension Double {
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    func toCurrency() -> String {
        currencyFormatter.string(for: self) ?? ""
    }
}
