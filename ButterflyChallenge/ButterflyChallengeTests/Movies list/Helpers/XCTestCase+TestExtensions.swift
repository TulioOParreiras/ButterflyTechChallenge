//
//  MoviesListTests+Helpers.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 1/3/2024.
//

import XCTest

extension XCTestCase {
    
    func anyImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    func anyError() -> Error {
        NSError(domain: "an error", code: 0)
    }
    
    func trackForMemoryLeaks(_ object: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "\(String(describing: object)) was expected to be removed from memory, possible retain cycle", file: file, line: line)
        }
    }
    
}
