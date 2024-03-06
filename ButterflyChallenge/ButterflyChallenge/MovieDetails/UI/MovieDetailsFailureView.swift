//
//  MovieDetailsFailureView.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import SwiftUI

struct MovieDetailsFailureView: View {
    enum Constants {
        static let contentStackSpacing = CGFloat(16)
        static let textsStackSpacing = CGFloat(8)
        static let imageSize = CGFloat(120)
    }
    
    enum ViewIdentifiers: String {
        case icon = "icon-view"
        case title = "title-label"
        case message = "message-label"
        case button = "retry-button"
    }
    
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: Constants.contentStackSpacing) {
            Image(systemName: "poweroutlet.type.b")
                .resizable()
                .foregroundStyle(Color.secondary)
                .frame(width: Constants.imageSize, height: Constants.imageSize)
                .accessibilityIdentifier(ViewIdentifiers.icon.rawValue)
            
            VStack(spacing: Constants.textsStackSpacing) {
                Text("Ops!")
                    .font(.title)
                    .accessibilityIdentifier(ViewIdentifiers.title.rawValue)
                Text("Seems that something went wrong")
                    .font(.title3)
                    .accessibilityIdentifier(ViewIdentifiers.message.rawValue)
            }
            
            Button {
                retryAction()
            } label: {
                Text("Try again")
            }.accessibilityIdentifier(ViewIdentifiers.button.rawValue)
        }
    }
}

#Preview {
    MovieDetailsFailureView(retryAction: { })
}
