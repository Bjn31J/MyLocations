//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 20/10/23.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
// Marca la clase `Location` como accesible desde Objective-C.

public class Location: NSManagedObject, MKAnnotation {
    // Declara la clase `Location` como subclase de NSManagedObject y adopta el protocolo MKAnnotation.

    public var coordinate: CLLocationCoordinate2D {
        // Implementa la propiedad `coordinate` del protocolo MKAnnotation.
        return CLLocationCoordinate2DMake(latitude, longitude)
        // Retorna la coordenada como un objeto CLLocationCoordinate2D utilizando las propiedades `latitude` y `longitude`.
    }

    public var title: String? {
        // Implementa la propiedad `title` del protocolo MKAnnotation.
        if locationDescription.isEmpty {
            return "(No Description)"
            // Si la descripción de la ubicación está vacía, retorna un mensaje indicando que no hay descripción.
        } else {
            return locationDescription
            // Si hay una descripción, la retorna como el título de la ubicación.
        }
    }

    public var subtitle: String? {
        // Implementa la propiedad `subtitle` del protocolo MKAnnotation.
        return category
        // Retorna la categoría como el subtítulo de la ubicación.
    }
}


