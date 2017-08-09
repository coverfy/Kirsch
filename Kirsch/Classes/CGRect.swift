//
//  CGRect.swift
//  Pods
//
//  Created by Josep Bordes Jové on 24/7/17.
//
//

import Foundation

extension CGRect {
    func topLeftZone() -> CGRect {
        return CGRect(x: 0 + self.minX, y: 0 + self.minY, width: self.width / 2, height: self.height / 2)
    }
    
    func bottomLeftZone() -> CGRect {
        return CGRect(x: self.width / 2 + self.minX, y: 0 + self.minY, width: self.width / 2, height: self.height / 2)
    }
    
    func topRightZone() -> CGRect {
        return CGRect(x: 0 + self.minX, y: self.height / 2 + self.minY, width: self.width / 2, height: self.height / 2)
    }
    
    func bottomRightZone() -> CGRect {
        return CGRect(x: self.width / 2 + self.minX, y: self.height / 2 + self.minY, width: self.width / 2, height: self.height / 2)
    }
    
    func rectangle() -> CSRectangle {
        let topLeft = CGPoint(x: self.minX, y: self.minY)
        let topRight = CGPoint(x: self.maxX, y: self.minY)
        let bottomLeft = CGPoint(x: self.minX, y: self.maxY)
        let bottomRight = CGPoint(x: self.maxX, y: self.maxY)
        
        return CSRectangle(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
    }
    
    func size() -> Float {
        return Float(self.height * self.width)
    }
    
    func interchangeHeightWidth() -> CGRect{
        return CGRect(x: self.minX, y: self.minY, width: self.height, height: self.width)
    }
}
