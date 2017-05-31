//
//  RenderableView.swift
//  Slide
//
//  Created by Jordan Kay on 5/31/17.
//  Copyright © 2017 Squareknot. All rights reserved.
//

import Tangram
import UIKit

@IBDesignable open class RenderableView: UIView, Renderable {
    @IBInspectable public private(set) var templateColor: UIColor?
    @IBInspectable public private(set) var cornerRadius: CGFloat = 0
    @IBInspectable public private(set) var blendsWithBackground: Bool = false
    
    public var renderedView: RenderedImageView!
    
    @available(*, unavailable)
    init() {
        fatalError()
    }
    
    // MARK: UIView
    @available(*, unavailable)
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        backgroundColor = templateColor
        if cornerRadius > 0 {
            layer.masksToBounds = true
            layer.cornerRadius = cornerRadius
        }
    }
    
    // MARK: NSCoding
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
