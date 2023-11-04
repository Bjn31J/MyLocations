//
//  LocationsDetailsViewController.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 25/09/23.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .medium
  formatter.timeStyle = .short
  return formatter
}()

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
  var managedObjectContext: NSManagedObjectContext!
  var date = Date()
  var descriptionText = ""

    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                // Cuando se establece la ubicación para editar (locationToEdit), realiza lo siguiente:

                descriptionText = location.locationDescription
                // Establece la propiedad descriptionText con la descripción de la ubicación a editar.

                categoryName = location.category
                // Establece la propiedad categoryName con la categoría de la ubicación a editar.

                date = location.date
                // Establece la propiedad date con la fecha de la ubicación a editar.

                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                // Establece la propiedad coordinate con las coordenadas (latitud y longitud) de la ubicación a editar.

                placemark = location.placemark
                // Establece la propiedad placemark con el placemark de la ubicación a editar, que contiene información detallada de la dirección, si está disponible.
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        if let location = locationToEdit {
            title = "Edit Location"
            // Si se está editando una ubicación existente, se establece el título de la vista como "Edit Location".
        }

        descriptionTextView.text = descriptionText
        // Se establece el texto en la vista de texto (descriptionTextView) con la descripción de la ubicación.

        categoryLabel.text = categoryName
        // Se establece el texto en la etiqueta (categoryLabel) con la categoría de la ubicación.

        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        // Se muestra la latitud en la etiqueta (latitudeLabel), con formato de 8 decimales.

        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        // Se muestra la longitud en la etiqueta (longitudeLabel), con formato de 8 decimales.

        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
            // Si hay un placemark disponible, se muestra la dirección en la etiqueta (addressLabel) utilizando una función llamada `string(from:)`.
        } else {
            addressLabel.text = "No Address Found"
            // Si no hay un placemark disponible, se muestra un mensaje indicando que no se encontró dirección.
        }

        dateLabel.text = format(date: date)
        // Se muestra la fecha formateada en la etiqueta (dateLabel) utilizando una función llamada `format(date:)`.

        // Ocultar el teclado
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        // Se configura un gesto de toque para ocultar el teclado cuando se toca en cualquier parte de la vista (excepto en los elementos de entrada de texto).
    }


  // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            // Verifica si el identificador del segway es "PickCategory".

            let controller = segue.destination as! CategoryPickerViewController
            // Obtiene una referencia a la vista de destino (CategoryPickerViewController) a la que se va a realizar la transición.

            controller.selectedCategoryName = categoryName
            // Configura la propiedad `selectedCategoryName` de la vista de destino con el valor actual de la categoría (`categoryName`) de la vista actual.
        }
    }


  // MARK: - Actions
    @IBAction func done() {
        guard let mainView = navigationController?.parent?.view else { return }
        // Obtiene la vista principal a la que se agregará el mensaje HUD.

        let hudView = HudView.hud(inView: mainView, animated: true)
        // Muestra un mensaje HUD (Heads-Up Display) en la vista principal, que proporciona información al usuario.

        let location: Location
        if let temp = locationToEdit {
            // Si se está editando una ubicación existente:

            hudView.text = "Updated"
            // Configura el texto del HUD como "Updated" para indicar que se ha actualizado la ubicación.
            location = temp
            // Utiliza la ubicación existente que se está editando.
        } else {
            hudView.text = "Tagged"
            // Configura el texto del HUD como "Tagged" para indicar que se ha etiquetado una nueva ubicación.
            location = Location(context: managedObjectContext)
            // Crea una nueva ubicación en el contexto de Core Data.
        }

        // Asigna los valores de la vista de detalle a la ubicación.
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark

        do {
            try managedObjectContext.save()
            // Guarda los cambios en el contexto de Core Data.

            afterDelay(0.6) {
                hudView.hide()
                // Oculta el mensaje HUD después de un breve retraso.

                self.navigationController?.popViewController(animated: true)
                // Navega de regreso a la vista anterior (por lo general, la vista de lista de ubicaciones) después de guardar los cambios.
            }
        } catch {
            fatalCoreDataError(error)
            // En caso de un error al guardar los cambios en Core Data, se maneja de manera adecuada, mostrando un mensaje de error.
        }
    }

    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
        // Navega de regreso a la vista anterior (generalmente la vista de lista de ubicaciones) de manera animada.
    }


    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        // Este método se llama cuando el usuario elige una categoría desde la vista de selección de categorías y regresa a la vista de detalle de ubicación.
        
        let controller = segue.source as! CategoryPickerViewController
        // Obtiene una referencia a la vista de origen (CategoryPickerViewController) de la que se regresó.
        
        categoryName = controller.selectedCategoryName
        // Actualiza la propiedad categoryName con la categoría seleccionada en la vista de selección
    }

  // MARK: - Helper Methods
    func string(from placemark: CLPlacemark) -> String {
        // Este método toma un placemark (objeto CLPlacemark) y lo convierte en una cadena de texto que representa la dirección.

        var text = ""
        if let tmp = placemark.subThoroughfare {
            text += tmp + " "
            // Agrega el subThoroughfare (número de edificio o calle) seguido de un espacio, si está disponible.
        }
        if let tmp = placemark.thoroughfare {
            text += tmp + ", "
            // Agrega el thoroughfare (nombre de la calle), seguido de una coma y un espacio, si está disponible.
        }
        if let tmp = placemark.locality {
            text += tmp + ", "
            // Agrega la locality (localidad o ciudad), seguida de una coma y un espacio, si está disponible.
        }
        if let tmp = placemark.administrativeArea {
            text += tmp + " "
            // Agrega el administrativeArea (estado o provincia) seguido de un espacio, si está disponible.
        }
        if let tmp = placemark.postalCode {
            text += tmp + ", "
            // Agrega el postalCode (código postal), seguido de una coma y un espacio, si está disponible.
        }
        if let tmp = placemark.country {
            text += tmp
            // Agrega el country (país), si está disponible.
        }
        return text
        // Retorna la cadena de texto resultante que representa la dirección completa.
    }

    func format(date: Date) -> String {
        // Este método toma un objeto Date y lo formatea como una cadena de texto.

        return dateFormatter.string(from: date)
        // Utiliza el formateador de fecha (dateFormatter) para convertir el objeto Date en una cadena de texto formateada y la retorna.
    }

    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        // Este método se llama cuando el usuario toca en cualquier parte de la vista para ocultar el teclado si está visible.

        let point = gestureRecognizer.location(in: tableView)
        // Obtiene la posición donde se realizó el toque en relación a la vista de tabla (tableView).

        let indexPath = tableView.indexPathForRow(at: point)
        // Obtiene el índice de la fila en la que se realizó el toque, si corresponde.

        if indexPath != nil && indexPath!.section == 0 &&
            indexPath!.row == 0 {
            return
            // Si el toque se realizó en la primera sección y primera fila (por ejemplo, en la descripción), no se oculta el teclado y se sale del método.
        }
        descriptionTextView.resignFirstResponder()
        // Si el toque no se realizó en la vista de descripción, se oculta el teclado al hacer que la vista de texto de descripción (descriptionTextView) deje de ser el primer respondedor, lo que oculta el teclado si está visible.
    }


  // MARK: - Table View Delegates
    override func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        // Este método se utiliza para controlar si una fila específica en la vista de tabla se puede seleccionar o no.

        if indexPath.section == 0 || indexPath.section == 1 {
            // Si la fila pertenece a la sección 0 o 1, se permite la selección.
            return indexPath
        } else {
            // En caso contrario, se evita la selección y se devuelve nil.
            return nil
        }
    }


    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        // Este método se llama cuando el usuario selecciona una fila en la vista de tabla.

        if indexPath.section == 0 && indexPath.row == 0 {
            // Si la fila seleccionada pertenece a la sección 0 y es la fila 0 (por ejemplo, la fila de la descripción):

            descriptionTextView.becomeFirstResponder()
            // Hace que la vista de texto de descripción (descriptionTextView) sea el primer respondedor, lo que muestra el teclado y permite la edición del texto en la vista de descripción.
        }
    }

}
