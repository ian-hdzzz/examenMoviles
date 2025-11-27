//
//  CountryInfoProtocol.swift
//  Examen
//
//  Created by Ian Hernandez on 27/11/25.
//


protocol CountryInfoRequirementProtocol {
    func getCountryInfo(country: String) async -> CountryDetail?
}

class CountryInfoRequirement: CountryInfoRequirementProtocol {
    let dataRepository: CountriesRepository
    static let shared = CountryInfoRequirement()
    
    init(dataRepository: CountriesRepository = CountriesRepository.shared) {
        self.dataRepository = dataRepository
    }

    func getCountryInfo(country: String) async -> CountryDetail? {
        return await dataRepository.getCountryInfo(country: country)
    }
}
