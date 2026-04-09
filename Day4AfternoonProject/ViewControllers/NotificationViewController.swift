//
//  NotificationViewController.swift
//  Day4AfternoonProject
//

import UIKit
import UserNotifications

final class NotificationViewController: UIViewController {

    private let titleField = UITextField()
    private let descriptionField = UITextField()
    private let secondsField = UITextField()
    private let scheduleButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        layoutViews()
        requestNotificationPermission()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Notification locale"
        
        titleField.placeholder = "Titre"
        titleField.borderStyle = .roundedRect

        descriptionField.placeholder = "Description"
        descriptionField.borderStyle = .roundedRect

        secondsField.placeholder = "Secondes"
        secondsField.borderStyle = .roundedRect
        secondsField.keyboardType = .numberPad

        scheduleButton.setTitle("Programmer", for: .normal)
        scheduleButton.addTarget(self, action: #selector(scheduleNotification), for: .touchUpInside)
    }
    
    private func layoutViews() {
        let stackView = UIStackView(arrangedSubviews: [
            titleField,
            descriptionField,
            secondsField,
            scheduleButton
        ])

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func requestNotificationPermission() {
        // TODO:
    }

    @objc
    private func scheduleNotification() {
        // TODO:
        // - Récupérer les textes depuis le formulaire et s'assurer qu'ils ne soient pas vides
        // - Créer une notification locale et préparer un envoi avec une requête locale
        // - Afficher une alerte présentant l'information de la programmation de la notification
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Info",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
