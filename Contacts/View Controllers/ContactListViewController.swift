//
//  ContactListViewController.swift
//  Contacts
//
//  Created by James Hager on 4/15/22.
//

import UIKit

class ContactListViewController: UIViewController {

    // MARK: - Properties
    
    var addBarButton: UIBarButtonItem!
    let tableView = UITableView()
    
    var contacts: [Contact] { ContactController.shared.contacts }
    
    let cellIdentifier = "contactCell"
    
    // MARK: - Init
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        fetchContacts()
        NotificationCenter.default.addObserver(self, selector: #selector(handleICloudConnectionChanged), name: .iCloudConnectionChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - View Methods

    func setUpViews() {
        title = "Contacts"
        
        addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddButton))
        addBarButton.isEnabled = false
        navigationItem.setRightBarButton(addBarButton, animated: false)
        
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        
        tableView.pin(top: view.topAnchor, trailing: view.trailingAnchor, bottom: view.bottomAnchor, leading: view.leadingAnchor)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func fetchContacts() {
        guard ContactController.shared.iCloudIsAvailable else { return }
        
        ContactController.shared.fetchContacts { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                    self.presentErrorAlert(for: error)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func handleAddButton() {
        let contactVC = ContactViewController()
        navigationController?.pushViewController(contactVC, animated: true)
    }
    
    @objc func handleICloudConnectionChanged() {
        DispatchQueue.main.async {
            let iCloudIsAvailable = ContactController.shared.iCloudIsAvailable
            self.addBarButton.isEnabled = iCloudIsAvailable
            
            if iCloudIsAvailable && self.contacts.count == 0 {
                self.fetchContacts()
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension ContactListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        config.text = contacts[indexPath.row].nameForList
        cell.contentConfiguration = config
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return ContactController.shared.iCloudIsAvailable
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        ContactController.shared.delete(atIndex: indexPath.row) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                    self.presentErrorAlert(for: error)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension ContactListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contactVC = ContactViewController()
        contactVC.contact = contacts[indexPath.row]
        navigationController?.pushViewController(contactVC, animated: true)
    }
}
