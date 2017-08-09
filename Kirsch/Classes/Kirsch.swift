//
//  CSPoint.swift
//  Pods
//
//  Created by Josep Bordes Jové on 24/7/17.
//
//

import UIKit
import GLKit
import AVFoundation
import CoreMedia
import CoreImage
import OpenGLES
import QuartzCore

public protocol KirschDelegate: class {
    func getCapturedImageFiltered(_ image: UIImage?)
    func getCapturingProgress(_ progress: Float?)
}

public class Kirsch: NSObject {
    
    private var captureProgress: Float = -50 {
        didSet {
            delegate?.getCapturingProgress(self.captureProgress * 2 / 100)
        }
    }
    
    public var isBlackFilterActivated = false {
        didSet {
            self.captureProgress = -50
        }
    }
    
    public var isFlashActive = false {
        didSet {
            toggleFlash()
        }
    }
    
    private var squareDetectionCounter = 0 {
        didSet {
            if squareDetectionCounter >= 4 {
                detectedRectangle = CSRectangle(rectangleType: .empty)
            }
        }
    }
    
    private var detector: CIDetector?
    private var avSession: AVCaptureSession?
    fileprivate var applyFilter: ((CIImage) -> CIImage?)?
    
    private var detectedRectangle = CSRectangle(rectangleType: .empty)
    
    private let ratio: Float
    private let minRatio: Float
    private let maxRatio: Float
    private let superViewFrame: CGRect
    
    fileprivate var sessionQueue: DispatchQueue
    fileprivate var videoDisplayView: GLKView
    fileprivate var videoDisplayViewBounds: CGRect
    fileprivate var renderContext: CIContext
    fileprivate var currentImage: CIImage
    
    public weak var delegate: KirschDelegate?
    
    public init(superview: UIView, videoFrameOption: CSVideoFrame, applyFilterCallback: ((CIImage) -> CIImage?)?, ratio: Float) {
        let cameraFrame = Kirsch.calculateFrameForScreenOption(videoFrameOption, superview.frame)
        
        self.superViewFrame = superview.frame
        
        self.ratio = ratio
        self.minRatio = ratio - 0.2
        self.maxRatio = ratio + 0.2
        self.applyFilter = applyFilterCallback
        
        self.videoDisplayView = GLKView(frame: cameraFrame, context: EAGLContext(api: .openGLES2))
        self.videoDisplayView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        self.videoDisplayView.bindDrawable()
        
        self.renderContext = CIContext(eaglContext: videoDisplayView.context)

        self.videoDisplayViewBounds = CGRect(x: 0, y: 0, width: videoDisplayView.drawableWidth, height: videoDisplayView.drawableHeight)
        
        self.sessionQueue = DispatchQueue(label: "AVSessionQueue", attributes: [])
        
        self.currentImage = CIImage()
        
        superview.addSubview(videoDisplayView)
        superview.sendSubview(toBack: videoDisplayView)
    }
    
    public init(superview: UIView, applyFilterCallback: ((CIImage) -> CIImage?)?, ratio: Float) {
        let cameraFrame = Kirsch.calculateFrameForScreenOption(.normal, superview.frame)
        
        self.superViewFrame = superview.frame
        
        self.ratio = ratio
        self.minRatio = ratio - 0.2
        self.maxRatio = ratio + 0.2
        self.applyFilter = applyFilterCallback
        
        self.videoDisplayView = GLKView(frame: cameraFrame, context: EAGLContext(api: .openGLES2))
        self.videoDisplayView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        self.videoDisplayView.bindDrawable()
        
        self.renderContext = CIContext(eaglContext: videoDisplayView.context)
        
        self.videoDisplayViewBounds = CGRect(x: 0, y: 0, width: videoDisplayView.drawableWidth, height: videoDisplayView.drawableHeight)
        
        self.sessionQueue = DispatchQueue(label: "AVSessionQueue", attributes: [])
        
        self.currentImage = CIImage()
        
        superview.addSubview(videoDisplayView)
        superview.sendSubview(toBack: videoDisplayView)
    }
    
    deinit {
        stop()
    }
    
    
    // MARK: - Scanner Control Methods
    
    public func start() throws {
        do {
            try activateScannerDetection()
        } catch {
            throw error
        }
    }
    
    public func stop() {
        avSession?.stopRunning()
    }
    
    public func configure() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.detector = self.prepareRectangleDetector()
            
