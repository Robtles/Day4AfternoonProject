//
//  ContactsViewController.swift
//  Day4AfternoonProject
//

import Contacts
import UIKit

final class ContactsViewController: UIViewController {

    private let contactStore = CNContactStore()

    private let stackView = UIStackView()
    private let statusLabel = UILabel()
    private let requestButton = UIButton(type: .system)
    private let reloadButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)

    private var contacts: [CNContact] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        refreshPermissionStatus()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshPermissionStatus()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Contacts"

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill

        statusLabel.font = .preferredFont(forTextStyle: .body)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0

        requestButton.setTitle("Demander l’accès aux contacts", for: .normal)
        requestButton.addTarget(self, action: #selector(didTapRequestPermission), for: .touchUpInside)

        reloadButton.setTitle("Recharger les contacts", for: .normal)
        reloadButton.addTarget(self, action: #selector(didTapReloadContacts), for: .touchUpInside)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ContactCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.isHidden = true

        stackView.addArrangedSubview(statusLabel)
        stackView.addArrangedSubview(requestButton)
        stackView.addArrangedSubview(reloadButton)

        view.addSubview(stackView)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func refreshPermissionStatus() {
        let status = CNContactStore.authorizationStatus(for: .contacts)

        switch status {
        case .authorized:
            statusLabel.text = "Statut : autorisé"
            requestButton.isHidden = true
            reloadButton.isHidden = false
            tableView.isHidden = false
            loadContacts()

        case .notDetermined:
            statusLabel.text = "Statut : non déterminé"
            requestButton.isHidden = false
            reloadButton.isHidden = true
            tableView.isHidden = true
            contacts = []
            tableView.reloadData()

        case .denied:
            statusLabel.text = "Statut : refusé"
            requestButton.isHidden = false
            reloadButton.isHidden = true
            tableView.isHidden = true
            contacts = []
            tableView.reloadData()

        case .restricted:
            statusLabel.text = "Statut : restreint"
            requestButton.isHidden = true
            reloadButton.isHidden = true
            tableView.isHidden = true
            contacts = []
            tableView.reloadData()
        case .limited:
            statusLabel.text = "Statut : limité"
            requestButton.isHidden = true
            reloadButton.isHidden = true
            tableView.isHidden = true
            contacts = []
            tableView.reloadData()

        @unknown default:
            statusLabel.text = "Statut : inconnu"
            requestButton.isHidden = false
            reloadButton.isHidden = true
            tableView.isHidden = true
            contacts = []
            tableView.reloadData()
        }
    }

    @objc
    private func didTapRequestPermission() {
        let status = CNContactStore.authorizationStatus(for: .contacts)

        switch status {
        case .authorized:
            refreshPermissionStatus()

        case .notDetermined:
            contactStore.requestAccess(for: .contacts) { [weak self] granted, error in
                DispatchQueue.main.async {
                    guard let self else { return }

                    if let error {
                        self.presentErrorAlert(message: "Erreur lors de la demande d’accès : \(error.localizedDescription)")
                        return
                    }

                    if !granted {
                        self.presentPermissionDeniedAlert()
                    }

                    self.refreshPermissionStatus()
                }
            }

        case .denied, .restricted, .limited:
            presentPermissionDeniedAlert()

        @unknown default:
            presentPermissionDeniedAlert()
        }
    }

    @objc
    private func didTapReloadContacts() {
        loadContacts()
    }

    private func loadContacts() {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactMiddleNameKey as CNKeyDescriptor,
            CNContactPhoneticGivenNameKey as CNKeyDescriptor,
            CNContactPhoneticFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneticMiddleNameKey as CNKeyDescriptor
        ]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            var fetchedContacts: [CNContact] = []
            
            do {
                try self.contactStore.enumerateContacts(with: fetchRequest) { contact, _ in
                    fetchedContacts.append(contact)
                }
                
                let sortedContacts = fetchedContacts.sorted {
                    let lhs = "\($0.givenName) \($0.familyName)"
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    let rhs = "\($1.givenName) \($1.familyName)"
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    return lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
                }
                
                DispatchQueue.main.async {
                    self.contacts = sortedContacts
                    self.statusLabel.text = "Statut : autorisé (\(sortedContacts.count) contact(s))"
                    self.tableView.reloadData()
                }
            } catch {
                DispatchQueue.main.async {
                    self.presentErrorAlert(
                        message: "Impossible de charger les contacts : \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    private func presentPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Accès aux contacts refusé",
            message: "Autorise l’accès aux contacts dans Réglages pour utiliser cette fonctionnalité.",
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

    private func presentErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Erreur",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func displayName(for contact: CNContact) -> String {
        let fullName = "\(contact.givenName) \(contact.familyName)"
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return fullName.isEmpty ? "Sans nom" : fullName
    }

    private func subtitle(for contact: CNContact) -> String {
        if let firstPhoneNumber = contact.phoneNumbers.first?.value.stringValue,
           !firstPhoneNumber.isEmpty {
            return firstPhoneNumber
        }

        if let firstEmail = contact.emailAddresses.first?.value as String?,
           !firstEmail.isEmpty {
            return firstEmail
        }

        return "Aucune information"
    }
}

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contacts.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let contact = contacts[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)

        var configuration = cell.defaultContentConfiguration()
        configuration.text = displayName(for: contact)
        configuration.secondaryText = subtitle(for: contact)
        configuration.secondaryTextProperties.color = .secondaryLabel

        cell.contentConfiguration = configuration
        cell.selectionStyle = .none

        return cell
    }
}
