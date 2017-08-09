//
//  CSPoint.swift
//  Pods
//
//  Created by Josep Bordes Jové on 24/7/17.
//
//

import Foundation

public enum CSImageFilter {
    case contrast
    case none
}

public enum CSImageOrientation {
    case vertical
    case horizontal
}

public enum CSVideoFrame {
    case normal
    case square
    case fullScreen
    case withBottomMargin
}

public enum CSErrors: String, Error {
    case noAvSessionAvailable = "The AVSession was not created properly"
    case cannotSetFocusMode = "The focus mode cannot be set"
    case cannotSetInput = "The Device Media Input cannot be configured properly"
}

public enum CSPointType {
    case topRight
    case topLeft
    case bottomRight
    case bottomLeft
}

public enum CSRectangleSize {
    case fullFrame
    case empty
}
