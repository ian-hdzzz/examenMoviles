//
//  Covid.swift
//  Examen
//
//  Created by Ian Hernandez on 27/11/25
//

import Foundation

struct CountryCases: Codable {
    let total: Int
    let new: Int
}

struct Country: Codable {
    let country: String
    let region: String
    let cases: CountryCases
}

typealias Countries = [Country]

struct CountryCasesByDate: Codable {
    let total: Int
    let new: Int
}

struct CountryDetail: Codable, Identifiable {
    let country: String
    let region: String
    let cases: [String: CountryCasesByDate]
    var id: String { country }
}

