//
//  Renderable.swift
//  Slide
//
//  Created by Jordan Kay on 5/31/17.
//  Copyright © 2017 Squareknot. All rights reserved.
//

import UIKit

public protocol Renderable where Self: UIView {
    var templateColor: UIColor? { get }
    var cornerRadius: CGFloat { get }
    var blendsWithBackground: Bool { get }
    var renderedView: RenderedImageView! { get set }
}

extension Renderable {
    mutating func prepare(with key: String) {
        guard renderedView == nil else { return }
        
        backgroundColor = templateColor ?? .clear
        renderedView = RenderedImageView(view: self)
        superview?.addSubview(renderedView)
        removeFromSuperview()
        
        let views = controls + highlightViews
        let constraints = views.flatMap { a in
            views.flatMap { b in
                self.constraints.filter { $0.firstItem === a && $0.secondItem === b || $0.firstItem === b && $0.secondItem === a }
            }
        }
        for view in views {
            let constraints = constraintsByReplacingTopLevelContainer(with: renderedView, affecting: view)
            renderedView.addSubview(view)
            renderedView.addConstraints(constraints)
            view.isHidden = view.alpha > 0
        }
        renderedView.addConstraints(constraints)
    }
    
    func reset(with key: String) {
        renderedView.isTransitioning = false
        renderedView.renderKey = key
        renderedView.updateRendering(for: key, animated: false)
    }
    
    func cancelRender() {
        Renderer.cancelRendering(for: self)
    }
}

extension UIView {
    var controls: [UIView] {
        return subviews.filter { $0 is UIControl || $0 is UITextView }
    }
}

private extension UIView {
    var highlightViews: [UIView] {
        return [(self as? Highlightable)?.highlightView].flatMap { $0 }
    }
}
