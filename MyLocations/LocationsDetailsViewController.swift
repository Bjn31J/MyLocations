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
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var addPhotoLabel: UILabel!
  @IBOutlet var imageHeight: NSLayoutConstraint!
    


  var coordinate = CLLocationCoordinate2D(
    latitude: 0,
    longitude: 0)
  var placemark: CLPlacemark?
  var categoryName = "No Category"
  var managedObjectContext: NSManagedObjectContext!
  var date = Date()
  var descriptionText = ""
  var image: UIImage?
  var observer: Any!

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
//nuevo
        if let location = locationToEdit {
            // Si hay una ubicación para editar.

            title = "Edit Location" // Establece el título de la vista como "Edit Location".

            if location.hasPhoto {
                // Si la ubicación tiene una foto asociada.

                if let theImage = location.photoImage {
                    // Si se puede obtener la imagen de la ubicación.

                    show(image: theImage)
                    // Muestra la imagen en la interfaz de usuario utilizando la función show().
                }
            }
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
        listenForBackgroundNotification()
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
            location.photoID = nil
        }

        // Asigna los valores de la vista de detalle a la ubicación.
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        // Save image
        if let image = image {
            // Si hay una imagen.

            if !location.hasPhoto {
                // Si la ubicación no tiene una foto asociada.

                location.photoID = Location.nextPhotoID() as NSNumber
                // Asigna un nuevo identificador de foto a la ubicación utilizando la función nextPhotoID().
            }

            if let data = image.jpegData(compressionQuality: 0.5) {
                // Si se puede obtener datos JPEG de la imagen con una calidad del 50%.

                do {
                    try data.write(to: location.photoURL, options: .atomic)
                    // Intenta escribir los datos de la imagen en la URL de la foto de la ubicación.
                } catch {
                    // Si hay un error al escribir el archivo, imprime el error.
                    print("Error writing file: \(error)")
                }
            }
        }


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
    
    func show(image: UIImage) {
        // Muestra la imagen en la interfaz de usuario.

        imageView.image = image
        // Asigna la imagen al objeto imageView.

        imageView.isHidden = false
        // Hace visible el objeto imageView.

        addPhotoLabel.text = ""
        // Limpia el texto en el objeto addPhotoLabel.
        
        //imageHeight.constant = 260

        // Verificar si imageHeight es nil antes de asignar el valor
        if let height = imageHeight {
            // Si imageHeight no es nil.

            height.constant = 260
            // Establece la altura del objeto imageHeight en 260.
        } else {
            // Manejar el caso en el que imageHeight sea nil.
            print("imageHeight is nil")
        }

        tableView.reloadData()
        // Recarga los datos de la tabla para reflejar los cambios.
    }

    
    func listenForBackgroundNotification() {
        // Establece un observador para la notificación de entrada en segundo plano de la aplicación.

        observer = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            // Escucha la notificación de entrada en segundo plano de la aplicación.
            object: nil,
            queue: OperationQueue.main) { [weak self] _ in
            // Usa una captura débil para evitar posibles problemas de retención circular.

            if let weakSelf = self {
                // Si weakSelf no es nil.

                if weakSelf.presentedViewController != nil {
                    // Si hay un controlador de vista presentado.

                    weakSelf.dismiss(animated: false, completion: nil)
                    // Descarta el controlador de vista presentado de manera animada.
                }

                weakSelf.descriptionTextView.resignFirstResponder()
                // Retira el foco del teclado para el objeto descriptionTextView.
            }
        }
    }

    deinit {
        // Se llama cuando la instancia de la clase está siendo desinicializada.

        print("*** deinit \(self)")
        // Imprime un mensaje de depuración indicando que la instancia está siendo desinicializada.

        NotificationCenter.default.removeObserver(observer!)
        // Elimina el observador previamente configurado para evitar problemas de retención.
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
        // Se llama cuando se selecciona una celda en la tabla.

        if indexPath.section == 0 && indexPath.row == 0 {
            // Si se selecciona la primera celda de la primera sección.

            descriptionTextView.becomeFirstResponder()
            // Hace que el objeto descriptionTextView obtenga el foco del teclado.
        } else if indexPath.section == 1 && indexPath.row == 0 {
            // Si se selecciona la primera celda de la segunda sección.

            tableView.deselectRow(at: indexPath, animated: true)
            // Deselecciona la celda de manera animada.

            pickPhoto()
            // Llama al método pickPhoto para seleccionar una foto.
        }
    }


}