            self.applyFilter = { image in
                self.currentImage = image
                
                return self.performRectangleDetection(image: image)
            }
        })
    }
    
    public func captureImage(withFilter filter: CSImageFilter, andOrientation orientation: CSImageOrientation) {
        var image: UIImage? = UIImage()
        
        switch filter {
        case .contrast:
            image = self.currentImage.cropWithColorContrast(withRectangle: self.detectedRectangle, preferredOrientation: orientation)
        case .none:
            image = self.currentImage.crop(withRectangle: self.detectedRectangle, preferredOrientation: orientation)
        }
                
        self.captureProgress = -50
        delegate?.getCapturedImageFiltered(image)
    }
    
    public func captureImage(withOrientation orientation: CSImageOrientation) {
        var image: UIImage? = UIImage()
        
        image = self.currentImage.crop(withRectangle: self.detectedRectangle, preferredOrientation: orientation)
        
        self.captureProgress = -50
        delegate?.getCapturedImageFiltered(image)
    }
    
    public func captureImageWithNoCrop(withOrientation orientation: CSImageOrientation) {
        var image: UIImage? = UIImage()
        
        image = self.currentImage.noCropWithColorContrast(preferredOrientation: orientation)
        
        self.captureProgress = -50
        delegate?.getCapturedImageFiltered(image)
    }
    
    // MARK: - Scanner setup methods
    
    private func prepareAvSession() throws {
        if avSession == nil {
            do {
                avSession = try createAVSession()
            } catch {
                throw CSErrors.noAvSessionAvailable
            }
        }
        
        avSession?.startRunning()
    }
    
    private func createAVSession() throws -> AVCaptureSession {
        // Set the input media as Video Input from the device
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { throw CSErrors.noAvSessionAvailable }
        
        try device.lockForConfiguration()
        device.focusMode = .continuousAutoFocus
        device.unlockForConfiguration()
        
        let input = try AVCaptureDeviceInput(device: device)
        
        // Set the image mode as High Quality
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPreset1920x1080
        
        // Configure the video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        // Join it all together
        session.addInput(input)
        session.addOutput(videoOutput)
        
        return session
    }
    
    private static func calculateFrameForScreenOption(_ frameOption: CSVideoFrame, _ viewFrame: CGRect) -> CGRect {
        
        switch frameOption {
        case .fullScreen:
            let topMargin: CGFloat = 20
            let bottomMargin: CGFloat = 0
            
            let width = viewFrame.width
            let height = viewFrame.height - topMargin - bottomMargin
            
            let doubledDifference = height - width
            let simpleDifference = doubledDifference / 2
            
            return CGRect(x: -simpleDifference, y: topMargin, width: width + doubledDifference, height: width + doubledDifference)
            
        case .square:
            let topMargin: CGFloat = (viewFrame.height / 2) - (viewFrame.width / 2)
            
            let width = viewFrame.width
            let heigh = viewFrame.width
            
            return CGRect(x: 0, y: topMargin, width: width, height: heigh)
            
        case .normal:
            let topMargin: CGFloat = 70
            let bottomMargin: CGFloat = 120
            
            let width = viewFrame.width
            let height = viewFrame.height - topMargin - bottomMargin
            
            let doubledDifference = height - width
            let simpleDifference = doubledDifference / 2
            
            return CGRect(x: -simpleDifference, y: topMargin, width: width + doubledDifference, height: width + doubledDifference)
            
        case .withBottomMargin:
            let topMargin: CGFloat = 20
            let bottomMargin: CGFloat = 120
            
            let width = viewFrame.width
            let height = viewFrame.height - topMargin - bottomMargin
            
            let doubledDifference = height - width
            let simpleDifference = doubledDifference / 2
            
            return CGRect(x: -simpleDifference, y: topMargin, width: width + doubledDifference, height: width + doubledDifference)
        }
        
    }
    
    // MARK: - Document Detection Setup
    
    private func prepareRectangleDetector() -> CIDetector? {
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: 1.5]
        return CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)
    }
    
    // MARK: - Document Detection Methods
    
    private func performRectangleDetection(image: CIImage) -> CIImage? {
        let previousImage = renderRed(self.detectedRectangle, inImage: image)
        
        if let detector = detector {
            guard let blackWhiteImage = image.filterImageUsingContrastFilter() else { return  previousImage }
            guard let feature = detector.features(in: blackWhiteImage).first as? CIRectangleFeature else {
                squareDetectionCounter += 1
                return previousImage
            }
            
            let rectangle = CSRectangle(rectangle: feature)
                        
            detectedRectangle.topLeft.point = shouldRefreshPoint(image, rectangle, detectedRectangle.topLeft, rectangle.topLeft)
            detectedRectangle.topRight.point = shouldRefreshPoint(image, rectangle, detectedRectangle.topRight, rectangle.topRight)
            detectedRectangle.bottomLeft.point = shouldRefreshPoint(image, rectangle, detectedRectangle.bottomLeft, rectangle.bottomLeft)
            detectedRectangle.bottomRight.point = shouldRefreshPoint(image, rectangle, detectedRectangle.bottomRight, rectangle.bottomRight)
            
            squareDetectionCounter = 0
            
            return renderRed(rectangle, inImage: image)
        }
        
        return image
    }
    
    private func renderRed(_ rectangle: CSRectangle, inImage image: CIImage) -> CIImage {
        
        if captureProgress < 0 {
            return image
        }
        
        var redSquareOverlay = CIImage(color: CIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5))
        redSquareOverlay = redSquareOverlay.cropping(to: image.extent)
        redSquareOverlay = redSquareOverlay.applyingFilter(kCIPerspectiveTransformWithExtent, withInputParameters:
            [
                kCIInputExtent: CIVector(cgRect: image.extent),
                kCIInputTopLeft: CIVector(cgPoint: self.detectedRectangle.topLeft.point),
                kCIInputTopRight: CIVector(cgPoint: self.detectedRectangle.topRight.point),
                kCIInputBottomLeft: CIVector(cgPoint: self.detectedRectangle.bottomLeft.point),
                kCIInputBottomRight: CIVector(cgPoint: self.detectedRectangle.bottomRight.point)
            ])
        
        return redSquareOverlay.compositingOverImage(image)
        
    }
    
    // MARK: - Document Detection Points Correction
    
    private func shouldRefreshPoint(_ image: CIImage, _ rectangle: CSRectangle, _ previous: CSPoint, _ actual: CSPoint) -> CGPoint {
        let newRectangle = CSRectangle(rectangle: rectangle, newPoint: actual)
        
        // Check the point movement compared to the previous position
        if previous.absoluteMovementFrom(point: actual) <= 5 {
            self.captureProgress += 5
            
        } else if previous.absoluteMovementFrom(point: actual) <= 10 {
            self.captureProgress += 1
            
        } else if previous.absoluteMovementFrom(point: actual) <= 20 {
            self.captureProgress -= 2
            
        } else if previous.absoluteMovementFrom(point: actual) < 50 &&  previous.absoluteMovementFrom(point: actual) >= 30 {
             squareDetectionCounter += 1
            self.captureProgress = -50
            
        } else {
            
            if newRectangle.calculateRatio() < minRatio || newRectangle.calculateRatio() > maxRatio {
                return previous.point
            } else {
                return actual.point
            }
        }
        
        // If the point is null, at least return the detected point
        if previous.point == CGPoint(x: 0, y: 0) {
            return actual.point
        }
        
        // Check if the point is inside the desired zone
        if !actual.isInside(image.extent) {
            return previous.point
        }
        
        // Check if the ratio is approximately the introduced ratio
        if newRectangle.calculateRatio() < minRatio || newRectangle.calculateRatio() > maxRatio {
            return previous.point
        }
        
        return actual.point
    }
    
    // MARK: - ConfigurationMethods
    
    public func changeVideoDisplayFrame(_ frameOption: CSVideoFrame) {
        
        UIView.animate(withDuration: 0.7) {
            self.captureProgress = -50
            self.videoDisplayView.frame = Kirsch.calculateFrameForScreenOption(frameOption, self.superViewFrame)
        }
        
    }
    
    private func toggleFlash() {
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if self.isFlashActive {
                    try device.setTorchModeOnWithLevel(1.0)
                } else {
                    device.torchMode = AVCaptureTorchMode.off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Toggle Flash: \(error.localizedDescription)")
            }
        }
        
    }
    
    // MARK: - Helper Methods
    
    private func activateScannerDetection() throws {
        do {
            try self.prepareAvSession()
        } catch {
            throw error
        }
    }

}

//MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension Kirsch: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // Need to shimmy this through type-hell
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Force the type change - pass through opaque buffer
        let opaqueBuffer = Unmanaged<CVImageBuffer>.passUnretained(imageBuffer).toOpaque()
        let pixelBuffer = Unmanaged<CVPixelBuffer>.fromOpaque(opaqueBuffer).takeUnretainedValue()
        
        var sourceImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
        
        if isBlackFilterActivated {
            guard let blackAndWhiteImage = sourceImage.filterImageUsingContrastFilter() else { return }
            sourceImage = blackAndWhiteImage
        }
        
        // Do some detection on the image
        let detectionResult = applyFilter?(sourceImage)
        var outputImage = sourceImage
        
        if let detectionResult = detectionResult {
            outputImage = detectionResult
        }
                
        // Do some clipping
        var drawFrame = outputImage.extent
        let imageAR = drawFrame.width / drawFrame.height
        let viewAR = videoDisplayViewBounds.width / videoDisplayViewBounds.height
        
        if imageAR > viewAR {
            drawFrame.origin.x += (drawFrame.width - drawFrame.height * viewAR) / 2.0
            drawFrame.size.width = drawFrame.height / viewAR
        } else {
            drawFrame.origin.y += (drawFrame.height - drawFrame.width / viewAR) / 2.0
            drawFrame.size.height = drawFrame.width / viewAR
        }
        
        videoDisplayView.bindDrawable()
        if videoDisplayView.context != EAGLContext.current() {
            EAGLContext.setCurrent(videoDisplayView.context)
        }
        
        // clear eagl view to grey
        glClearColor(0.5, 0.5, 0.5, 1.0)
        glClear(0x00004000)
        
        // set the blend mode to "source over" so that CI will use that
        glEnable(0x0BE2)
        glBlendFunc(1, 0x0303)
        
        renderContext.draw(outputImage, in: videoDisplayViewBounds, from: drawFrame)
        
        videoDisplayView.display()
    }
}
