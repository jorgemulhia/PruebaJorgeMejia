//
//  XMLParser.swift
//  PruebaJorgeMejia
//
//  Created by Jorge Mulhia on 6/5/25.
//

import Foundation

// MARK: - ResponseXMLParser
// la idea es hacerlo genérico
// que se puedan inyectar los valores de los keys, para que primero lo haga un diccionario
// una vez que tiene el diccionario, pasarlo al generico <T>
final class ResponseXMLParser<T: Codable>: NSObject, XMLParserDelegate {
    
    // MARK: - Variables
    
    // las keys del response
    private var responseKeys: [String]
    private var codingKeys: [String]
    
    private var dict: [[String: Any]] = []
    private var currentElement = ""
    private var currentValue: [String: Any] = [:]
    
    // un pequeño parche para que pueda responder de manera asyncrona
    private var continuation: CheckedContinuation<T, Never>?
    
    // MARK: - init
    
    init(responseKeys: [String], codingKeys: [String]) {
        self.responseKeys = responseKeys
        self.codingKeys = codingKeys
    }
    
    // MARK: - Parser

    func parse(data: Data) async -> T {
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
    }

    // MARK: - XMLParser delegate

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // esto es para checar si hay coincidencias en el array de keys, y en caso de que si, agregarlas al diccionario
        if codingKeys.contains(currentElement) {
            currentValue[currentElement.lowercaseFirstLetter()] = string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        
        // agregar el diccionario al array
        if responseKeys.contains(elementName) {
            dict.append(currentValue)
            
            currentValue = [:]
            currentElement = ""
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        // pasar el diccionario a [ResponseModel]
        guard let json = try? JSONSerialization.data(withJSONObject: dict) else {
            return
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        if let values = try? decoder.decode(T.self, from: json) {
            continuation?.resume(returning: values)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Error de parseo: \(parseError)")
    }
}

private extension String {
    
    // extension para convertir el key del diccionario y poder mapearlo a ResponseModel
    func lowercaseFirstLetter() -> String {
        guard let first = self.first else {
            return self
        }
        return first.lowercased() + self.dropFirst()
    }
}
