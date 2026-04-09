//
//  MenuViewController.swift
//  Day4AfternoonProject
//

import UIKit

enum MenuRoute: CaseIterable {
    case camera
    case contacts
    case map
    case notification

    var title: String {
        switch self {
        case .camera: "TO CAMERA FEATURE"
        case .contacts: "TO CONTACTS FEATURE"
        case .map: "TO MAP FEATURE"
        case .notification: "TO NOTIFICATION"
        }
    }

    var viewController: UIViewController {
        switch self {
        case .camera:
            CameraViewController()
        case .contacts:
            ContactsViewController()
        case .map:
            MapViewController()
        case .notification:
            NotificationViewController()
        }
    }
}

final class MenuViewController: UIViewController {

    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func button(for route: MenuRoute) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(route.title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18.0)

        button.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                
                navigationController?.pushViewController(route.viewController, animated: true)
            },
            for: .touchUpInside
        )

        return button
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Menu"

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16

        MenuRoute.allCases.forEach { route in
            addButton(route: route)
        }

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func addButton(route: MenuRoute) {
        let button = button(for: route)
        stackView.addArrangedSubview(button)
    }
}
