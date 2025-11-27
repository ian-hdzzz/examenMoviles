//
//  CountryListProtocol.swift
//  Examen
//
//  Created by Ian Hernandez on 27/11/25.
//

//
//   PokemonInfoRequirement.swift
//  Lab2_Pokedex
//
//  Created by Ian Hernandez on 18/11/25.
//

protocol CountryListRequirementProtocol {
    func getCountryList(date: String) async -> [Country]?
}

class CountryListRequirement: CountryListRequirementProtocol {
    let dataRepository: CountriesRepository
    static let shared = CountryListRequirement()
    
    init(dataRepository: CountriesRepository = CountriesRepository.shared) {
        self.dataRepository = dataRepository
    }

    func getCountryList(date: String) async -> [Country]? {
        return await dataRepository.getCountriesList(date: date)
    }
}
