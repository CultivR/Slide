//
//  Highlightable.swift
//  Slide
//
//  Created by Jordan Kay on 9/1/16.
//  Copyright © 2016 Squareknot. All rights reserved.
//

import Lilt
import Mensa

protocol Highlightable where Self: UIView {
    var highlightView: UIView? { get }
    func setHighlighted(_ highlighted: Bool, animated: Bool)
}

extension Highlightable {
    func setHighlighted(_ highlighted: Bool, animated: Bool) {
        guard let highlightView = highlightView else { return }
        
        let highlight = {
            highlightView.alpha = highlighted ? 1 : 0
        }
        if highlighted {
            highlightView.alpha = 0
        }
        if animated {
            Lilt.animate(animations: highlight)
        } else {
            highlight()
        }
    }
}

extension ItemDisplaying where Self: UIViewController, View: Highlightable {
    func setItemHighlighted(_ item: Item, highlighted: Bool, animated: Bool) {
        view.setHighlighted(highlighted, animated: animated)
    }
}
