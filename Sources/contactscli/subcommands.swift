import ArgumentParser
import Contacts
import AppKit

let AllContactKeys = [
    CNContactGivenNameKey,
    CNContactFamilyNameKey,
    CNContactMiddleNameKey,
    CNContactJobTitleKey,
    CNContactPostalAddressesKey,
    CNContactDepartmentNameKey,
    CNContactNoteKey,
    CNContactNicknameKey,
    CNContactTypeKey,
    CNContactBirthdayKey,
    CNContactDatesKey,
    CNContactPhoneNumbersKey,
    CNContactNonGregorianBirthdayKey
] as [CNKeyDescriptor]

struct list: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        abstract: "List a Contact and it's properties if specified, otherwise list all Contacts and their properties "
    )
    
    @Argument(help: "The name of the Contact(s) to list information from (optional)")
    var contactName: String?
    
    @Flag(help: "Show unavailable values")
    var showUnavailable: Bool = false
    
    func run() throws {
        // the contacts to loop over and show information from
        var contacts: [CNContact]
        
        if let contactName = contactName {
            
            contacts = try ContactHelper.getContacts(withName: contactName, KeysToFetch: AllContactKeys)
            guard !contacts.isEmpty else {
                throw ValidationError("No contacts with the name \(contactName) found")
            }
        } else {
            contacts = try ContactHelper.getAllContacts(keysToFetch: AllContactKeys)
        }
        
        for contact in contacts {
            print("Contact \"\(contact.givenName)\": ")
            for (key, value) in ContactHelper.formatContactInfo(fromContact: contact, hideUnavailable: !showUnavailable) {
                print("\t\(key): \(value)")
            }
        }
        
    }
}

struct save: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        abstract: "Saves a new contact with specified information"
    )
    
    @OptionGroup var saveOpts: saveOptions
    
    func run() throws {
        let contact = CNMutableContact()
        contact.givenName = saveOpts.firstName
        
        if let imagePath = saveOpts.imagePath {
            guard FileManager.default.fileExists(atPath: imagePath) else {
                throw ValidationError("Path \"\(imagePath)\" can't be used as the Image for the contact as it doesn't exist.")
            }
            
            let url = URL(fileURLWithPath: imagePath)
            guard let data = NSImage(contentsOf: url)?.tiffRepresentation else {
                fatalError("Can't get data of image at path \(imagePath)")
            }
            
            contact.imageData = data
        }
        
        if let middleName = saveOpts.middleName {
            contact.middleName = middleName
        }
        
        if let familyName = saveOpts.familyName {
            contact.familyName = familyName
        }
        
        if let jobTitle = saveOpts.jobTitle {
            contact.jobTitle = jobTitle
        }
        
        if let departmentName = saveOpts.departmentName {
            contact.departmentName = departmentName
        }
        
        if let nickname = saveOpts.nickname {
            contact.nickname = nickname
        }
        
        if let note = saveOpts.note {
            contact.note = note
        }
        
        var contactEmailAddresses: [CNLabeledValue<NSString>] = []
        
        if let workEmail = saveOpts.workEmail {
            contactEmailAddresses.append(
                CNLabeledValue(label: CNLabelHome, value: workEmail as NSString)
            )
        }
        
        if let homeEmail = saveOpts.homeEmail {
            contactEmailAddresses.append(
                CNLabeledValue(label: CNLabelWork, value: homeEmail as NSString)
            )
        }
        
        if !contactEmailAddresses.isEmpty {
            contact.emailAddresses = contactEmailAddresses
        }
        
        let homeAddress = CNMutablePostalAddress()
        
        if let street = saveOpts.street {
            homeAddress.street = street
        }
        
        if let city = saveOpts.city {
            homeAddress.city = city
        }
        
        if let state = saveOpts.state {
            homeAddress.state = state
        }
        
        if let country = saveOpts.country {
            homeAddress.country = country
        }
        
        if let birthDate = saveOpts.birthDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = saveOpts.dateFormat
            guard let date = dateFormatter.date(from: birthDate) else {
                fatalError("Unable to convert \"\(birthDate)\" to a readable date.")
            }
            let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            contact.birthday = components
        }
        
        contact.postalAddresses = [CNLabeledValue(label: CNLabelHome, value: homeAddress)]
        
        try ContactHelper.addContact(contact)
        print("Saved contact \"\(saveOpts.firstName)\"")
    }
}


struct delete: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        abstract: "Deletes a Contact with the specified name"
    )
    
    @Argument(help: "The name of Contact to delete")
    var name: String
    
    func run() throws {
        // the contact(s) that match the specified name
        let contacts = try ContactHelper.getContacts(withName: name, KeysToFetch: AllContactKeys)
        
        guard !contacts.isEmpty else {
            throw ValidationError("No contact with the name \"\(name)\" found")
        }
        
        var contactToDelete: CNContact
        // if more than one contact with the name exists, ask which one to use
        if contacts.count > 1 {
            let range = 0...contacts.count - 1
            print("Multiple Contacts with the name \"\(name)\" found, which would you like to use?")
            for i in range {
                print("[\(i)] \(contacts[i].givenName), Identifier: \(contacts[i].identifier)")
            }
            
            guard let input = readLine(), let inputInt = Int(input), range ~= inputInt else {
                throw ValidationError("User must input a number between 0 and \(contacts.count - 1)")
            }
            
            contactToDelete = contacts[inputInt]
        } else {
            // otherwise if theres only one contact with the provided name
            // use that contact
            contactToDelete = contacts.first!
        }
        
        try ContactHelper.deleteContact(contactToDelete)
        print("Successfully deleted Contact")
    }
}
