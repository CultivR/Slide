//
//  RenderedImageView.swift
//  Slide
//
//  Created by Jordan Kay on 5/31/17.
//  Copyright © 2017 Squareknot. All rights reserved.
//

import UIKit

public final class RenderedImageView: UIImageView {
    var renderKey: String?
    var nextAnimations: [(() -> Void)] = []
    
    var isTransitioning = false {
        didSet {
            guard let key = renderKey else { return }
            Renderer.setAnimating(isTransitioning, for: key)
        }
    }
    
    private weak var view: UIView?
    
    init(view: UIView & Renderable) {
        self.view = view
        super.init(frame: view.frame)
        backgroundColor = view.backgroundColor
        
        if view.cornerRadius > 0 {
            layer.masksToBounds = true
            layer.cornerRadius = view.cornerRadius
        }
    }
    
    deinit {
        isTransitioning = false
    }
    
    func updateRendering(for key: String, animated: Bool) {
        let rendering = Renderer.renderCache[key]
        if animated {
            let animation = { [weak self] in
                guard let `self` = self else { return }
                let duration: TimeInterval = 0.3
                
                self.isTransitioning = true
                UIView.transition(with: self, duration: duration, options: [.transitionCrossDissolve, .allowUserInteraction], animations: { [weak self] in
                    guard let `self` = self else { return }
                    self.image = rendering
                    self.showControls()
                }, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    if let nextAnimation = self.nextAnimations.first {
                        nextAnimation()
                        let _ = self.nextAnimations.remove(at: 0)
                    } else {
                        self.isTransitioning = false
                    }
                }
            }
            if isTransitioning {
                nextAnimations.append(animation)
            } else {
                animation()
            }
        } else {
            image = rendering
            if rendering != nil {
                showControls()
            }
        }
    }
    
    // MARK: UIResponder
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view?.touchesBegan(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: UIImageView
    override public var isUserInteractionEnabled: Bool {
        set {}
        get { return true }
    }
    
    // MARK: NSCoder
    required public init?(coder: NSCoder) {
        fatalError()
    }
}

private extension RenderedImageView {
    func showControls() {
        controls.forEach { $0.isHidden = false }
    }
}
