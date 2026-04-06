//
//  AppModel.swift
//  thesis_visionpro_app
//
//  Created by Tegshbayar Batbayar on 29.11.25.
//

import SwiftUI

@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
}
