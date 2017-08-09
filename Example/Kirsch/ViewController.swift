//
//  ViewController.swift
//  DocumentScanner
//
//  Created by Josep Bordes Jové on 18/7/17.
//  Copyright © 2017 Josep Bordes Jové. All rights reserved.
//

import UIKit
import Kirsch

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    lazy var coverfyScanner: Kirsch = {
        let scanner = Kirsch(superview: self.view, videoFrameOption: .fullScreen, applyFilterCallback: nil, ratio: 1.5)
        scanner.configure()
        
        return scanner
    }()
    
    lazy var captureButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "camera-btn"), for: .normal)
        button.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var progressBar: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progress = 0.0
        progressView.progressTintColor = UIColor.yellow
        progressView.trackTintColor = UIColor.gray
        progressView.progressViewStyle = UIProgressViewStyle.bar
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        return progressView
    }()
    
    lazy var infoButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "info-btn"), for: .normal)
        button.addTarget(self, action: #selector(showinfoLabel), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var captureModeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "color-btn"), for: .normal)
        button.addTarget(self, action: #selector(changeColorCapturingState), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var flashButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "flashOff-btn"), for: .normal)
        button.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.alpha = 0
        label.text = "Please, put the document on a dark surface and wait at the progress bar to be completed."
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup the view
        setupView()
        setupConstraints()
        
        // Create the video filter
        coverfyScanner.delegate = self
        coverfyScanner.isBlackFilterActivated = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        
        // Set the status bar style
        UIApplication.shared.statusBarStyle = .lightContent
        
        infoLabel.alpha = 0
        infoButton.alpha = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        do {
            try coverfyScanner.start()
        } catch {
            presentAlertView(title: "Some Error Occurred", message: error.localizedDescription)
        }
    }
    
    // MARK: - View Methods
    
    func setupView() {
        [captureButton,progressBar,infoLabel,infoButton,captureModeButton,flashButton].forEach{ view.addSubview($0) }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            captureButton.heightAnchor.constraint(equalToConstant: 80),
            captureButton.widthAnchor.constraint(equalToConstant: 80),
            
            flashButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            flashButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            flashButton.heightAnchor.constraint(equalToConstant: 30),
            flashButton.widthAnchor.constraint(equalToConstant: 30),
            
            captureModeButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            captureModeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            captureModeButton.heightAnchor.constraint(equalToConstant: 33),
            captureModeButton.widthAnchor.constraint(equalToConstant: 35),
            
            progressBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            progressBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            progressBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            progressBar.heightAnchor.constraint(equalToConstant: 4),
            
            infoButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            infoButton.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 10),
            infoButton.heightAnchor.constraint(equalToConstant: 20),
            infoButton.widthAnchor.constraint(equalToConstant: 20),
            
            infoLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 5),
            infoLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            infoLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
            ])
    }
    
    // MARK: - Helper Methods
    
    func changeColorCapturingState() {
        coverfyScanner.isBlackFilterActivated = !coverfyScanner.isBlackFilterActivated
        
        if coverfyScanner.isBlackFilterActivated {
            captureModeButton.setImage(#imageLiteral(resourceName: "color-btn"), for: .normal)
        } else {
            captureModeButton.setImage(#imageLiteral(resourceName: "b&w-btn"), for: .normal)
        }
    }
    
    func toggleFlash() {
        coverfyScanner.isFlashActive = !coverfyScanner.isFlashActive
        
        if coverfyScanner.isFlashActive {
            flashButton.setImage(#imageLiteral(resourceName: "flash-btn"), for: .normal)
        } else {
            flashButton.setImage(#imageLiteral(resourceName: "flashOff-btn"), for: .normal)
        }
    }
    
    func captureImage() {
        coverfyScanner.captureImage(withFilter: .contrast, andOrientation: .vertical)
    }
    
    func showinfoLabel() {
        UIView.animate(withDuration: 1) {
            self.infoLabel.alpha = 1
            self.infoButton.alpha = 0
        }
    }
    
    // MARK: - Present Methods
    
    func presentAlertView(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - CoverfyScannerDelegate

extension ViewController: KirschDelegate {
    
    func getCapturingProgress(_ progress: Float?) {
        guard let progress = progress else { return }
        
        if progress >= 1 {
            captureImage()
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                self.progressBar.setProgress(Float(progress), animated: true)
            }
        }
    }
    
    func getCapturedImageFiltered(_ image: UIImage?) {
        guard let capturedImage = image else { return }
        
        self.coverfyScanner.stop()
        
        DispatchQueue.main.async {
            let detailViewController = DetailViewController(image: capturedImage)
            self.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    
    
}
