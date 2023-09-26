//
//  LocationsDetailsViewController.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 25/09/23.
//

import UIKit
import CoreLocation


// Declaración de una constante privada llamada dateFormatter que es un objeto DateFormatter
private let dateFormatter: DateFormatter = {
    // Inicia un nuevo objeto DateFormatter utilizando una clausura
    
    let formatter = DateFormatter() // Crea una instancia de DateFormatter
    
    // Establece el estilo de fecha en medio (por ejemplo, "Sep 25, 2023")
    formatter.dateStyle = .medium
    
    // Establece el estilo de tiempo en corto (por ejemplo, "1:30 PM")
    formatter.timeStyle = .short
    
    return formatter // Devuelve el objeto DateFormatter configurado
}() // Llama inmediatamente a la clausura para crear el objeto y asignarlo a la constante


class LocationDetailsViewController: UITableViewController {
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    
    
    var coordinate = CLLocationCoordinate2D(
        latitude: 0,
        longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    
    override func viewDidLoad() {
        // Método que se ejecuta cuando la vista se carga en memoria
        super.viewDidLoad() // Llama al método viewDidLoad() de la clase base
        
        // Línea siguiente: Configuración de la interfaz de usuario
        
        // Borra cualquier texto existente en descriptionTextView
        descriptionTextView.text = ""
        
        // Establece el texto de categoryLabel con el valor de categoryName
        categoryLabel.text = categoryName
        
        // Convierte la latitud (coordinate.latitude) en una cadena con 8 decimales y la muestra en latitudeLabel
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        
        // Convierte la longitud (coordinate.longitude) en una cadena con 8 decimales y la muestra en longitudeLabel
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        // Verifica si placemark tiene un valor (dirección geográfica)
        if let placemark = placemark {
            // Si hay un placemark, muestra la dirección en addressLabel utilizando la función string(from: placemark)
            addressLabel.text = string(from: placemark)
        } else {
            // Si no hay un placemark, muestra "No Address Found" en addressLabel
            addressLabel.text = "No Address Found"
        }
        
        // Formatea la fecha actual (Date()) y la muestra en dateLabel
        dateLabel.text = format(date: Date())
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Método llamado antes de que se realice una transición de vista (por ejemplo, cuando se navega a otra vista)
        
        if segue.identifier == "PickCategory" {
            // Verifica si la identificación del segue es "PickCategory"
            
            // Obtiene una referencia al controlador de vista de destino (CategoryPickerViewController)
            let controller = segue.destination as! CategoryPickerViewController
            
            // Configura la propiedad selectedCategoryName en el controlador de destino
            // Usando el valor de la variable categoryName
            controller.selectedCategoryName = categoryName
        }
    }
    
    
    // MARK: - Actions
    @IBAction func done() {
        // Método asociado a un botón o acción que se ejecuta cuando se presiona el botón "done"
        
        // Verifica si hay un controlador de navegación (navigationController)
        if let navigationController = navigationController {
            // Si existe un controlador de navegación, realiza una animación para retroceder a la vista anterior
            navigationController.popViewController(animated: true)
        }
    }
    
    @IBAction func cancel() {
        // Método asociado a un botón o acción que se ejecuta cuando se presiona el botón "cancel"
        
        // Verifica si hay un controlador de navegación (navigationController)
        if let navigationController = navigationController {
            // Si existe un controlador de navegación, realiza una animación para retroceder a la vista anterior
            navigationController.popViewController(animated: true)
        }
    }
    
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        // Método llamado cuando se selecciona una categoría en la vista de selección de categoría y se regresa a esta vista
        
        // Obtiene una referencia al controlador de vista de origen (CategoryPickerViewController)
        let controller = segue.source as! CategoryPickerViewController
        
        // Actualiza la variable categoryName con la categoría seleccionada en el controlador de origen
        categoryName = controller.selectedCategoryName
        
        // Actualiza el texto en categoryLabel con la nueva categoryName
        categoryLabel.text = categoryName
    }
    
    
    // MARK: - Helper Methods
    func string(from placemark: CLPlacemark) -> String {
        // Esta función toma un objeto CLPlacemark y lo convierte en una cadena formateada de dirección
        
        var text = "" // Inicializa una cadena vacía para construir la dirección
        
        // Comprueba si placemark.subThoroughfare tiene un valor y agrega a la cadena
        if let tmp = placemark.subThoroughfare {
            text += tmp + " "
        }
        
        // Comprueba si placemark.thoroughfare tiene un valor y agrega a la cadena
        if let tmp = placemark.thoroughfare {
            text += tmp + ", "
        }
        
        // Comprueba si placemark.locality tiene un valor y agrega a la cadena
        if let tmp = placemark.locality {
            text += tmp + ", "
        }
        
        // Comprueba si placemark.administrativeArea tiene un valor y agrega a la cadena
        if let tmp = placemark.administrativeArea {
            text += tmp + " "
        }
        
        // Comprueba si placemark.postalCode tiene un valor y agrega a la cadena
        if let tmp = placemark.postalCode {
            text += tmp + ", "
        }
        
        // Comprueba si placemark.country tiene un valor y agrega a la cadena
        if let tmp = placemark.country {
            text += tmp
        }
        
        return text // Devuelve la cadena resultante que representa la dirección
    }
    
    func format(date: Date) -> String {
        // Esta función toma una fecha y la formatea como una cadena utilizando el dateFormatter
        
        return dateFormatter.string(from: date) // Utiliza el dateFormatter para formatear la fecha y devuelve la cadena resultante
    }
    
}
