//
//  StateDetailView.swift
//  PruebaJorgeMejia
//
//  Created by Jorge Mulhia on 6/5/25.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

struct StateDetailView: View {
    
    // MARK: - Variables
    
    @State var selectedCountry: ResponseModel?
    
    // manager para los requests
    @StateObject private var apiRequestViewModel = ApiRequestViewModel()
    
    @State private var states: [ResponseModel] = []
    @Environment(\.dismiss) private var dismiss
    
    // el id del pin seleccionado
    @State private var selection: Int?
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            Color.background
            
            VStack {
                if apiRequestViewModel.status == .loading {
                    Text("Cargando estados...")
                        .font(.custom("FiraSans-Light", size: 20))
                        .foregroundColor(Color.primary)
                } else {
                    mapView()
                }
            }
            
            // boton de cerrar
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 25))
                            .foregroundColor(.primary)
                    }
                }
                Spacer()
            }
            .padding(25)
        }
        .ignoresSafeArea()
        .navigationTitle("Detalle")
        .task {
            // hacer el request al moemnto que se carga la pantalla
            do {
                let response = try await apiRequestViewModel.request(
                    .getStates,
                    selectedCountry: selectedCountry?.idPais ?? "1"
                )
                states = response
            } catch(let error) {
                print(error)
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Private
    
    private func mapView() -> some View {
        ZStack {
            Map(selection: $selection) {
                ForEach(states, id: \.orderId) { location in
                    Marker(
                        location.estadoNombre ?? "",
                        coordinate: location.getCoordinates
                    )
                    .tint(Color.secondary)
                }
            }
            .onChange(of: selection) {
                guard let selection else { return }
                guard let item = states.first(where: { $0.orderId == selection }) else { return }
                print(String(describing: item.coordenadas))
            }
            .mapStyle(.standard(emphasis: .automatic, pointsOfInterest: .excludingAll))
            
            VStack {
                Spacer()
                HStack {
                    if let selection,
                       let item = states.first(where: { $0.orderId == selection }) {
                        
                        // para mostrar la info y el street view
                        withAnimation {
                            MapPreviewInfoView(
                                info: item,
                                countryName: selectedCountry?.nombrePais ?? ""
                            )
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(25)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial)
            }
        }
        .ignoresSafeArea()
    }
    
    // vista para la lista
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
        }
    }
}

// MARK: - Preview

struct StateDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StateDetailView(selectedCountry: ResponseModel(idPais: "1", nombrePais: "Mexico"))
    }
}

// MARK: - MapPreviewInfoView
// vista para mostrar el street view del punto seleccionado
struct MapPreviewInfoView: View {
    @State private var lookAroundView: MKLookAroundScene?
    var info: ResponseModel
    var countryName: String
    
    var body: some View {
        ZStack {
            
            // el street view
            LookAroundPreview(
                initialScene: lookAroundView,
                showsRoadLabels: true,
                pointsOfInterest: .all)
            .onAppear {
                refreshLookAroundView()
            }
            .onChange(of: info) {
                refreshLookAroundView()
            }
            
            // la información del marker
            VStack(spacing: .zero) {
                Spacer()
                VStack(alignment: .leading) {
                    Text(countryName)
                        .font(.custom("FiraSans-Regular", size: 15))
                    
                    Text(info.estadoNombre ?? "")
                        .font(.custom("FiraSans-SemiBold", size: 15))
                    
                    Text(info.coordenadas ?? "")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.primary)
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .foregroundStyle(.white)
            .padding(10)
        }
    }
    
    func refreshLookAroundView() {
        lookAroundView = nil
        Task {
            let request = MKLookAroundSceneRequest(coordinate: info.getCoordinates)
            lookAroundView = try? await request.scene
        }
    }
}
