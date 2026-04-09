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
        mapView.showsUserLocation = true
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
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private func refreshPermissionStatus() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            statusLabel.text = "Statut : permission non demandée"
            requestPermissionButton.isHidden = false

        case .restricted:
            statusLabel.text = "Statut : accès restreint"
            requestPermissionButton.isHidden = true

        case .denied:
            statusLabel.text = "Statut : permission refusée"
            requestPermissionButton.isHidden = false

        case .authorizedWhenInUse, .authorizedAlways:
            statusLabel.text = "Statut : permission accordée"
            requestPermissionButton.isHidden = true
            locationManager.startUpdatingLocation()

        @unknown default:
            statusLabel.text = "Statut : inconnu"
            requestPermissionButton.isHidden = false
        }
    }

    @objc
    private func didTapRequestPermission() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .denied:
            presentLocationDeniedAlert()

        case .restricted:
            presentRestrictedAlert()

        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()

        @unknown default:
            break
        }
    }

    private func updateMap(with location: CLLocation) {
        let coordinate = location.coordinate

        coordinatesLabel.text = """
        Latitude: \(coordinate.latitude)
        Longitude: \(coordinate.longitude)
        """

        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )

        mapView.setRegion(region, animated: true)

        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Vous êtes ici"

        mapView.addAnnotation(annotation)
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
        refreshPermissionStatus()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        updateMap(with: location)

        // Pour cet exercice, une seule mise à jour suffit
        manager.stopUpdatingLocation()
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
