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
- iOS 9.3+ 
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
```swift
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

### Functions
There are multiple functions to use the scanner

### Delegate

## Author

josepbordesjove, josep.bordes@coverfy.com

## License

Kirsch is available under the MIT license. See the LICENSE file for more info.
