//
//  ApiRequestManager.swift
//  PruebaJorgeMejia
//
//  Created by Jorge Mulhia on 6/5/25.
//

import Foundation

enum LoaderStatus {
    case loading
    case loaded
}

enum ApiRequestManagerError: Error {
    case invalidUrl
    case invalidResponse
    case decodingError
    case invalidRequest(error: Error)
}

enum ApiRequestManagerEndpoint {
    case getCountries
    case getStates
    
    var host: String {
        return "https://servicesoap.azurewebsites.net"
    }
    
    var url: String {
        switch self {
        case .getCountries:
            return "\(host)/ws/Paises.asmx?op=GetPaises"
        case .getStates:
            return "\(host)/ws/Paises.asmx?op=GetEstadosbyPais"
        }
    }
    
    var xmlRequest: String {
        switch self {
        case .getCountries:
            return """
        <?xml version="1.0" encoding="utf-8"?>
        <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
          <soap12:Body>
            <GetPaises xmlns="http://tempuri.org/" />
          </soap12:Body>
        </soap12:Envelope>
        """
        case .getStates:
            return """
        <?xml version="1.0" encoding="utf-8"?>
        <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
          <soap12:Body>
            <GetEstadosbyPais xmlns="http://tempuri.org/">
              <idEstado>int</idEstado>
            </GetEstadosbyPais>
          </soap12:Body>
        </soap12:Envelope>
        """
        }
    }
}

@MainActor
final class ApiRequestViewModel: ObservableObject {
    
    @Published var status: LoaderStatus = .loaded
    
    func request(_ type: ApiRequestManagerEndpoint) async throws -> [ResponseModel] {
        
        status = .loading
        
        // validar si es una url válida
        guard let url = URL(string: type.url) else {
            status = .loaded
            throw ApiRequestManagerError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = type.xmlRequest.data(using: .utf8)

//        request.setValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
//        request.setValue(String(soapV1Message.count), forHTTPHeaderField: "Content-Length")
//        request.setValue("http://tempuri.org/GetPaises", forHTTPHeaderField: "SOAPAction")
        request.setValue("application/soap+xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("length", forHTTPHeaderField: "Content-Length")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                status = .loaded
                throw ApiRequestManagerError.invalidResponse
            }
            
            let parser = ResponseXMLParser<[ResponseModel]>(
                responseKeys: ["Pais", "Estado"],
                codingKeys: ["idPais", "NombrePais", "idEstado", "EstadoNombre", "Coordenadas"]
            )
            let values = await parser.parse(data: data)
            status = .loaded
            return values
        } catch(let error) {
            status = .loaded
            throw ApiRequestManagerError.invalidRequest(error: error)
        }
    }
}
