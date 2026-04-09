//
//  CameraViewController.swift
//  Day4AfternoonProject
//

import AVFoundation
import UIKit

final class CameraViewController: UIViewController {

    private let stackView = UIStackView()
    private let statusLabel = UILabel()
    private let requestPermissionButton = UIButton(type: .system)
    private let openCameraButton = UIButton(type: .system)
    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refreshPermissionStatus()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Caméra"

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill

        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center

        requestPermissionButton.setTitle("Demander l’accès caméra", for: .normal)
        requestPermissionButton.titleLabel?.font = .systemFont(ofSize: 18.0)
        requestPermissionButton.addTarget(self, action: #selector(didTapRequestPermission), for: .touchUpInside)

        openCameraButton.setTitle("Ouvrir la caméra", for: .normal)
        openCameraButton.titleLabel?.font = .systemFont(ofSize: 18.0)
        openCameraButton.addTarget(self, action: #selector(didTapOpenCamera), for: .touchUpInside)

        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.heightAnchor.constraint(equalToConstant: 240).isActive = true

        stackView.addArrangedSubview(statusLabel)
        stackView.addArrangedSubview(requestPermissionButton)
        stackView.addArrangedSubview(openCameraButton)
        stackView.addArrangedSubview(imageView)

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func refreshPermissionStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        let statusText = switch status {
        case .authorized: "Statut : autorisé"
        case .notDetermined: "Statut : non déterminé"
        case .denied: "Statut : refusé"
        case .restricted: "Statut : restreint"
        @unknown default: "Statut : inconnu"
        }
        
        statusLabel.text = statusText
        openCameraButton.isEnabled = switch status {
        case .authorized: true
        default: false
        }
    }

    @objc private func didTapRequestPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            refreshPermissionStatus()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.refreshPermissionStatus()

                    if !granted {
                        self.presentPermissionDeniedAlert()
                    }
                }
            }

        case .denied, .restricted:
            presentPermissionDeniedAlert()

        @unknown default:
            presentPermissionDeniedAlert()
        }
    }

    @objc private func didTapOpenCamera() {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            presentPermissionDeniedAlert()
            return
        }

        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentCameraUnavailableAlert()
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = false

        present(picker, animated: true)
    }

    private func presentPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Caméra non autorisée",
            message: "Autorise la caméra dans Réglages pour utiliser cette fonctionnalité.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alert.addAction(UIAlertAction(title: "Réglages", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(url) else {
                return
            }

            UIApplication.shared.open(url)
        })

        present(alert, animated: true)
    }

    private func presentCameraUnavailableAlert() {
        let alert = UIAlertController(
            title: "Caméra indisponible",
            message: "La caméra n’est pas disponible sur cet appareil ou simulateur.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        let image = info[.originalImage] as? UIImage
        imageView.image = image
        picker.dismiss(animated: true)
    }
}
