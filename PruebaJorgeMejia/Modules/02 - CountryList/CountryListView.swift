//
//  CountryListView.swift
//  PruebaJorgeMejia
//
//  Created by Jorge Mulhia on 6/5/25.
//

import Foundation
import SwiftUI

struct CountryListView: View {
    
    // MARK: - Variables
    
    // manager para los requests
    @StateObject private var apiRequestViewModel = ApiRequestViewModel()
    @State private var countries: [ResponseModel] = []
    @State private var selectedCountry: ResponseModel?
    @State private var showStateInfo: Bool = false
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            Color.background
            
            VStack {
                if apiRequestViewModel.status == .loading {
                    // loader
                    Text("Cargando paises...")
                        .font(.custom("FiraSans-Light", size: 20))
                        .foregroundColor(Color.primary)
                } else if !countries.isEmpty {
                    // se muestra la lista una vez que se cargaron los paises
                    countriesListView()
                }
            }
            .padding(40)
        }
        .ignoresSafeArea()
        .navigationTitle("Lista de paises")
        .task {
            // hacer el request al moemnto que se carga la pantalla
            do {
                let response = try await apiRequestViewModel.request(.getCountries)
                countries = response
            } catch(let error) {
                print(error)
            }
        }
        .sheet(isPresented: $showStateInfo) {
            StateDetailView(selectedCountry: selectedCountry)
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Private
    
    private func countriesListView() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: "map.circle")
                .font(.system(size: 70))
                .foregroundColor(.primary)
                .opacity(0.4)
                .padding(.top, 50)
                .padding(.bottom, 20)
            
            Text("Lista de países:")
                .font(.custom("FiraSans-Light", size: 26))
                .foregroundColor(Color.primary)
            
            ScrollView {
                ForEach(countries, id: \.idPais) { item in
                    CountryListItemView(
                        id: item.idPais,
                        name: item.nombrePais ?? "") {
                            selectedCountry = item
                            showStateInfo.toggle()
                        }
                }
            }
            .multilineTextAlignment(.leading)
        }
        .padding(30)
    }
    
    // vista para la lista de paises
    struct CountryListItemView: View {
        var id: String
        var name: String
        var action: () -> Void
        
        var body: some View {
            HStack {
                Image(systemName: "arrow.right")
                    .foregroundColor(.primary)
                
                Text(name)
                    .font(.custom("FiraSans-SemiBold", size: 22))
                    .foregroundColor(Color.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(5)
            .onTapGesture {
                action()
            }
        }
    }
}

// MARK: - Preview

struct CountryListView_Previews: PreviewProvider {
    static var previews: some View {
        CountryListView()
    }
}