extension LocationDetailsViewController:
UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    // Mark: - Image Helper Methods
    func takePhotoWithCamera() {
        // Crea un controlador de vista para seleccionar una imagen de la cámara.

        let imagePicker = UIImagePickerController()
        // Crea una instancia del controlador de vista para seleccionar una imagen.

        imagePicker.sourceType = .camera
        // Establece la fuente del controlador de vista para la cámara.

        imagePicker.delegate = self
        // Establece el delegado del controlador de vista como la instancia actual.

        imagePicker.allowsEditing = true
        // Permite la edición de la imagen seleccionada.

        present(imagePicker, animated: true, completion: nil)
        // Presenta el controlador de vista de selección de imagen de manera animada.
    }

    func choosePhotoFromLibrary() {
        // Crea un controlador de vista para seleccionar una imagen de la biblioteca de fotos.

        let imagePicker = UIImagePickerController()
        // Crea una instancia del controlador de vista para seleccionar una imagen.

        imagePicker.sourceType = .photoLibrary
        // Establece la fuente del controlador de vista para la biblioteca de fotos.

        imagePicker.delegate = self
        // Establece el delegado del controlador de vista como la instancia actual.

        imagePicker.allowsEditing = true
        // Permite la edición de la imagen seleccionada.

        present(imagePicker, animated: true, completion: nil)
        // Presenta el controlador de vista de selección de imagen de manera animada.
    }

    
    func pickPhoto() {
        // Verifica si la cámara está disponible en el dispositivo.
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // Si la cámara está disponible, muestra el menú de selección de foto.
            showPhotoMenu()
        } else {
            // Si la cámara no está disponible, elige una foto de la biblioteca de fotos.
            choosePhotoFromLibrary()
        }
    }

    
    func showPhotoMenu() {
        // Crea un controlador de alerta con un estilo de hoja de acciones.

        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)
        // Crea una instancia de UIAlertController con un estilo de hoja de acciones.

        let actCancel = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil)
        // Crea una acción de cancelar.

        alert.addAction(actCancel)
        // Agrega la acción de cancelar al controlador de alerta.

        let actPhoto = UIAlertAction(
            title: "Take Photo",
            style: .default) { _ in
                self.takePhotoWithCamera()
            }
        // Crea una acción para tomar una foto.

        alert.addAction(actPhoto)
        // Agrega la acción de tomar foto al controlador de alerta.

        let actLibrary = UIAlertAction(
            title: "Choose From Library",
            style: .default) { _ in
                self.choosePhotoFromLibrary()
            }
        // Crea una acción para elegir una foto de la biblioteca.

        alert.addAction(actLibrary)
        // Agrega la acción de elegir foto de la biblioteca al controlador de alerta.

        present(alert, animated: true, completion: nil)
        // Presenta el controlador de alerta de manera animada.
    }

    
    // MARK: - Image Picker Delegates
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        // Obtiene la imagen editada del diccionario de información.
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage

        // Verifica si la imagen es válida.
        if let theImage = image {
            // Muestra la imagen.
            show(image: theImage)
        }

        // Descarta el controlador de selección de imágenes de manera animada.
        dismiss(animated: true, completion: nil)
    }


    func imagePickerControllerDidCancel(
        _ picker: UIImagePickerController
    ) {
        // Descarta el controlador de selección de imágenes de manera animada.
        dismiss(animated: true, completion: nil)
    }

}
                                
