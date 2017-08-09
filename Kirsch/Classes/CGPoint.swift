//
//  CGPoint.swift
//  Pods
//
//  Created by Josep Bordes Jové on 24/7/17.
//
//

import Foundation

extension CGPoint {
    
    func isInside(_ frame: CGRect) -> Bool {
        if self.x <= frame.maxX && self.x >= frame.minX && self.y <= frame.maxY && self.y >= frame.minY {
            return true
        }
        
        return false
    }
    
}
