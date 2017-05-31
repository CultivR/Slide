//
//  RenderableBlock.swift
//  Slide
//
//  Created by Jordan Kay on 5/31/17.
//  Copyright © 2017 Squareknot. All rights reserved.
//

import Tangram

open class RenderableBlock: Block, Renderable {
    @IBInspectable public private(set) var templateColor: UIColor?
    @IBInspectable public private(set) var cornerRadius: CGFloat = 0
    @IBInspectable public private(set) var blendsWithBackground: Bool = false
    
    public var renderedView: RenderedImageView!
    
    // MARK: UIView
    @available(*, unavailable)
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: NSCoding
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
