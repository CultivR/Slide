//
//  RenderableDisplayed.swift
//  Slide
//
//  Created by Jordan Kay on 10/31/17.
//  Copyright © 2017 Squareknot. All rights reserved.
//

import Emissary
import Mensa

public protocol RenderableDisplayed: Renderable, Displayed where Item: Hashable {
    associatedtype T: Size
    
    func resourceMap(for item: Item) -> ResourceMap<T>
}

public extension RenderableDisplayed {
    func resourceMap(for item: Item) -> ResourceMap<T> {
        return ResourceMap<T>()
    }
    
    func render(displaying item: Item, with variant: DisplayVariant, update: @escaping () -> Void = {}) {
        let resourceMap = self.resourceMap(for: item)
        let (key, rerenderKey) = type(of: self).info(for: item, variant: variant)
        Renderer.render(self, key: key, rerenderKey: rerenderKey, resourceMap: resourceMap, update: update)
    }
    
    static func info(for item: Item, variant: DisplayVariant) -> (String, String) {
        let rerenderKey = "\(item.hashValue)"
        let key = "\(rerenderKey)\(self)\(variant.rawValue)"
        return (key, rerenderKey)
    }
}
