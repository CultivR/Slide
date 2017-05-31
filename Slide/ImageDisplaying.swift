//
//  ImageDisplaying.swift
//  Slide
//
//  Created by Jordan Kay on 6/2/17.
//  Copyright © 2017 Squareknot. All rights reserved.
//

import Emissary
import Tangram

public extension Shape {
    func setImage(_ image: UIImage?, update: Bool) {
        setImage(image, update: update, animated: false)
    }
}

extension Shape: ImageDisplaying {
    public func setImage(_ image: UIImage?, update: Bool, animated: Bool) {
        if update {
            backgroundImage = image
        } else {
            storedBackgroundImage = image
        }
    }
}
