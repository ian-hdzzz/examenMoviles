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
    
    @State private var selectedCountry: CountryDetail? = nil

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(contentViewModel.countryList, id: \ .country) { countryDetail in
                    Button(action: {
                        selectedCountry = countryDetail
                    }) {
                        HStack(spacing: 16) {
                            // Si tienes URL de bandera, puedes mostrarla aquí
                            /*WebImage(url: URL(string: countryDetail.flagURL ?? ""))
                                .resizable()
                                .placeholder(Image(systemName: "photo"))
                                .frame(width: 40, height: 28)
                                .cornerRadius(6)*/
                            VStack(alignment: .leading, spacing: 4) {
                                Text(countryDetail.country)
                                    .font(.headline)
                                Text(countryDetail.region)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .onAppear {
            Task {
                await contentViewModel.getCountriesList(date: "2022-01-01")
            }
        }
        .sheet(item: $selectedCountry) { country in
            CountryDetailSheet(country: country)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - CountryDetailSheet
struct CountryDetailSheet: View {
    let country: CountryDetail

    var body: some View {
        VStack(spacing: 24) {
            // Si tienes URL de bandera, puedes mostrarla aquí
            /*WebImage(url: URL(string: country.flagURL ?? ""))
                .resizable()
                .frame(width: 80, height: 56)
                .cornerRadius(8)*/
            Text(country.country)
                .font(.largeTitle)
                .bold()
            Text("Región: \(country.region)")
                .font(.title2)
                .foregroundColor(.gray)
            // Agrega más detalles si tienes más propiedades
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}


