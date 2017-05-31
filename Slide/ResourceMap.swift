//
//  ResourceMap.swift
//  Slide
//
//  Created by Jordan Kay on 11/2/17.
//  Copyright © 2017 Squareknot. All rights reserved.
//

import Emissary

public struct ResourceMap<T: Size> {
    private var data: [(ImageDisplaying, ImageResource<T>)] = []
    
    public init() {}
    
    var imageDisplayers: [ImageDisplaying] {
        return data.map { $0.0 }
    }
}

public extension ResourceMap {
    mutating func add(_ resource: ImageResource<T>?, displayedBy displayer: ImageDisplaying) {
        guard let resource = resource else { return }
        data.append((displayer, resource))
    }
}

extension ResourceMap: Sequence {
    public func makeIterator() -> AnyIterator<(ImageDisplaying, ImageResource<T>)> {
        var index = 0
        return AnyIterator {
            if index < self.data.count {
                let object = self.data[index]
                index += 1
                return object
            }
            return nil
        }
    }
}
