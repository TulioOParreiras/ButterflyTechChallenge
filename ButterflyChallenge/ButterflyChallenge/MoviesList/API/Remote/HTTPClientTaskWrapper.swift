//
//  HTTPClientTaskWrapper.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

final class HTTPClientTaskWrapper<Result>: DataLoaderTask {
    private var completion: ((Result) -> Void)?
    
    var wrapped: HTTPClientTask?
    
    init(_ completion: @escaping (Result) -> Void) {
        self.completion = completion
    }
    
    func complete(with result: Result) {
        completion?(result)
    }
    
    func cancel() {
        preventFurtherCompletions()
        wrapped?.cancel()
        wrapped = nil
    }
    
    private func preventFurtherCompletions() {
        completion = nil
    }
}
