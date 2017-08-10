# Kirsch

[![CI Status](http://img.shields.io/travis/josepbordesjove/Kirsch.svg?style=flat)](https://travis-ci.org/josepbordesjove/Kirsch)
[![Version](https://img.shields.io/cocoapods/v/Kirsch.svg?style=flat)](http://cocoapods.org/pods/Kirsch)
[![License](https://img.shields.io/cocoapods/l/Kirsch.svg?style=flat)](http://cocoapods.org/pods/Kirsch)
[![Platform](https://img.shields.io/cocoapods/p/Kirsch.svg?style=flat)](http://cocoapods.org/pods/Kirsch)

Kirsch is an elegant and simple scanner library to automatically scan documents and crop them.

## Features
- [x] Automatic and manual document capture
- [x] Color and black and white filter
- [x] Border cropping

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- iOS 9.0+ 
- Xcode 8.1, 8.2, 8.3, and 9.0
- Swift 3.0, 3.1, 3.2, and 4.0

## Installation

Kirsch is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Kirsch"
```

## Usage
### Initialize and configure the scanner
To initialize the scanner simply call it's initilaizer with the desired options. 
* videoFrameOption: Indicates the size of the view where the video is displayed (.normal, .square, .fullScreen and .withBottomMargin)
* applyFilterCallback: Should stay nil
* ratio: The approximate ratio (height/width) of the document you want to scan

```swift
import UIKit
import Kirsch

class ViewController: UIViewController, KirschDelegate {
  
  lazy var scanner: Kirsch = {
    let scanner = Kirsch(superview: self.view, videoFrameOption: .fullScreen, applyFilterCallback: nil, ratio: 1.5)
    scanner.configure()
    
    return scanner
  }()

  viewDidLoad() {
    super.viewDidLoad()
    
    // Create the video filter
    scanner.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    do {
      try scanner.start()
    } catch {
      presentAlertView(title: "Some Error Occurred", message: error.localizedDescription)
    }
  }
  
}
```

### Options available
```swift 
scanner.isBlackFilterActivated // Activate the black filter 
scanner.isFlashActive // Activate the flashlight of the phone 
```

### Configuration Functions
```swift 
scanner.configure() // Configure the scanner
scanner.start() // Start the scanner
swift scanner.stop() // Stop the scanner
```

Note: that the configure() should be called before the start() function.

### Control  Functions
* Filter: Indicates the type of filter it's going to be applied (.contrast, .none)
* Orientation: Helps the detector in which orientation the documents is going to be (.vertical, horizontal)

```swift 
scanner.captureImage(withFilter: .contrast, andOrientation: .vertical) // Captures vertical image and applying a high contrast filter
scanner.captureImage(withOrientation: .vertical) // Captures a vertical image without applying any filters
scanner.captureImageWithNoCrop(withOrientation: .vertical) // Captures a vertical image without cropping any borders
```

## Delegate

The capturing progress indicates if an image is being well detected and the phone is able to capture it. When this progress arrives at 100%, the scanner has detected an stable image

```swift
func getCapturingProgress(_ progress: Float?) {
  guard let progress = progress else { return }
        
  if progress >= 1 {
    scanner.captureImage(withFilter: .contrast, andOrientation: .vertical)
  }
}
```

When the an image is captured, it will be returned by this delegate function 
```swift
func getCapturedImageFiltered(_ image: UIImage?) {
  guard let capturedImage = image else { return }
   
  self.coverfyScanner.stop()
}
```
## Credits
This project has been developed to use it into the Coverfy App. An app to organize all your insurances, take a look at it https://www.coverfy.com!

<img src="https://www.coverfy.com/wp-content/uploads/2016/07/coverfy-logo.png" alt="image" style="width: 100px;"/>

## Base project
Some ideas of this scanner has been taken from the IRLScanner (https://github.com/hartws1/IRLScanner)

## Author

josepbordesjove, josep.bordes@coverfy.com

## License

Kirsch is available under the MIT license. See the LICENSE file for more info.
