//
//  CSPoint.swift
//  Pods
//
//  Created by Josep Bordes Jové on 24/7/17.
//
//

import UIKit
import CoreImage

extension CIImage {
    
    func getImageOrientationForDevice() -> UIImageOrientation {
        
        switch UIDevice.current.orientation {
        case .portrait:
            return UIImageOrientation.right
            
        case .landscapeLeft:
            return UIImageOrientation.up
            
        case .landscapeRight:
            return UIImageOrientation.down
            
        case .portraitUpsideDown:
            return UIImageOrientation.left
            
        default:
            return UIImageOrientation.up
        }
    }
    
    func correctImageOrientation(forOrientation imageOrientation: CSImageOrientation) -> UIImage? {        
        let height = self.extent.size.height
        let width = self.extent.size.width
        var size = CGSize(width: width, height: height)
        var rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        switch imageOrientation {
        case .horizontal:
            if height > width {
                size = CGSize(width: height, height: width)
                rect = CGRect(x: 0, y: 0, width: height, height: width)
            }
            
        case .vertical:
            if height < width {
                size = CGSize(width: height, height: width)
                rect = CGRect(x: 0, y: 0, width: height, height: width)
            }
            
        }
        
        UIGraphicsBeginImageContext(size)
        
        var image: UIImage? = UIImage(ciImage: self, scale: 1, orientation: .right)
        image?.draw(in: rect)
        image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func correctImageOrientation(fromOrientation inputOrientation: UIImageOrientation) -> UIImage? {
        var orientation: UIImageOrientation? = nil
        
        switch inputOrientation {
        case .down:
            orientation = UIImageOrientation.left
            
        case .left:
            orientation = UIImageOrientation.up
            
        case .up:
            orientation = UIImageOrientation.right
            
        case .right:
            orientation = UIImageOrientation.down
            
        default:
            orientation = UIImageOrientation.up
        }
        
        let height = self.extent.size.height
        let width = self.extent.size.width
        var size = CGSize(width: width, height: height)
        var rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        if height < width {
            size = CGSize(width: height, height: width)
            rect = CGRect(x: 0, y: 0, width: height, height: width)
        }
        
        UIGraphicsBeginImageContext(size)
        
        var image: UIImage? = UIImage(ciImage: self, scale: 1, orientation: orientation!)
        image?.draw(in: rect)
        image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
                
        return image
    }
    
    func filterImageUsingContrastFilter() -> CIImage? {
        guard let imageFiltered: CIFilter = CIFilter(name: kCIColorControls, withInputParameters:
            [
                kCIInputImageKey: self,
                kCIInputBrightnessKey: 0.0,
                kCIInputContrastKey: 1.4,
                kCIInputSaturationKey: 0.0
            ]) else { return nil }
        
        return imageFiltered.outputImage
    }
    
    func correctPerspective(withRectangle rectangle: CSRectangle) -> CIImage {
        let rectangleCoordinates = [
            kCIInputTopLeft: CIVector(cgPoint: rectangle.topLeft.point),
            kCIInputTopRight: CIVector(cgPoint: rectangle.topRight.point),
            kCIInputBottomLeft: CIVector(cgPoint: rectangle.bottomLeft.point),
            kCIInputBottomRight: CIVector(cgPoint: rectangle.bottomRight.point)
        ]
        
        return self.applyingFilter(kCIPerspectiveCorrection, withInputParameters: rectangleCoordinates)
    }
    
    // MARK: - Crop Methods
    
    func cropBordersWith(margin: CGFloat) -> CIImage {
        let original = self.extent
        let rect = CGRect(
            x: original.origin.x + margin,
            y: original.origin.y + margin,
            width: original.size.width-2*margin,
            height: original.size.height-2*margin)
        
        return self.cropping(to: rect)
    }
    
    func cropWithColorContrast(withRectangle rectangle: CSRectangle, preferredOrientation orientation: CSImageOrientation) -> UIImage? {
        guard var image = self.filterImageUsingContrastFilter() else { return UIImage() }
        image = image.cropBordersWith(margin: 1)
        
        if !rectangle.isEmpty() {
            image = image.correctPerspective(withRectangle: rectangle)
        }
        
        return image.correctImageOrientation(forOrientation: orientation)
    }
    
    func crop(withRectangle rectangle: CSRectangle, preferredOrientation orientation: CSImageOrientation) -> UIImage? {
        var image = self.cropBordersWith(margin: 1)
        
        if !rectangle.isEmpty() {
            image = image.correctPerspective(withRectangle: rectangle)
        }
        
        return image.correctImageOrientation(forOrientation: orientation)
    }
    
    func noCropWithColorContrast(preferredOrientation orientation: CSImageOrientation) -> UIImage? {
        guard var image = self.filterImageUsingContrastFilter() else { return UIImage() }
        image = image.cropBordersWith(margin: 15)
        
        return image.correctImageOrientation(forOrientation: orientation)
    }
}
