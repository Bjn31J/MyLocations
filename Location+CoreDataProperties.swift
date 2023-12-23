//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 20/10/23.
//
//

import Foundation
import CoreData
import CoreLocation

extension Location {
    // Esta extensión agrega funcionalidad adicional a la clase Location.
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        // Define un método estático llamado fetchRequest() que devuelve una instancia de NSFetchRequest
        // configurada para la entidad "Location".
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    // Declara una propiedad llamada "latitude" que es administrada por Core Data.
    // Esto significa que Core Data se encargará de almacenar y recuperar su valor en la base de datos.
    
    @NSManaged public var longitude: Double
    // Declara una propiedad llamada "longitude" que es administrada por Core Data.
    
    @NSManaged public var date: Date
    // Declara una propiedad llamada "date" que es administrada por Core Data y almacena objetos Date.

    @NSManaged public var locationDescription: String
    // Declara una propiedad llamada "locationDescription" que es administrada por Core Data y almacena cadenas de texto (Strings).

    @NSManaged public var category: String
    // Declara una propiedad llamada "category" que es administrada por Core Data.

    @NSManaged public var placemark: CLPlacemark?
    // Declara una propiedad llamada "placemark" que es administrada por Core Data y puede contener objetos de tipo CLPlacemark.
    
    @NSManaged public var photoID: NSNumber?
    // Identificador de la foto asociado a la ubicación. Puede ser nulo si no hay foto.
    
}


extension Location: Identifiable {
    // Esta extensión indica que la clase Location conforma al protocolo Identifiable.
    
}
