//
//  MapViewController.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 11/11/23.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
  @IBOutlet var mapView: MKMapView!

  var locations = [Location]()

    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            // Este bloque de código se ejecuta cuando se asigna un valor al atributo managedObjectContext.

            NotificationCenter.default.addObserver(
                forName: Notification.Name.NSManagedObjectContextObjectsDidChange,
                // Agrega un observador para la notificación de cambio de objetos en el contexto de Core Data.

                object: managedObjectContext,
                // La notificación solo se escuchará si proviene del contexto de Core Data asignado.

                queue: OperationQueue.main
            ) { _ in
                // El bloque de código que se ejecutará cuando se reciba la notificación.

                if self.isViewLoaded {
                    // Verifica si la vista está cargada para evitar realizar actualizaciones innecesarias si la vista aún no se ha cargado.

                    self.updateLocations()
                    // Llama al método updateLocations para actualizar la vista con las ubicaciones más recientes.
                }
            }
        }
    }

  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Llama a la implementación de viewDidLoad en la superclase.

        updateLocations()
        // Llama al método updateLocations para cargar las ubicaciones desde el contexto de Core Data.

        if !locations.isEmpty {
            // Verifica si hay ubicaciones cargadas en el arreglo locations.

            showLocations()
            // Llama al método showLocations para mostrar las ubicaciones en la vista.
        }
    }


  // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Este método se llama justo antes de realizar una transición de segues.

        if segue.identifier == "EditLocation" {
            // Verifica si la identificación del segue es "EditLocation".

            let controller = segue.destination as! LocationDetailsViewController
            // Obtiene el controlador de destino (destination view controller) del segue.

            controller.managedObjectContext = managedObjectContext
            // Asigna el contexto de Core Data (`managedObjectContext`) al controlador de vista de detalles.

            let button = sender as! UIButton
            // Obtiene el objeto UIButton que activó el segue.

            let location = locations[button.tag]
            // Obtiene la ubicación asociada al botón que activó el segue.

            controller.locationToEdit = location
            // Asigna la ubicación al controlador de vista de detalles para la edición.
        }
    }


  // MARK: - Actions
    @IBAction func showUser() {
        // Este método se llama cuando se quiere mostrar la ubicación del usuario en el mapa.

        let region = MKCoordinateRegion(
            center: mapView.userLocation.coordinate,
            // Obtiene las coordenadas de la ubicación actual del usuario.

            latitudinalMeters: 1000,
            // Establece el rango en metros de latitud alrededor de la ubicación del usuario.

            longitudinalMeters: 1000
            // Establece el rango en metros de longitud alrededor de la ubicación del usuario.
        )

        mapView.setRegion(
            mapView.regionThatFits(region),
            // Ajusta la región del mapa para que se ajuste a las coordenadas y el rango especificados.

            animated: true
            // Realiza la transición animada para centrar el mapa en la ubicación del usuario.
        )
    }


    @IBAction func showLocations() {
        // Este método se llama cuando se quiere mostrar un conjunto de ubicaciones en el mapa.

        let theRegion = region(for: locations)
        // Llama a la función region(for:) para calcular la región que abarca todas las ubicaciones.

        mapView.setRegion(theRegion, animated: true)
        // Ajusta la región del mapa para que se ajuste a la región calculada y realiza una transición animada.
    }


  // MARK: - Helper methods
    func updateLocations() {
        // Este método actualiza las ubicaciones en el mapa.

        mapView.removeAnnotations(locations)
        // Elimina todas las anotaciones existentes en el mapa.

        let entity = Location.entity()
        // Obtiene la entidad de Core Data asociada a la clase Location.

        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        // Configura la solicitud de búsqueda para recuperar objetos de la entidad Location.

        locations = try! managedObjectContext.fetch(fetchRequest)
        // Realiza la búsqueda en el contexto de Core Data para obtener las ubicaciones.

        mapView.addAnnotations(locations)
        // Agrega las ubicaciones como nuevas anotaciones en el mapa.
    }


    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        // Este método calcula una región que abarca todas las anotaciones (ubicaciones) en el mapa.

        let region: MKCoordinateRegion

        switch annotations.count {
        case 0:
            // Caso cuando no hay anotaciones. Utiliza la ubicación del usuario como centro de la región.
            region = MKCoordinateRegion(
                center: mapView.userLocation.coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000)

        case 1:
            // Caso cuando hay una sola anotación. Utiliza la coordenada de esa anotación como centro de la región.
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegion(
                center: annotation.coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000)

        default:
            // Caso cuando hay más de una anotación. Calcula la región que abarca todas las anotaciones.

            var topLeft = CLLocationCoordinate2D(
                latitude: -90,
                longitude: 180)
            var bottomRight = CLLocationCoordinate2D(
                latitude: 90,
                longitude: -180)

            // Encuentra las coordenadas mínimas (topLeft) y máximas (bottomRight) entre todas las anotaciones.
            for annotation in annotations {
                topLeft.latitude = max(topLeft.latitude, annotation.coordinate.latitude)
                topLeft.longitude = min(topLeft.longitude, annotation.coordinate.longitude)
                bottomRight.latitude = min(bottomRight.latitude, annotation.coordinate.latitude)
                bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
            }

            // Calcula el centro de la región y la extensión (span).
            let center = CLLocationCoordinate2D(
                latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2,
                longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2)

            let extraSpace = 1.1
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace,
                longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)

            // Crea la región final.
            region = MKCoordinateRegion(center: center, span: span)
        }

        // Ajusta la región para que se ajuste al mapa y la devuelve.
        return mapView.regionThatFits(region)
    }


    @objc func showLocationDetails(_ sender: UIButton) {
        // Este método se llama cuando se quiere mostrar detalles de ubicación en respuesta de un botón.

        performSegue(withIdentifier: "EditLocation", sender: sender)
        // Realiza la transición a la escena "EditLocation" utilizando el identificador de la segue.
    }
}

