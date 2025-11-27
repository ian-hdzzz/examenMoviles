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
        guard let countries = await countryListRequirement.getCountryList(date: date) else {
            print("No se obtuvieron países de la API")
            return
        }
        // Convertimos cada Country a CountryDetail usando solo los datos disponibles.
        self.countryList = countries.map { country in
            CountryDetail(country: country.country, region: country.region, cases: [date: CountryCasesByDate(total: country.cases.total, new: country.cases.new)])
        }
        print("Países mostrados:", self.countryList)
    }
}
