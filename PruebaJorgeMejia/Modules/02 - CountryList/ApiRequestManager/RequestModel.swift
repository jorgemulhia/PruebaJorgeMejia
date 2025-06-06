//
//  RequestModel.swift
//  PruebaJorgeMejia
//
//  Created by Jorge Mulhia on 6/5/25.
//

import Foundation
import MapKit

struct ResponseModel: Codable, Equatable, Identifiable {
    var idPais: String
    var nombrePais: String?
    
    var idEstado: String?
    var estadoNombre: String?
    var coordenadas: String?
    
    // para tener un id<Int> para los markers del mapa, porque sino no permite seleccionarlo
    var id: Int {
        return Int(idEstado ?? "0") ?? 0
    }
    
    // convertir el string de coordenadas en coordinates
    var getCoordinates: CLLocationCoordinate2D {
        let coordinates = coordenadas?.split(separator: ", ")
        return CLLocationCoordinate2D(
            latitude: Double(coordinates?.first ?? "0") ?? 0,
            longitude: Double(coordinates?.last ?? "0") ?? 0
        )
    }
    
    static func == (lhs: ResponseModel, rhs: ResponseModel) -> Bool {
        return lhs.id == rhs.id
    }
}