extension MapViewController: MKMapViewDelegate {
    // Método del protocolo MKMapViewDelegate para personalizar la vista de la anotación.
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        // Verifica si la anotación es de tipo Location.
        guard annotation is Location else {
            return nil
        }

        // Define un identificador para la vista de la anotación.
        let identifier = "Location"
        
        // Intenta reutilizar una vista de anotación existente.
        var annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier)

        
        if annotationView == nil {
            // Si no hay una vista de anotación reutilizable, crea una nueva.

            // Crea una vista de anotación con el identificador y la anotación proporcionados.
            let pinView = MKPinAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier)
            
            // Configura las propiedades de la vista de la anotación.
            pinView.isEnabled = true // Habilita la interacción con la vista de anotación.
            pinView.canShowCallout = true // Permite mostrar la burbuja de la anotación al tocarla.
            pinView.animatesDrop = false // Desactiva la animación de caída al mostrar la anotación.
            pinView.pinTintColor = UIColor(
                red: 0.32,
                green: 0.82,
                blue: 0.4,
                alpha: 1) // Configura el color del pin de la anotación.

            // Agrega un botón de detalle en el accesorio derecho de la burbuja de la anotación.
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(
                self,
                action: #selector(showLocationDetails(_:)),
                for: .touchUpInside) // Configura la acción del botón para mostrar detalles de la ubicación.
            pinView.rightCalloutAccessoryView = rightButton // Asigna el botón como accesorio derecho.

            annotationView = pinView // Asigna la nueva vista de anotación creada.
        }


        if let annotationView = annotationView {
            // Si se pudo obtener la vista de anotación.

            annotationView.annotation = annotation // Asigna la anotación a la vista de anotación.

            // Accede al botón de detalle en el accesorio derecho de la burbuja de la anotación.
            let button = annotationView.rightCalloutAccessoryView as! UIButton

            if let index = locations.firstIndex(of: annotation as! Location) {
                // Si se encuentra el índice de la ubicación en el arreglo de locations.

                button.tag = index // Asigna el índice como la etiqueta del botón.
            }
        }


        return annotationView
    }
}
