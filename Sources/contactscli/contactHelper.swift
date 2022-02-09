import Contacts

/// A Structure containing Helper methods for Contacts
struct ContactHelper {
    
    /// Returns all User Contacts as an array of CNContacts
    static func getAllContacts(withFormatterStyle formatterStyle: CNContactFormatterStyle = .fullName, keysToFetch keys: [CNKeyDescriptor]) throws -> [CNContact] {
        let request = CNContactFetchRequest(keysToFetch: keys)
        let contactStore = CNContactStore()
        var contacts: [CNContact] = []
        try contactStore.enumerateContacts(with: request) { contact, _ in
            contacts.append(contact)
        }
        return contacts
    }
    
    /// Deletes a specified Contact
    static func deleteContact(_ contact: CNContact) throws {
        let request = CNSaveRequest()
        let store = CNContactStore()
        let mutableCopy = contact.mutableCopy() as! CNMutableContact
        
        request.delete(mutableCopy)
        try store.execute(request)
    }
    
    /// Adds a new Contact
    static func addContact(_ contact: CNMutableContact) throws {
        let store = CNContactStore()
        let request = CNSaveRequest()
        
        request.add(contact, toContainerWithIdentifier: nil)
        try store.execute(request)
    }
    
    /// Get Contacts with a specified name
    static func getContacts(withName name: String, KeysToFetch keys: [CNKeyDescriptor]) throws -> [CNContact] {
        let store = CNContactStore()
        let predicate = CNContact.predicateForContacts(matchingName: name)
        let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keys)
        return contacts
    }
    
    static func formatContactInfo(fromContact contact: CNContact, hideUnavailable: Bool) -> [String: String] {
        var dict = [
            "Given Name": contact.givenName,
            "Family Name": contact.familyName,
            "Middle Name": contact.middleName,
            "Job Title": contact.jobTitle,
            "Department Name": contact.departmentName,
            "Note": contact.note,
            "Nickname": contact.nickname
        ]
        
        for PostalInfo in contact.postalAddresses {
            let value = PostalInfo.value
            let PostalInfoDict = [value.country, value.street, value.state, value.postalCode, value.city, value.subLocality].filter {
                !$0.isEmpty
            }
            dict["Postal Info"] = PostalInfoDict.joined(separator: ", ")
        }
        
        var finalDict: [String: String] {
            if hideUnavailable {
                return dict.filter { !$0.value.isEmpty }
            } else {
                return dict.mapValues { $0.isEmpty ? "(Not Available)" : $0 }
            }
        }
        
        return finalDict
    }
}
