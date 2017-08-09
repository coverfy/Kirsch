//
//  DetailViewController.swift
//  DocumentScanner
//
//  Created by Josep Bordes Jové on 18/7/17.
//  Copyright © 2017 Josep Bordes Jové. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UINavigationControllerDelegate {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        
        self.imageView.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Detail View Controller deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConttraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        
        // Set the status bar style
        UIApplication.shared.statusBarStyle = .default
    }
    
    func setupView() {
        view.backgroundColor = .white
        [imageView].forEach{ view.addSubview($0) }
    }
    
    func setupConttraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])
    }

}
