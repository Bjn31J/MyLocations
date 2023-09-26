//
//  ViewController.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 06/09/23.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate{ //Define una clase llamada CurrentLocationViewController que hereda de UIViewController e implementa el protocolo CLLocationManagerDelegate

    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    var timer: Timer?
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    override func viewDidLoad() {
      super.viewDidLoad()
      updateLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      // Llama al método viewWillAppear de la superclase para realizar tareas adicionales (si es necesario).
      super.viewWillAppear(animated)
      
      // Oculta la barra de navegación del controlador de vista.
      navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
      // Llama al método viewWillDisappear de la superclase para realizar tareas adicionales (si es necesario).
      super.viewWillDisappear(animated)
      
      // Vuelve a mostrar la barra de navegación del controlador de vista.
      navigationController?.isNavigationBarHidden = false
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Verifica si el identificador del segue coincide con "TagLocation".
      if segue.identifier == "TagLocation" {
        // Obtiene una referencia al controlador de vista de destino (LocationDetailsViewController).
        let controller = segue.destination as! LocationDetailsViewController
        
        // Pasa la coordenada de la ubicación actual al controlador de vista de destino.
        controller.coordinate = location!.coordinate
        
        // Pasa el placemark (información de ubicación inversa) al controlador de vista de destino.
        controller.placemark = placemark
      }
    }



    // MARK: - Actions
    // Este método se llama cuando se presiona un botón u otra acción para obtener la ubicación del dispositivo.
    @IBAction func getLocation() {
    // Se verifica el estado de autorización de la ubicación.
      let authStatus = locationManager.authorizationStatus
    // Si el estado de autorización es .notDetermined (no determinado), solicitamos permiso al usuario.
      if authStatus == .notDetermined {
        locationManager.requestWhenInUseAuthorization()
        return
      }
    // Si el estado de autorización es .denied (denegado) o .restricted (restringido),
   // mostramos una alerta al usuario informando que los servicios de ubicación están deshabilitados para la aplicación.
      if authStatus == .denied || authStatus == .restricted {
        showLocationServicesDeniedAlert()
        return
      }
   // Si estamos actualizando la ubicación en este momento, detenemos el proceso.
      if updatingLocation {
        stopLocationManager()
      } else {
  // Si no estamos actualizando la ubicación, reiniciamos algunas variables relacionadas con la ubicación y comenzamos a rastrear la ubicación.
        location = nil
        lastLocationError = nil
        placemark = nil
        lastGeocodingError = nil
        startLocationManager()
      }
    // Después de realizar las acciones necesarias, actualizamos las etiquetas en la interfaz de usuario.
      updateLabels()
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(
      _ manager: CLLocationManager,
      didFailWithError error: Error
    ) {
    // Imprimimos un mensaje de error que incluye la descripción del error.
      print("didFailWithError \(error.localizedDescription)")
    // Verificamos si el código del error es igual al valor de CLError.locationUnknown.
      if (error as NSError).code == CLError.locationUnknown.rawValue {
        return
      }
    // Si el error no se debe a una ubicación desconocida, almacenamos el error en la variable lastLocationError.
      lastLocationError = error
    // Detenemos el proceso de actualización de la ubicación.
      stopLocationManager()
    // Actualizamos las etiquetas en la interfaz de usuario para reflejar el nuevo estado.
      updateLabels()
    }
    
    func locationManager(
      _ manager: CLLocationManager,
      didUpdateLocations locations: [CLLocation]
    ) {
      // Obtiene la ubicación más reciente del arreglo de ubicaciones.
      let newLocation = locations.last!
      
      // Imprime un mensaje para depuración que muestra la ubicación más reciente.
      print("didUpdateLocations \(newLocation)")

      // Verifica si la ubicación es demasiado antigua (más de -5 segundos).
      if newLocation.timestamp.timeIntervalSinceNow < -5 {
        return // Sale temprano del método si la ubicación es muy antigua.
      }

      // Verifica si la precisión horizontal de la ubicación es negativa.
      if newLocation.horizontalAccuracy < 0 {
        return // Sale temprano del método si la ubicación es inválida.
      }

      // Inicializa una variable para calcular la distancia entre ubicaciones.
      var distance = CLLocationDistance(Double.greatestFiniteMagnitude)

      // Comprueba si ya hay una ubicación previa almacenada.
      if let location = location {
        // Calcula la distancia entre la nueva ubicación y la ubicación previa.
        distance = newLocation.distance(from: location)
      }

      // Verifica si no hay una ubicación previa o si la precisión de la nueva ubicación es mejor.
      if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
        // Limpia el error de ubicación anterior y actualiza la ubicación actual.
        lastLocationError = nil
        location = newLocation

        // Si la precisión es suficientemente buena, se detiene el administrador de ubicación.
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
          print("*** ¡Hemos terminado!")
          stopLocationManager()

          // Si hay una distancia positiva entre ubicaciones, se indica que no se está realizando la inversión geocodificación.
          if distance > 0 {
            performingReverseGeocoding = false
          }
        }

        // Si no se está realizando la inversión geocodificación, se inicia el proceso.
        if !performingReverseGeocoding {
          print("*** Going to geocode")

          performingReverseGeocoding = true

          // Realiza la inversión geocodificación en segundo plano.
          geocoder.reverseGeocodeLocation(newLocation) { placemarks, error in
            // Almacena el error de geocodificación.
            self.lastGeocodingError = error
            
            // Si no hay error y se obtienen los lugares, se actualiza el placemark.
            if error == nil, let places = placemarks, !places.isEmpty {
              self.placemark = places.last!
            } else {
              self.placemark = nil
            }

            // Finaliza el proceso de inversión geocodificación.
            self.performingReverseGeocoding = false
            
            // Actualiza las etiquetas u otros elementos de la interfaz de usuario.
            self.updateLabels()
          }
        }

        // Actualiza las etiquetas u otros elementos de la interfaz de usuario.
        updateLabels()
      } else if distance < 1 {
        // Si la distancia entre ubicaciones es muy pequeña y ha pasado mucho tiempo, se detiene el administrador de ubicación.
        let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
        if timeInterval > 10 {
          print("*** ¡Forzar finalización!")
          stopLocationManager()
          updateLabels()
        }
      }
    }


    // MARK: - Helper Methods
    func showLocationServicesDeniedAlert() {
      // Crea una instancia de UIAlertController para mostrar un mensaje de alerta.
      let alert = UIAlertController(
        title: "Location Services Disabled",  // Título del mensaje de alerta.
        message: "Please enable location services for this app in Settings.",  // Mensaje descriptivo.
        preferredStyle: .alert  // Establece el estilo de alerta.
      )

      // Crea una acción de botón "OK" que se mostrará en la alerta.
      let okAction = UIAlertAction(
        title: "OK",  // Título del botón.
        style: .default,  // Estilo del botón (predeterminado).
        handler: nil  // Acción a realizar cuando se toca el botón (ninguna en este caso).
      )

      // Agrega la acción "OK" a la alerta, para que aparezca como una opción para el usuario.
      alert.addAction(okAction)

      // Muestra la alerta en la interfaz de usuario con animación y sin ninguna acción de finalización.
      present(alert, animated: true, completion: nil)
    }

    func updateLabels() {
      // Verifica si hay una ubicación válida.
      if let location = location {
        // Actualiza las etiquetas de latitud y longitud con la ubicación actual.
        latitudeLabel.text = String(
          format: "%.8f",
          location.coordinate.latitude)
        longitudeLabel.text = String(
          format: "%.8f",
          location.coordinate.longitude)
        
        // Muestra el botón "Tag" (etiqueta) y limpia el mensaje.
        tagButton.isHidden = false
        messageLabel.text = ""

        // Verifica si hay un placemark disponible.
        if let placemark = placemark {
          // Muestra la dirección obtenida del placemark.
          addressLabel.text = string(from: placemark)
        } else if performingReverseGeocoding {
          // Muestra un mensaje mientras se realiza la inversión geocodificación.
          addressLabel.text = "Searching for Address..."
        } else if lastGeocodingError != nil {
          // Muestra un mensaje si ocurrió un error durante la geocodificación.
          addressLabel.text = "Error Finding Address"
        } else {
          // Muestra un mensaje si no se encontró ninguna dirección.
          addressLabel.text = "No Address Found"
        }
      } else {
        // Si no hay una ubicación válida, se borran las etiquetas y se oculta el botón "Tag".
        latitudeLabel.text = ""
        longitudeLabel.text = ""
        addressLabel.text = ""
        tagButton.isHidden = true

        // Define un mensaje de estado basado en varias condiciones.
        let statusMessage: String
        if let error = lastLocationError as NSError? {
          if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
            // Mensaje si los servicios de ubicación están desactivados o denegados.
            statusMessage = "Location Services Disabled"
          } else {
            // Mensaje si hubo un error al obtener la ubicación.
            statusMessage = "Error Getting Location"
          }
        } else if !CLLocationManager.locationServicesEnabled() {
          // Mensaje si los servicios de ubicación están desactivados en general.
          statusMessage = "Location Services Disabled"
        } else if updatingLocation {
          // Mensaje si se está buscando una ubicación.
          statusMessage = "Searching..."
        } else {
          // Mensaje predeterminado si no se cumplen las demás condiciones.
          statusMessage = "Tap 'Get My Location' to Start"
        }
        
        // Asigna el mensaje de estado a la etiqueta de mensaje.
        messageLabel.text = statusMessage
      }
      
      // Llama a la función para configurar el botón "Get" (Obtener).
      configureGetButton()
    }


    func startLocationManager() {
      // Verifica si los servicios de ubicación están habilitados en el dispositivo.
      if CLLocationManager.locationServicesEnabled() {
        // Asigna el delegado de CLLocationManager para manejar las actualizaciones de ubicación.
        locationManager.delegate = self
        
        // Establece la precisión deseada para las actualizaciones de ubicación (10 metros en este caso).
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        // Inicia la actualización continua de la ubicación.
        locationManager.startUpdatingLocation()
        
        // Marca la bandera 'updatingLocation' como verdadera para indicar que se están buscando actualizaciones de ubicación.
        updatingLocation = true
        
        // Configura un temporizador para controlar el tiempo de espera de las actualizaciones de ubicación.
        timer = Timer.scheduledTimer(
          timeInterval: 60,  // Intervalo de tiempo de 60 segundos.
          target: self,  // El objeto que manejará el temporizador (en este caso, esta instancia de la clase).
          selector: #selector(didTimeOut),  // Método que se llamará cuando el temporizador se agote.
          userInfo: nil,  // Información adicional (ninguna en este caso).
          repeats: false  // No se repite automáticamente después de agotarse.
        )
      }
    }


    func stopLocationManager() {
      // Verifica si se están recibiendo actualizaciones de ubicación.
      if updatingLocation {
        // Detiene la actualización continua de la ubicación.
        locationManager.stopUpdatingLocation()
        
        // Anula la asignación del delegado para dejar de recibir actualizaciones de ubicación.
        locationManager.delegate = nil
        
        // Marca la bandera 'updatingLocation' como falsa para indicar que se han detenido las actualizaciones.
        updatingLocation = false

        // Verifica si hay un temporizador en funcionamiento y lo invalida.
        if let timer = timer {
          timer.invalidate()
        }
      }
    }


    func configureGetButton() {
      // Verifica si se están recibiendo actualizaciones de ubicación.
      if updatingLocation {
        // Si se están recibiendo actualizaciones, cambia el título del botón a "Stop".
        getButton.setTitle("Stop", for: .normal)
      } else {
        // Si no se están recibiendo actualizaciones, establece el título del botón como "Get My Location".
        getButton.setTitle("Get My Location", for: .normal)
      }
    }


    func string(from placemark: CLPlacemark) -> String {
      var line1 = ""
      // Verifica si hay información en 'subThoroughfare' y la agrega a 'line1'.
      if let tmp = placemark.subThoroughfare {
        line1 += tmp + " "
      }
      // Verifica si hay información en 'thoroughfare' y la agrega a 'line1'.
      if let tmp = placemark.thoroughfare {
        line1 += tmp
      }
      
      var line2 = ""
      // Verifica si hay información en 'locality' y la agrega a 'line2'.
      if let tmp = placemark.locality {
        line2 += tmp + " "
      }
      // Verifica si hay información en 'administrativeArea' y la agrega a 'line2'.
      if let tmp = placemark.administrativeArea {
        line2 += tmp + " "
      }
      // Verifica si hay información en 'postalCode' y la agrega a 'line2'.
      if let tmp = placemark.postalCode {
        line2 += tmp
      }
      
      // Retorna la combinación de 'line1' y 'line2' con un salto de línea.
      return line1 + "\n" + line2
    }


    @objc func didTimeOut() {
      // Imprime un mensaje de tiempo de espera en la consola para fines de depuración.
      print("*** Time out")
      
      // Verifica si no se ha obtenido ninguna ubicación durante el tiempo de espera.
      if location == nil {
        // Detiene el administrador de ubicación ya que ha agotado el tiempo de espera.
        stopLocationManager()
        
        // Crea un objeto NSError para representar un error relacionado con ubicaciones.
        lastLocationError = NSError(
          domain: "MyLocationsErrorDomain",  // Dominio personalizado para el error.
          code: 1,  // Código de error personalizado (puede ser cualquier valor).
          userInfo: nil  // Información adicional del error (en este caso, no se proporciona).
        )
        
        // Actualiza las etiquetas en la interfaz de usuario para reflejar el error.
        updateLabels()
      }
    }

  }
