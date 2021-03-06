//
//  BaseFunctions.swift
//  EasyLayout
//
//  Created by Søren Møller Gade Hansen on 16/04/2019.
//  Copyright © 2019 Søren Møller Gade Hansen. All rights reserved.
//

import UIKit

extension UIView: PropertyStoring {
    /**
    
    Makes the object ready for snapping.
    
    - returns:
    An UIView object
    
    */
    @discardableResult
    public func exec() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        safeArea = false
        return self
    }
    
    /**
     
     Toggles if the view should take care of safe area.
     
     - returns:
     An UIView object
     
     */
    @discardableResult
    public func safe() -> Self {
        safeArea = !self.safeArea
        return self
    }
    
    // MARK: Base functions
    private func createXAxisLayoutConstraint(anchor: NSLayoutXAxisAnchor, equalTo viewAnchor: NSLayoutXAxisAnchor, offset: CGFloat) -> NSLayoutConstraint {
        return anchor.constraint(equalTo: viewAnchor, constant: offset)
    }
    
    private func createYAxisLayoutConstraint(anchor: NSLayoutYAxisAnchor, equalTo viewAnchor: NSLayoutYAxisAnchor, offset: CGFloat) -> NSLayoutConstraint {
        return anchor.constraint(equalTo: viewAnchor, constant: offset)
    }
    
    private func createDimensionLayoutConstraint(anchor: NSLayoutDimension, equalTo _viewAnchor: NSLayoutDimension?, value: CGFloat) -> NSLayoutConstraint {
        if let viewAnchor = _viewAnchor {
            return anchor.constraint(equalTo: viewAnchor)
        }
        return anchor.constraint(equalToConstant: value)
    }
    
    private func bindXAxis(anchor: NSLayoutXAxisAnchor, equalTo viewAnchor: NSLayoutXAxisAnchor, offset: CGFloat, view: UIView) {
        
        var safetyAnchor: NSLayoutXAxisAnchor = viewAnchor
        
        if safeArea {
            if let name = safetyAnchor.value(forKey: "name") as? String {
                if name == "leading" {
                    if #available(iOS 11.0, *) {
                        safetyAnchor = view.safeAreaLayoutGuide.leadingAnchor
                    }
                }
                else if name == "trailing" {
                    if #available(iOS 11.0, *) {
                        safetyAnchor = view.safeAreaLayoutGuide.trailingAnchor
                    }
                }
            }
        }
        snapAddConstraint(createXAxisLayoutConstraint(anchor: anchor, equalTo: safetyAnchor, offset: offset))
    }
    
    private func bindYAxis(anchor: NSLayoutYAxisAnchor, equalTo viewAnchor: NSLayoutYAxisAnchor, offset: CGFloat, view: UIView) {
        
        var safetyAnchor: NSLayoutYAxisAnchor = viewAnchor
        
        if safeArea {
            if let name = safetyAnchor.value(forKey: "name") as? String {
                if name == "top" {
                    if #available(iOS 11.0, *) {
                        safetyAnchor = view.safeAreaLayoutGuide.topAnchor
                    }
                }
                else if name == "bottom" {
                    if #available(iOS 11.0, *) {
                        safetyAnchor = view.safeAreaLayoutGuide.bottomAnchor
                    }
                }
            }
        }
        snapAddConstraint(createYAxisLayoutConstraint(anchor: anchor, equalTo: safetyAnchor, offset: offset))
    }
    
    private func bindDimension(anchor: NSLayoutDimension, equalTo viewAnchor: NSLayoutDimension?, value: CGFloat) {
        snapAddConstraint(createDimensionLayoutConstraint(anchor: anchor, equalTo: viewAnchor, value: value))
    }
    
    internal func bind(attribute: Attribute, to viewAttribute: Attribute, offset: CGFloat, view: UIView) {
        // As anchors are static, only check when developing
        #if DEBUG
            snapAttributeFilter(attribute, viewAttribute) { (message, valid) in
                if !valid {
                    assert(false, "Binding failed: \(message)")
                    return
                }
            }
        #endif
        
        switch attribute {
        case .width:
            if viewAttribute == .height {
                bindDimension(anchor: self.widthAnchor, equalTo: view.heightAnchor, value: offset)
            }
            else if viewAttribute == .width {
                bindDimension(anchor: self.widthAnchor, equalTo: view.widthAnchor, value: offset)
            }
            else {
                bindDimension(anchor: self.widthAnchor, equalTo: nil, value: offset)
            }
        case .height:
            if viewAttribute == .height {
                bindDimension(anchor: self.heightAnchor, equalTo: view.heightAnchor, value: offset)
            }
            else if viewAttribute == .width {
                bindDimension(anchor: self.heightAnchor, equalTo: view.widthAnchor, value: offset)
            }
            else {
                bindDimension(anchor: self.heightAnchor, equalTo: nil, value: offset)
            }
        case .left:
            if viewAttribute == .right {
                bindXAxis(anchor: self.leadingAnchor, equalTo: view.trailingAnchor, offset: offset, view: view)
            } else {
                bindXAxis(anchor: self.leadingAnchor, equalTo: view.leadingAnchor, offset: offset, view: view)
            }
        case .right:
            if viewAttribute == .right {
                bindXAxis(anchor: self.trailingAnchor, equalTo: view.trailingAnchor, offset: offset, view: view)
            } else {
                bindXAxis(anchor: self.trailingAnchor, equalTo: view.leadingAnchor, offset: offset, view: view)
            }
        case .top:
            if viewAttribute == .top {
                bindYAxis(anchor: self.topAnchor, equalTo: view.topAnchor, offset: offset, view: view)
            } else {
                bindYAxis(anchor: self.topAnchor, equalTo: view.bottomAnchor, offset: offset, view: view)
            }
        case .bottom:
            if viewAttribute == .top {
                bindYAxis(anchor: self.bottomAnchor, equalTo: view.topAnchor, offset: offset, view: view)
            } else {
                bindYAxis(anchor: self.bottomAnchor, equalTo: view.bottomAnchor, offset: offset, view: view)
            }
        case .centerX:
            if viewAttribute == .left {
                bindXAxis(anchor: self.centerXAnchor, equalTo: view.leadingAnchor, offset: offset, view: view)
            }
            else if viewAttribute == .right {
                bindXAxis(anchor: self.centerXAnchor, equalTo: view.trailingAnchor, offset: offset, view: view)
            }
            else {
                bindXAxis(anchor: self.centerXAnchor, equalTo: view.centerXAnchor, offset: offset, view: view)
            }
        case .centerY:
            if viewAttribute == .top {
                bindYAxis(anchor: self.centerYAnchor, equalTo: view.topAnchor, offset: offset, view: view)
            }
            else if viewAttribute == .bottom {
                bindYAxis(anchor: self.centerYAnchor, equalTo: view.bottomAnchor, offset: offset, view: view)
            }
            else {
                bindYAxis(anchor: self.centerYAnchor, equalTo: view.centerYAnchor, offset: offset, view: view)
            }
        case .none:
            assert(false, "Cannot bind an undefined anchor")
        }
    }
    
    // Remove constraints from object
    internal func deleteConstraint(_ constraint: NSLayoutConstraint) -> Bool {
        // Remove from custom array
        guard let index = snapConstraints.firstIndex(of: constraint) else { return false }
        snapConstraints.remove(at: index)
        
        // Deactivate constraint
        constraint.isActive = false
        return true
    }
    
    internal func snapAddConstraint(_ constraint: NSLayoutConstraint) {
        snapConstraints.append(constraint)
        constraint.isActive = true
    }
    
    internal func snapAttributeFilter(_ firstAttribute: Attribute, _ secondAttribute: Attribute, completion: (_ message: String, _ valid: Bool) -> ()) {
        // Check if dimension is valid
        if (firstAttribute.isDimension() && !secondAttribute.isDimension()) {
            completion("Cannot have different dimension attributes", false)
            return
        }
        
        // Check if x axis is valid
        if (firstAttribute.isXAxis() && !secondAttribute.isXAxis()) {
            completion("Cannot have different X-Axis attributes", false)
            return
        }
        
        // Check if y axis is valid
        if (firstAttribute.isYAxis() && !secondAttribute.isYAxis()) {
            completion("Cannot have diffent Y-Axis attributes", false)
            return
        }
        completion("", true)
    }
}
