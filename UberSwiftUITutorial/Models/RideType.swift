//
//  RideType.swift
//  UberSwiftUITutorial
//
//  Created by Tiziano Cialfi on 12/06/23.
//

import Foundation

enum RideType: Int, CaseIterable, Identifiable {
    case uberX
    case black
    case uberXL
    
    var id: Int {
        rawValue
    }
    
    var description: String {
        switch self {
            case .uberX: return "UberX"
            case .black: return "UberBlack"
            case .uberXL: return "UberXL"
        }
    }
    
    var imageName: String {
        switch self {
            case .uberX: return "uber-x"
            case .black: return "uber-x"
            case .uberXL: return "uber-x"
        }
    }
    
    var baseFare: Double {
        switch self {
            case .uberX: return 5
            case .black: return 20
            case .uberXL: return 10
        }
    }
    
    func computePrice(for distanceInMeters: Double) -> Double {
        let distanceInMiles = distanceInMeters / 1600
        switch self {
            case .uberX: return distanceInMiles * 1.5 + baseFare
            case .black: return distanceInMiles * 2.0 + baseFare
            case .uberXL: return distanceInMiles * 1.75 + baseFare
        }
    }
}
