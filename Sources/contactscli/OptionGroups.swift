import ArgumentParser
import Foundation

/// The Options available to the user when saving a Contact
struct saveOptions: ParsableArguments {
    @Option(help: "The First Name of the Contact to save")
    var firstName: String
    
    @Option(help: "The Middle Name of the Contact to save")
    var middleName: String?
    
    @Option(help: "The Family Name of the Contact to save")
    var familyName: String?
    
    @Option(help: "The Nickname of the Contact to save")
    var nickname: String?
    
    @Option(help: "A Note to save of the Contact to save")
    var note: String?
    
    @Option(help: "The Job Title of the Contact to save")
    var jobTitle: String?
    
    @Option(help: "The Department Name of the Contact to save")
    var departmentName: String?
    
    @Option(help: "The Work Email of the Contact to save")
    var workEmail: String?
    
    @Option(help: "The Home Email of the Contact to save")
    var homeEmail: String?
    
    @Option(help: "The Street Address of the Contact to save")
    var street: String?
    
    @Option(help: "The City of the Contact to save")
    var city: String?
    
    @Option(help: "The State of the Contact to save")
    var state: String?
    
    @Option(help: "The Country of the Contact to save")
    var country: String?
    
    @Option(help: "The Path of the Image to set for the Contact to save")
    var imagePath: String?
    
    @Option(help: "The Birthdate of the Contact to save")
    var birthDate: String?
    
    @Option(help: "The Date Format to use if setting the Birthdate")
    var dateFormat: String = "dd/mm/yy"
}
