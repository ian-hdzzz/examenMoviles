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
    @State private var showSuccess: Bool = false
    @State private var searchText: String = ""
    @State private var hoveredCountry: String? = nil
    @State private var tappedCountry: String? = nil

    var filteredCountries: [CountryDetail] {
        let all = contentViewModel.countryList.filter {
            ($0.cases.values.first?.total ?? 0) > 0 &&
            (searchText.isEmpty || $0.country.localizedCaseInsensitiveContains(searchText))
        }
        
        if all.count > 20 {
            let start = (all.count - 20) / 2
            return Array(all[start..<(start+20)])
        } else {
            return all
        }
    }


    let lastCountryKey = "lastCountryViewed"

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
                .frame(height: 260)
                .padding(.horizontal)
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel() {
                            if let country = value.as(String.self) {
                                Text(country)
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .frame(width: 60)
                                    .rotationEffect(.degrees(-45))
                            }
                        }
                    }
                }
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
                            showSuccess = false
                            // Guardamos país en UserDefaults
                            UserDefaults.standard.set(countryDetail.country, forKey: lastCountryKey)
                            Task {
                        if let info = await contentViewModel.countryInfoRequirement.getCountryInfo(country: countryDetail.country) {
                            selectedCountry = info
                            showSuccess = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showSuccess = false
                            }
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
            } else if showSuccess {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Label("Datos cargados", systemImage: "checkmark.circle")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    Spacer()
                }
                .background(Color.green.opacity(1))
                .cornerRadius(16)
                .padding(5)
                .frame(maxWidth: 270, maxHeight: 20)
                .transition(.opacity)
            }
        }
        .onAppear {
            Task {
                await contentViewModel.getCountriesList(date: "2022-01-01")
                // Leemos el país guardado y lo mostramos
                if let lastCountry = UserDefaults.standard.string(forKey: lastCountryKey), !lastCountry.isEmpty {
                    searchText = lastCountry
                    // Buscamos el objeto CountryDetail en la lista completa
                    let allCountries = contentViewModel.countryList.filter { ($0.cases.values.first?.total ?? 0) > 0 }
                    if let found = allCountries.first(where: { $0.country.localizedCaseInsensitiveCompare(lastCountry) == .orderedSame }) {
                        // Consultamos detalles y mostrar modal automáticamente
                        isLoadingDetail = true
                        showSuccess = false
                        if let info = await contentViewModel.countryInfoRequirement.getCountryInfo(country: found.country) {
                            selectedCountry = info
                            showSuccess = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showSuccess = false
                            }
                        } else {
                            selectedCountry = found
                        }
                        isLoadingDetail = false
                    }
                }
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
    @State private var startYear: String = "2020"
    @State private var startMonth: String = "02"
    @State private var endYear: String = "2023"
    @State private var endMonth: String = "12"

    var availableYears: [String] {
        ["2020", "2021", "2022", "2023"]
    }
    var availableMonths: [String] {
        ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    }

    var filteredDates: [String] {
        let start = "\(startYear)-\(startMonth)"
        let end = "\(endYear)-\(endMonth)"
        return country.cases.keys.filter { date in
            date >= start && date <= end
        }.sorted()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(country.country)
                    .font(.largeTitle)
                    .bold()
                Text("Región: \(country.region.isEmpty ? "Sin región" : country.region)")
                    .font(.title2)
                    .foregroundColor(.gray)

                Text("Casos de COVID-19 en el tiempo")
                    .font(.headline)
                    .padding(.top, 8)
                Text("De \(startYear)-\(startMonth) a \(endYear)-\(endMonth)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                if !country.cases.isEmpty {
                    if !filteredDates.isEmpty {
                        Chart(filteredDates, id: \ .self) { date in
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
                    Text("Filtrar por rango de fechas:")
                        .font(.headline)
                        .padding(.top)
                    VStack(spacing: 8) {
                        HStack {
                            Text("Desde:")
                                .font(.subheadline)
                            Spacer()
                        }
                        HStack {
                            Picker("Año inicio", selection: $startYear) {
                                ForEach(availableYears, id: \ .self) { year in
                                    Text(year).tag(year)
                                }
                            }
                            .pickerStyle(.menu)
                            Picker("Mes inicio", selection: $startMonth) {
                                ForEach(availableMonths, id: \ .self) { month in
                                    Text(month).tag(month)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        HStack {
                            Text("Hasta:")
                                .font(.subheadline)
                            Spacer()
                        }
                        HStack {
                            Picker("Año fin", selection: $endYear) {
                                ForEach(availableYears, id: \ .self) { year in
                                    Text(year).tag(year)
                                }
                            }
                            .pickerStyle(.menu)
                            Picker("Mes fin", selection: $endMonth) {
                                ForEach(availableMonths, id: \ .self) { month in
                                    Text(month).tag(month)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .padding(.horizontal)

                    if !filteredDates.isEmpty {
                        // Agrupamos por mes
                        let groupedByMonth = Dictionary(grouping: filteredDates) { date in
                            String(date.prefix(7)) 
                        }
                        Text("Detalle por mes")
                            .font(.headline)
                            .padding(.top, 8)
                        ForEach(groupedByMonth.keys.sorted(), id: \ .self) { month in
                            let monthDates = groupedByMonth[month] ?? []
                            let total = monthDates.compactMap { country.cases[$0]?.total }.reduce(0, +)
                            let nuevos = monthDates.compactMap { country.cases[$0]?.new }.reduce(0, +)
                            HStack {
                                Text(month)
                                    .font(.caption)
                                Spacer()
                                Text("Total: \(total)")
                                    .font(.caption)
                                Text("Nuevos: \(nuevos)")
                                    .font(.caption)
                            }
                            .padding(.vertical, 2)
                        }
                    } else {
                        Text("No hay datos para el filtro seleccionado.")
                            .foregroundColor(.gray)
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


