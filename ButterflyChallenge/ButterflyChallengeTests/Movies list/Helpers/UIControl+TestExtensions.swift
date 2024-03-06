//
//  UIControl+TestExtensions.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
