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
    
    func getCountries(url: URL, date: String) async -> Countries? {
        let parameters : Parameters = [
            "date" : date
        ]
            
        let taskRequest = AF.request(url, method: .get, parameters: parameters).validate()
        let response = await taskRequest.serializingData().response

        switch response.result {
        case .success(let data):
            do {
                return try JSONDecoder().decode(Countries.self, from: data)
            } catch {
                return nil
            }
        case let .failure(error):
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    func getCountryInfo(url: URL) async -> CountryDetail? {

        let taskRequest = AF.request(url, method: .get).validate()
        let response = await taskRequest.serializingData().response

        switch response.result {
        case .success(let data):
            do {
                return try JSONDecoder().decode(CountryDetail.self, from: data)
            } catch {
                return nil
            }
        case let .failure(error):
            debugPrint(error.localizedDescription)
            return nil
        }
    }

}


