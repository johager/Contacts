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
    
    // MARK: - Init
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        NotificationCenter.default.addObserver(self, selector: #selector(handleICloudConnectionChanged), name: .iCloudConnectionChanged, object: nil)
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
        
        addLabel(withText: "First Name:", topPinnedTo: layoutMarginsGuide.topAnchor, and: &firstNameTextField, withPlaceholder: "First Name...", marginBetweenItems: marginBetweenItems, marginForLabel: marginForLabel)
        
        addLabel(withText: "Last Name:", topPinnedTo: firstNameTextField.bottomAnchor, and: &lastNameTextField, withPlaceholder: "Last Name...", marginBetweenItems: marginBetweenItems, marginForLabel: marginForLabel)
        
        addLabel(withText: "Phone Number:", topPinnedTo: lastNameTextField.bottomAnchor, and: &phoneTextField, withPlaceholder: "123-123-1234", marginBetweenItems: marginBetweenItems, marginForLabel: marginForLabel)
        
        addLabel(withText: "Email Address:", topPinnedTo: phoneTextField.bottomAnchor, and: &emailTextField, withPlaceholder: "Email Address...", marginBetweenItems: marginBetweenItems, marginForLabel: marginForLabel)
        
        emailTextField.keyboardType = .emailAddress
    }
    
    func addLabel(withText text: String, topPinnedTo pin: NSLayoutYAxisAnchor, and textField: inout UITextField?, withPlaceholder placeholder: String, marginBetweenItems: CGFloat, marginForLabel: CGFloat) {
        
        let layoutMarginsGuide = view.layoutMarginsGuide
        
        let textLabel = label(text: text)
        view.addSubview(textLabel)
        textLabel.pin(top: pin, trailing: layoutMarginsGuide.trailingAnchor, bottom: nil, leading: layoutMarginsGuide.leadingAnchor, margin: [marginBetweenItems, 0, 0, 0])
        
        textField = self.textField(placeholder: placeholder)
        view.addSubview(textField!)
        textField!.pin(top: textLabel.bottomAnchor, trailing: layoutMarginsGuide.trailingAnchor, bottom: nil, leading: layoutMarginsGuide.leadingAnchor, margin: [marginForLabel, 0, 0, 0])
    }
    
    func label(text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.text = text
        return label
    }
    
    func textField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.placeholder = placeholder
        textField.delegate = self
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
    
    @objc func handleICloudConnectionChanged() {
        DispatchQueue.main.async {
            self.saveBarButton.isEnabled = ContactController.shared.iCloudIsAvailable
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
        
        guard ContactController.shared.iCloudIsAvailable else { return true }
        
        setSaveBarButtonIsEnabled(from: textField)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard ContactController.shared.iCloudIsAvailable else { return true }
        
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
