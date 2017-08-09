//
//  CSPoint.swift
//  Pods
//
//  Created by Josep Bordes Jové on 24/7/17.
//
//

import Foundation

struct CSPoint: Equatable {

    var point: CGPoint
    let type: CSPointType
    
    init(point: CGPoint, type: CSPointType) {
        self.point = point
        self.type = type
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs: CSPoint, rhs: CSPoint) -> Bool {
        if lhs.point == rhs.point && lhs.type == rhs.type {
            return true
        }
        
        return false
    }
    
    func isInside(_ frame: CGRect) -> Bool {
        
        switch self.type {
        case .topLeft:
            return self.point.isInside(frame.topRightZone())
            
        case .topRight:
            return self.point.isInside(frame.bottomRightZone())
            
        case .bottomLeft:
            return self.point.isInside(frame.topLeftZone())
            
        case .bottomRight:
            return self.point.isInside(frame.bottomLeftZone())
        }
        
    }
    
    func absoluteMovementFrom(point: CSPoint) -> Float {
        let xMovement: Float = abs(Float(self.point.x - point.point.x))
        let yMovement: Float = abs(Float(self.point.y - point.point.y))
        
        return Float(xMovement * xMovement + yMovement * yMovement).squareRoot()
    }
    
}
