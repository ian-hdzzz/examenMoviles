//
//  CountriesRepository.swift
//  Examen
//
//  Created by Ian Hernandez on 27/11/25.
//

import Foundation

struct Api {
    static let base = "https://api.api-ninjas.com/v1/covid19?=&="
        
    struct routes {
        static let countries = "/countries"
        static let x_Api_Key = "/X-Api-Key"
        static let date = "/date"
    }
}

protocol CountriesAPIProtocol {
    //https://api.api-ninjas.com/v1/covid19?X-Api-Key=Iyj8fFqpJmVbLcWFjY/a8A==k1a8GcVr300NZRXv&date=2022-01-01
    func getCountriesList(date: String) async -> Countries?
    //https://api.api-ninjas.com/v1/covid19?X-Api-Key=Iyj8fFqpJmVbLcWFjY/a8A==k1a8GcVr300NZRXv&country=canada
    func getCountryInfo(country: String) async -> CountryDetail?
}

class CountriesRepository: CountriesAPIProtocol {
    let nservice: NetworkAPIService
    static let shared = CountriesRepository()

    init(nservice: NetworkAPIService = NetworkAPIService.shared) {
            self.nservice = nservice
        }

    func getCountriesList(date: String) async -> Countries? {
        return await nservice.getCountries(date: date)
    }

    func getCountryInfo(country: String) async -> CountryDetail? {
        return await nservice.getCountryInfo(url: URL(string:"\(Api.base)\(Api.routes.countries)/\(country)")!)
    }
}
