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
    
    var hasPhoto: Bool {
        // Devuelve true si la propiedad opcional photoID tiene un valor, indicando que hay una foto asociada.
        return photoID != nil
    }

    
    var photoURL: URL {
        // Asegura que la propiedad opcional photoID tenga un valor, lo que indica que hay una foto asociada.
        assert(photoID != nil, "No photo ID set")
        
        // Crea el nombre de archivo utilizando el ID de la foto.
        let filename = "Photo-\(photoID!.intValue).jpg"
        
        // Devuelve la URL completa de la foto utilizando el directorio de documentos de la aplicación.
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }

    
    var photoImage: UIImage? {
        // Devuelve una instancia de UIImage utilizando el contenido del archivo en la URL de la foto.
        return UIImage(contentsOfFile: photoURL.path)
    }

    
    class func nextPhotoID() -> Int {
        // Accede a UserDefaults para obtener el ID de la foto actual almacenado.
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID") + 1
        
        // Incrementa el ID de la foto y lo guarda en UserDefaults para su uso futuro.
        userDefaults.set(currentID, forKey: "PhotoID")
        
        // Devuelve el nuevo ID de la foto.
        return currentID
    }

    
    func removePhotoFile() {
        // Verifica si la ubicación tiene una foto antes de intentar eliminarla.
        if hasPhoto {
            do {
                // Intenta eliminar el archivo de la foto en el directorio de documentos de la aplicación.
                try FileManager.default.removeItem(at: photoURL)
            } catch {
                // Maneja cualquier error que ocurra durante la eliminación del archivo.
                print("Error removing file: \(error)")
            }
        }
    }

    
    
}


