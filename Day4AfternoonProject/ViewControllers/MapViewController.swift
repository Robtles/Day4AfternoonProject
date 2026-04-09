//
//  MapViewController.swift
//  Day4AfternoonProject
//

import CoreLocation
import MapKit
import UIKit

final class MapViewController: UIViewController {

    private let locationManager = CLLocationManager()

    private let stackView = UIStackView()
    private let statusLabel = UILabel()
    private let requestPermissionButton = UIButton(type: .system)
    private let coordinatesLabel = UILabel()
    private let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
        refreshPermissionStatus()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshPermissionStatus()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Autour de moi"

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill

        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center

        requestPermissionButton.setTitle("Demander l’accès à la localisation", for: .normal)
        requestPermissionButton.addTarget(self, action: #selector(didTapRequestPermission), for: .touchUpInside)

        coordinatesLabel.numberOfLines = 0
        coordinatesLabel.textAlignment = .center
        coordinatesLabel.text = "Latitude: -\nLongitude: -"

        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layer.cornerRadius = 12
        mapView.clipsToBounds = true
        mapView.heightAnchor.constraint(equalToConstant: 320).isActive = true

        stackView.addArrangedSubview(statusLabel)
        stackView.addArrangedSubview(requestPermissionButton)
        stackView.addArrangedSubview(coordinatesLabel)
        stackView.addArrangedSubview(mapView)

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func setupLocationManager() {
        // TODO:
        // 1. Définir le delegate du locationManager
        // 2. Définir une précision (ex: kCLLocationAccuracyBest)
    }

    private func refreshPermissionStatus() {
        // TODO:
        // 1. Lire le statut d’autorisation de la localisation
        // 2. Mettre à jour statusLabel
        // 3. Afficher ou masquer le bouton de permission
        // 4. Si autorisé, démarrer la mise à jour de localisation
    }

    @objc
    private func didTapRequestPermission() {
        // TODO:
        // 1. Lire le statut actuel
        // 2. Si .notDetermined -> demander requestWhenInUseAuthorization()
        // 3. Si .denied -> afficher une alerte vers Réglages
        // 4. Si .restricted -> afficher une alerte informative
        // 5. Si déjà autorisé -> lancer startUpdatingLocation()
    }

    private func updateMap(with location: CLLocation) {
        // TODO:
        // 1. Récupérer les coordonnées
        // 2. Mettre à jour coordinatesLabel
        // 3. Créer une région centrée sur la position
        // 4. Appliquer cette région à la map
        // 5. Supprimer les anciennes annotations (sauf user location)
        // 6. Ajouter une annotation "Vous êtes ici"
    }

    private func presentLocationDeniedAlert() {
        let alert = UIAlertController(
            title: "Localisation refusée",
            message: "Autorisez la localisation dans Réglages pour afficher votre position sur la carte.",
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

    private func presentRestrictedAlert() {
        let alert = UIAlertController(
            title: "Localisation restreinte",
            message: "L’accès à la localisation est restreint sur cet appareil.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension MapViewController: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // TODO:
        // Recharger l’UI quand le statut change
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // TODO:
        // 1. Récupérer la dernière location
        // 2. Appeler updateMap(with:)
        // 3. Stopper les updates si une seule position suffit
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(
            title: "Erreur de localisation",
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
