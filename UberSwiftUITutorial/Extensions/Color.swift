//
//  Color.swift
//  UberSwiftUITutorial
//
//  Created by Tiziano Cialfi on 12/06/23.
//

import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let backgroundColor = Color("backgroundColor")
    let secondaryBackgroundColor = Color("secondaryBackgroundColor")
    let primaryTextColor = Color("primaryTextColor")
}
