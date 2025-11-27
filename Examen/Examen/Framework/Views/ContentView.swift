//
//  ContentView.swift
//  Examen
//
//  Created by Ian Hernandez on 27/11/25.
//
import SwiftUI
import SDWebImageSwiftUI


import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    @StateObject var contentViewModel = ContentViewModel()
    
    var body: some View {
        List(contentViewModel.countryList, id: \ .country) { countryDetail in
            HStack {
                Text(countryDetail.country)
                Spacer()
                Text(countryDetail.region)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            Task {
                await contentViewModel.getCountriesList(date: "2022-01-01") // Ajusta la fecha según lo que necesites
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}


