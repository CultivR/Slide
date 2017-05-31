//
//  Renderer.swift
//  Tangram
//
//  Created by Jordan Kay on 12/22/15.
//  Copyright © 2015 Squareknot. All rights reserved.
//

import Emissary
import OperationStack
import SwiftTask
import Tangram

typealias RenderTask = Task<Float, UIImage, RenderError>
typealias ProcessTask = Task<(ImageDisplaying, UIImage), Void, Reason>

public struct Renderer {
    static let renderCache = Cache<String, UIImage>(capacity: .cacheCapacity)
    
    static private var renderTasks = NSMapTable<UIView, RenderTask>.weakToStrongObjects()
    static private var renderStack = OperationStack(maxConcurrentOperationCount: .operationCount)
    static private var processTasks = NSMapTable<UIView, ProcessTask>.weakToStrongObjects()
    static private var renderedKeys = Set<String>()
    static private var rerenderKeys = Set<String>()
    static private var animatingKeys: [String: Bool] = [:]
    static private var deferredAction: (() -> Void)?

    static func render<T>(_ view: UIView & Renderable, key: String, rerenderKey: String?, resourceMap: ResourceMap<T>, update: @escaping () -> Void = {}) {
        var view = view
        view.cancelRender()
        view.prepare(with: key)
        view.reset(with: key)
        restartProcessing(for: resourceMap)
        process(view, key: key, resourceMap: resourceMap, update: update)
        
        if let rerenderKey = rerenderKey, rerenderKeys.contains(rerenderKey) {
            renderedKeys.remove(key)
            rerenderKeys.remove(rerenderKey)
            performRender(view, key: key, resourceMap: resourceMap, update: update)
        } else if !renderedKeys.contains(key) {
            performRender(view, key: key, resourceMap: resourceMap, update: update)
        }
    }
    
    static func cancelRendering(for view: UIView & Renderable) {
        renderTasks.object(forKey: view)?.cancel()
    }
}

public extension Renderer {
    static func setAnimating(_ animating: Bool, for key: String) {
        if animating {
            animatingKeys[key] = true
        } else {
            animatingKeys[key] = false
            if !isAnimating {
                deferredAction?()
                deferredAction = nil
            }
        }
    }
    
    static func performAfterAnimations(_ action: @escaping () -> Void) {
        if isAnimating {
            deferredAction = action
        } else {
            action()
        }
    }
    
    static func setNeedsRendering<T: Hashable>(for item: T) {
        let rerenderKey = "\(item.hashValue)"
        setNeedsRendering(for: rerenderKey)
    }
}

private extension Renderer {
    static var isAnimating: Bool {
        return animatingKeys.values.reduce(false) { $0 || $1 }
    }
    
    static func setNeedsRendering(for key: String) {
        rerenderKeys.insert(key)
    }
    
    static func restartProcessing<T>(for resourceMap: ResourceMap<T>) {
        for (imageDisplaying, resource) in resourceMap {
            let image = cachedImage(forURL: resource.url)
            imageDisplaying.setImage(image, update: false, animated: false)
        }
    }
    
    static func performRender<T>(_ view: UIView & Renderable, key: String, resourceMap: ResourceMap<T>, update: @escaping () -> Void = {}) {
        view.cancelRender()
        renderTasks.setObject(renderTask(for: view, with: key, update: update), forKey: view)
        renderTasks.object(forKey: view)!.success { [weak view] rendering in
            renderCache[key] = rendering
            view?.renderedView.updateRendering(for: key, animated: true)
            
            let rendered = resourceMap.imageDisplayers.reduce(true) { $0 && $1.image != nil }
            if rendered {
                renderedKeys.insert(key)
            }
        }
    }
    
    static func process<T>(_ view: UIView & Renderable, key: String, resourceMap: ResourceMap<T>, update: @escaping () -> Void = {}) {
        processTasks.object(forKey: view)?.cancel()
        processTasks.setObject(processTask(for: key, resourceMap: resourceMap), forKey: view)
        processTasks.object(forKey: view)!.progress { [weak view] _, progress in
            guard let view = view else { return }
            let (imageDisplaying, image) = progress
            imageDisplaying.setImage(image, update: false, animated: false)
            performRender(view, key: key, resourceMap: resourceMap, update: update)
        }
    }
    
    static func renderTask(for view: UIView & Renderable, with key: String, update: @escaping () -> Void = {}) -> RenderTask {
        return Task { [weak view] progress, fulfill, reject, configure in
            var isCancelled = false
            configure.cancel = { isCancelled = true }
            guard let view = view else { return }
            renderStack.add {
                guard !isCancelled else { return }
                let rendering = backgroundRender(view, key: key, update: update)
                DispatchQueue.main.async {
                    UIView.setAnimationsEnabled(true)
                    fulfill(rendering)
                }
            }
        }
    }
    
    static func processTask<T>(for key: String, resourceMap: ResourceMap<T>) -> ProcessTask {
        return Task { progress, fulfill, reject, configure in
            for (imageDisplaying, resource) in resourceMap {
                let url = resource.url
                guard imageDisplaying.image == nil else { continue }
                fetchCachedImage(forURL: url).success { image in
                    progress((imageDisplaying, image))
                    cacheImage(image, forURL: url, toDisk: false)
                }.failure { _ in
                    let _ = request(resource).success { image in
                        progress((imageDisplaying, image))
                        cacheImage(image, forURL: url, toDisk: true)
                    }
                }
            }
        }
    }
    
    static func backgroundRender(_ view: UIView & Renderable, key: String, update: () -> Void = {}) -> UIImage {
        update()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        let rect = view.bounds
        let subviews = (view as? Shape)?.backgroundView.subviews ?? view.subviews
        let backgroundColor = view.backgroundColor
        let opaque = !view.blendsWithBackground
        return UIImage.drawing(size: rect.size, opaque: opaque) { context in
            context.interpolationQuality = .none
            if opaque {
                backgroundColor?.set()
                UIRectFill(rect)
            }
            subviews.forEach { render($0, in: context) }
        }
    }
    
    static func render(_ view: UIView, in context: CGContext) {
        let (x, y) = (view.frame.minX, view.frame.minY)
        context.translateBy(x: x, y: y)
        (view as? Blur)?.image = UIGraphicsGetImageFromCurrentImageContext()
        prepareToRender(view)
        view.layer.render(in: context)
        context.translateBy(x: -x, y: -y)
    }
    
    static func prepareToRender(_ view: UIView) {
        (view as? Shape)?.updateBackgroundImage()
        view.subviews.forEach { prepareToRender($0) }
    }
}

private extension Int {
    static let operationCount = 6
    static let cacheCapacity = 500
}

enum RenderError: Error {}
