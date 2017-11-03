//
//  ResourceMap.swift
//  Slide
//
//  Created by Jordan Kay on 11/2/17.
//  Copyright © 2017 Squareknot. All rights reserved.
//

import Emissary

public class ResourceMap<SizeType: Size> {
    fileprivate var data: [(ImageDisplaying, ImageResource<SizeType>)] = []
    
    public init() {}
    
    var imageDisplayers: [ImageDisplaying] {
        return data.map { $0.0 }
    }
}

public extension ImageDisplaying {
    func setImageURL<SizeType>(_ url: URL?, size: SizeType, using resourceMap: ResourceMap<SizeType>) {
        guard let url = url else { return }
        let resource = ImageResource(url: url, size: size)
        resourceMap.data.append((self, resource))
    }
}

extension ResourceMap: Sequence {
    public func makeIterator() -> AnyIterator<(ImageDisplaying, ImageResource<SizeType>)> {
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
