//
//  MovieDetailsFailureView.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import SwiftUI

struct MovieDetailsFailureView: View {
    enum ViewIdentifiers: String {
        case title = "title-label"
        case button = "retry-button"
    }
    
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Seems something went wrong").accessibilityIdentifier(ViewIdentifiers.title.rawValue)
            Button {
                retryAction()
            } label: {
                Text("Try again")
            }.accessibilityIdentifier(ViewIdentifiers.button.rawValue)
        }
    }
}
