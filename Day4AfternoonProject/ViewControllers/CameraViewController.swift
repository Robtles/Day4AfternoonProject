//
//  CameraViewController.swift
//  Day4AfternoonProject
//

import UIKit

class CameraViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Caméra"
    }
}
