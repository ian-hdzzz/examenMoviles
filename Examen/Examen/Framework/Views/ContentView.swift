//
//  ContentView.swift
//  Examen
//
//  Created by Ian Hernandez on 27/11/25.
//
import SwiftUI
import SDWebImageSwiftUI
import Charts


import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    @StateObject var contentViewModel = ContentViewModel()
    
    @State private var selectedCountry: CountryDetail? = nil
    @State private var isLoadingDetail: Bool = false
    @State private var searchText: String = ""

    var filteredCountries: [CountryDetail] {
        contentViewModel.countryList.filter {
            ($0.cases.values.first?.total ?? 0) > 0 &&
            (searchText.isEmpty || $0.country.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Casos totales de COVID-19 por país")
                .font(.title2)
                .bold()
                .padding(.top)
            TextField("Buscar país...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            if !filteredCountries.isEmpty {
                Chart(filteredCountries) { country in
                    BarMark(
                        x: .value("País", country.country),
                        y: .value("Casos", country.cases.values.first?.total ?? 0)
                    )
                    .foregroundStyle(.blue)
                }
                .frame(height: 220)
                .padding(.horizontal)
            } else {
                Text("No hay países con datos para mostrar.")
                    .foregroundColor(.gray)
                    .padding()
            }
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredCountries, id: \ .country) { countryDetail in
                        Button(action: {
                            isLoadingDetail = true
                            Task {
                                if let info = await contentViewModel.countryInfoRequirement.getCountryInfo(country: countryDetail.country) {
                                    selectedCountry = info
                                } else {
                                    selectedCountry = countryDetail 
                                }
                                isLoadingDetail = false
                            }
                        }) {
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(countryDetail.country)
                                        .font(.headline)
                                    Text(countryDetail.region)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                if let total = countryDetail.cases.values.first?.total, total > 0 {
                                    Text("Casos: \(total)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
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
        }
        .overlay {
            if isLoadingDetail {
                ProgressView("Cargando detalles...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
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

struct CountryDetailSheet: View {
    let country: CountryDetail

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(country.country)
                    .font(.largeTitle)
                    .bold()
                Text("Región: \(country.region)")
                    .font(.title2)
                    .foregroundColor(.gray)

                if !country.cases.isEmpty {
                    Text("Casos por fecha:")
                        .font(.headline)
                        .padding(.top)
                    if country.cases.count > 1 {
                        Chart(Array(country.cases.keys.sorted()), id: \ .self) { date in
                            if let data = country.cases[date] {
                                BarMark(
                                    x: .value("Fecha", date),
                                    y: .value("Casos", data.total)
                                )
                                .foregroundStyle(.blue)
                            }
                        }
                        .frame(height: 180)
                        .padding(.horizontal)
                    }
                    ForEach(country.cases.keys.sorted(), id: \ .self) { date in
                        if let data = country.cases[date] {
                            HStack {
                                Text(date)
                                    .font(.caption)
                                Spacer()
                                Text("Total: \(data.total)")
                                    .font(.caption)
                                Text("Nuevos: \(data.new)")
                                    .font(.caption)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                } else {
                    Text("No hay datos de casos para este país.")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}


