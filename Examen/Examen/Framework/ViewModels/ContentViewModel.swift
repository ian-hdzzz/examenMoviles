//
//  ContentViewModel.swift
//  Examen
//
//  Created by Ian Hernandez on 27/11/25.
//
import Foundation

class ContentViewModel: ObservableObject {
    @Published var countryList = [CountryDetail]()
    var countryListRequirement: CountryListRequirementProtocol
    var countryInfoRequirement: CountryInfoRequirementProtocol

    init(countryListRequirement: CountryListRequirementProtocol = CountryListRequirement.shared,
         countryInfoRequirement: CountryInfoRequirementProtocol = CountryInfoRequirement.shared) {
        self.countryListRequirement = countryListRequirement
        self.countryInfoRequirement = countryInfoRequirement
    }

    @MainActor
    func getCountriesList(date: String) async {
        guard let countries = await countryListRequirement.getCountryList(date: date) else { return }
        for country in countries {
            if let infoCountry = await countryInfoRequirement.getCountryInfo(country: country.country) {
                self.countryList.append(infoCountry)
            }
        }
    }
}
