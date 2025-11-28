//
//  NetworkAPIService.swift
//  Examen
//
//  Created by Ian Hernandez on 27/11/25.
//


import Foundation
import Alamofire
class NetworkAPIService {
    static let shared = NetworkAPIService()
    
    func getCountries(date: String) async -> Countries? {
        let url = URL(string: "https://api.api-ninjas.com/v1/covid19")!
        let parameters : Parameters = [
            "date" : date
        ]
        let headers: HTTPHeaders = [
            "X-Api-Key": "Iyj8fFqpJmVbLcWFjY/a8A==k1a8GcVr300NZRXv"
        ]
        let taskRequest = AF.request(url, method: .get, parameters: parameters, headers: headers).validate()
        let response = await taskRequest.serializingData().response

        switch response.result {
        case .success(let data):
            do {
                print("Respuesta cruda de la API: ", String(data: data, encoding: .utf8) ?? "")
                let allCountries = try JSONDecoder().decode(Countries.self, from: data)
                let randomCountries = Array(allCountries.shuffled().prefix(30))
                return randomCountries
            } catch {
                print("Error decodificando Countries: \(error)")
                return nil
            }
        case let .failure(error):
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    func getCountryInfo(country: String) async -> CountryDetail? {
        let url = URL(string: "https://api.api-ninjas.com/v1/covid19")!
        let parameters: Parameters = [
            "country": country
        ]
        let headers: HTTPHeaders = [
            "X-Api-Key": "Iyj8fFqpJmVbLcWFjY/a8A==k1a8GcVr300NZRXv"
        ]
        let taskRequest = AF.request(url, method: .get, parameters: parameters, headers: headers).validate()
        let response = await taskRequest.serializingData().response

        switch response.result {
        case .success(let data):
            do {
                let decodedArray = try JSONDecoder().decode([CountryDetail].self, from: data)
                print("CountryDetail decodificado:", decodedArray)
                return decodedArray.first
            } catch {
                print("Error decodificando CountryDetail:", error)
                return nil
            }
        case let .failure(error):
            debugPrint(error.localizedDescription)
            return nil
        }
    }

}


