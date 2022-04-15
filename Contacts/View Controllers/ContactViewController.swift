//
//  ContactViewController.swift
//  Contacts
//
//  Created by James Hager on 4/15/22.
//

import UIKit

class ContactViewController: UIViewController {

    // MARK: - Properties
    
    var contact: Contact?
    
    var saveBarButton: UIBarButtonItem!
    
    var firstNameTextField: UITextField!
    var lastNameTextField: UITextField!
    var phoneTextField: UITextField!
    var emailTextField: UITextField!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    // MARK: - View Methods
    
    func setUpViews() {
        makeViews()
        configureViews()
    }

    func makeViews() {
        
        saveBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSaveButton))
        saveBarButton.isEnabled = false
        navigationItem.setRightBarButton(saveBarButton, animated: false)
        
        view.backgroundColor = .white
        
        let layoutMarginsGuide = view.layoutMarginsGuide
        let marginForLabel: CGFloat = 6
        let marginBetweenItems: CGFloat = 18
        
        let firstNameLabel = label(text: "First Name:")
        view.addSubview(firstNameLabel)
        firstNameLabel.pin(top: layoutMarginsGuide.topAnchor, trailing: layoutMarginsGuide.trailingAnchor, bottom: nil, leading: layoutMarginsGuide.leadingAnchor, margin: [marginBetweenItems, 0, 0, 0])
        
        firstNameTextField = textField(placeholder: "First Name...")
        view.addSubview(firstNameTextField)
        firstNameTextField.pin(top: firstNameLabel.bottomAnchor, trailing: layoutMarginsGuide.trailingAnchor, bottom: nil, leading: layoutMarginsGuide.leadingAnchor, margin: [marginForLabel, 0, 0, 0])

        let lastNameLabel = label(text: "Last Name:")
        view.addSubview(lastNameLabel)
        lastNameLabel.pin(top: firstNameTextField.bottomAnchor, trailing: layoutMarginsGuide.trailingAnchor, bottom: nil, leading: layoutMarginsGuide.leadingAnchor, margin: [marginBetweenItems, 0, 0, 0])
        
        lastNameTextField = textField(placeholder: "Last Name...")
        view.addSubview(lastNameTextField)
        lastNameTextField.pin(top: lastNameLabel.bottomAnchor, trailing: layoutMarginsGuide.trailingAnchor, bottom: nil, leading: layoutMarginsGuide.leadingAnchor, margin: [marginForLabel, 0, 0, 0])

        let phoneLabel = label(text: "Phone Number:")
        view.addSubview(phoneLabel)
        phoneLabel.pin(top: lastNameTextField.bottomAnchor, trailing: layoutMarginsGuide.trailingAnchor, bottom: nil, leading: layoutMarginsGuide.leadingAnchor, margin: [marginBetweenItems, 0, 0, 0])
        
        phoneTextField = textField(placeholder: "123-123-1234")
        view.addSubview(phoneTextField)
        phoneTextField.pin(top: phoneLabel.bottomAnchor, trailing: layoutMarginsGuide.trailingAnchor, bottom: nil, leading: layoutMarginsGuide.leadingAnchor, margin: [marginForLabel, 0, 0, 0])

        let emailLabel = label(text: "Email Address:")
        view.addSubview(emailLabel)
        emailLabel.pin(top: phoneTextField.bottomAnchor, trailing: layoutMarginsGuide.trailingAnchor, bottom: nil, leading: layoutMarginsGuide.leadingAnchor, margin: [marginBetweenItems, 0, 0, 0])
        
        emailTextField = textField(placeholder: "Email Address...")
        view.addSubview(emailTextField)
        emailTextField.pin(top: emailLabel.bottomAnchor, trailing: layoutMarginsGuide.trailingAnchor, bottom: nil, leading: layoutMarginsGuide.leadingAnchor, margin: [marginForLabel, 0, 0, 0])
    }
    
    func label(text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func textField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.placeholder = placeholder
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    func configureViews() {
        guard let contact = contact else { return }
        
        saveBarButton.isEnabled = true
        
        firstNameTextField.text = contact.firstName
        lastNameTextField.text = contact.lastName
        phoneTextField.text = contact.phone
        emailTextField.text = contact.email
    }
    
    // MARK: - Actions
    
    @objc func handleSaveButton() {
        guard let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              !firstName.isEmpty || !lastName.isEmpty,
              let phone = phoneTextField.text,
              let email = emailTextField.text
        else { return }
        
        if let contact = contact {
            ContactController.shared.update(contact, firstName: firstName, lastName: lastName, phone: phone, email: email, completion: handleCreateUpdateCompletion)
        } else {
            ContactController.shared.createContact(firstName: firstName, lastName: lastName, phone: phone, email: email, completion: handleCreateUpdateCompletion)
        }
    }
    
    func handleCreateUpdateCompletion(result: Result<Bool, ContactError>) {
        DispatchQueue.main.async {
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print(error)
                self.presentErrorAlert(for: error)
            }
        }
    }
    
    func setSaveBarButtonIsEnabled(from textField: UITextField) {
        if textField == firstNameTextField {
            saveBarButton.isEnabled = !textFieldIsEmpty(lastNameTextField)
        } else {
            saveBarButton.isEnabled = !textFieldIsEmpty(firstNameTextField)
        }
    }
    
    func textFieldIsEmpty(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return true }
        return text.isEmpty
    }
}


// MARK: - UITextFieldDelegate

extension ContactViewController: UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {

        setSaveBarButtonIsEnabled(from: textField)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard textField == firstNameTextField || textField == lastNameTextField else { return true }
        
        let textFieldText = textField.text != nil ? textField.text! : ""
        let newLength = textFieldText.count - range.length + string.count
        
        if newLength > 0 {
            saveBarButton.isEnabled = true
        } else {
            setSaveBarButtonIsEnabled(from: textField)
        }
        
        return true
    }
}
