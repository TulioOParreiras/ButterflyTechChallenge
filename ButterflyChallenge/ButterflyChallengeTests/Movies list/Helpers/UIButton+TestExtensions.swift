//
//  UIButton+TestExtensions.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
