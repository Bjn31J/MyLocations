//
//  String+AddText.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 10/01/24.
//

import Foundation

extension String {
    mutating func add(
        text: String?,
        separatedBy separator: String = ""
    ) {
        // Verifica si hay un texto para agregar.
        if let text = text {
            // Verifica si la cadena actual no está vacía.
            if !isEmpty {
                // Agrega el separador si la cadena no está vacía.
                self += separator
            }
            // Agrega el nuevo texto a la cadena.
            self += text
        }
    }
}

