//
//  ViewController.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 06/09/23.
//

import UIKit
import CoreLocation
import CoreData
import AudioToolbox

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate, CAAnimationDelegate {
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var tagButton: UIButton!
  @IBOutlet weak var getButton: UIButton!
  @IBOutlet weak var latitudeTextLabel: UILabel!
  @IBOutlet weak var longitudeTextLabel: UILabel!
  @IBOutlet weak var containerView: UIView!

  let locationManager = CLLocationManager()
  var location: CLLocation?
  var updatingLocation = false
  var lastLocationError: Error?
  let geocoder = CLGeocoder()
  var placemark: CLPlacemark?
  var performingReverseGeocoding = false
  var lastGeocodingError: Error?
  var timer: Timer?
  var managedObjectContext: NSManagedObjectContext!
  var logoVisible = false
  var soundID: SystemSoundID = 0

    // Declaración de una propiedad 'logoButton' como una instancia perezosa (lazy) de UIButton
    lazy var logoButton: UIButton = {
        // Creación de la instancia de UIButton con tipo personalizado
        let button = UIButton(type: .custom)
        
        // Establece la imagen de fondo del botón con la imagen llamada "Logo" para el estado normal
        button.setBackgroundImage(UIImage(named: "Logo"), for: .normal)
        
        // Ajusta el tamaño del botón para que se ajuste al tamaño de su contenido
        button.sizeToFit()
        
        // Agrega un objetivo (target) al botón para que llame al método 'getLocation' cuando se toque
        button.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
        
        // Establece la posición central del botón en el eje x, basándose en el centro horizontal de la vista
        button.center.x = self.view.bounds.midX
        
        // Establece la posición del botón en el eje y en 220 unidades desde la parte superior
        button.center.y = 220
        
        // Devuelve el botón configurado
        return button
    }()


    // Sobrescribe el método viewDidLoad de la clase actual (posiblemente un controlador de vista)
    override func viewDidLoad() {
        // Llama al método viewDidLoad de la clase base
        super.viewDidLoad()
        
        // Llama al método updateLabels para actualizar las etiquetas u otras configuraciones necesarias en la vista
        updateLabels()
    }


    // Sobrescribe el método viewWillAppear de la clase actual (posiblemente un controlador de vista)
    override func viewWillAppear(_ animated: Bool) {
        // Llama al método viewWillAppear de la clase base, pasando el parámetro 'animated'
        super.viewWillAppear(animated)
        
        // Accede a la propiedad 'navigationController' para ocultar o mostrar la barra de navegación
        navigationController?.isNavigationBarHidden = true
    }


    // Sobrescribe el método viewWillDisappear de la clase actual (posiblemente un controlador de vista)
    override func viewWillDisappear(_ animated: Bool) {
        // Llama al método viewWillDisappear de la clase base, pasando el parámetro 'animated'
        super.viewWillDisappear(animated)
        
        // Accede a la propiedad 'navigationController' para mostrar la barra de navegación antes de que la vista desaparezca
        navigationController?.isNavigationBarHidden = false
    }


  // MARK: - Navigation
    // Sobrescribe el método prepare(for:sender:) de la clase actual (posiblemente un controlador de vista)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Verifica si el identificador del segue es "TagLocation"
        if segue.identifier == "TagLocation" {
            // Accede al controlador de destino del segue, asumiendo que es una instancia de LocationDetailsViewController
            let controller = segue.destination as! LocationDetailsViewController
            
            // Configura propiedades en el controlador de destino con información del controlador actual
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }

  
  // MARK: - Actions
    // Acción de botón para obtener la ubicación
    @IBAction func getLocation() {
        // Obtiene el estado de autorización actual para la ubicación
        let authStatus = locationManager.authorizationStatus
        
        // Verifica si el usuario aún no ha tomado una decisión sobre la autorización de la ubicación
        if authStatus == .notDetermined {
            // Solicita la autorización para usar la ubicación cuando la aplicación esté en uso
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        // Verifica si la autorización ha sido denegada o restringida
        if authStatus == .denied || authStatus == .restricted {
            // Muestra una alerta indicando que los servicios de ubicación están deshabilitados
            showLocationServicesDeniedAlert()
            return
        }

        // Oculta el logo si está visible
        if logoVisible {
            hideLogoView()
        }

        // Si la obtención de ubicación está en curso, detiene el administrador de ubicación
        if updatingLocation {
            stopLocationManager()
        } else {
            // Si no se está actualizando la ubicación, reinicia las propiedades relacionadas con la ubicación y comienza la actualización
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        // Actualiza las etiquetas u otras configuraciones relacionadas con la interfaz de usuario
        updateLabels()
    }


  // MARK: - CLLocationManagerDelegate
    // Método delegado llamado cuando hay un error en el administrador de ubicación
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Imprime la descripción del error en la consola
        print("didFailWithError \(error.localizedDescription)")

        // Verifica si el código del error corresponde a una ubicación desconocida
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            // Si es así, simplemente retorna sin realizar más acciones
            return
        }
        
        // Si el error no es por ubicación desconocida, actualiza la propiedad 'lastLocationError' con el error
        lastLocationError = error
        
        // Detiene el administrador de ubicación debido al error
        stopLocationManager()
        
        // Actualiza las etiquetas u otras configuraciones relacionadas con la interfaz de usuario
        updateLabels()
    }

    // Método delegado llamado cuando se actualizan las ubicaciones en el administrador de ubicación
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        // Obtiene la última ubicación de la lista de ubicaciones proporcionada
        let newLocation = locations.last!
        
        // Imprime la nueva ubicación en la consola
        print("didUpdateLocations \(newLocation)")

        // Verifica si la marca de tiempo de la nueva ubicación es anterior a 5 segundos atrás
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }

        // Verifica si la precisión horizontal de la nueva ubicación es menor que 0 (indicando un valor no válido)
        if newLocation.horizontalAccuracy < 0 {
            return
        }

        // Calcula la distancia entre la nueva ubicación y la ubicación anterior (si existe)
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }

        // Verifica si la ubicación actual es nula o si la precisión horizontal es mejor que la anterior
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            // Reinicia el error de la última ubicación
            lastLocationError = nil
            // Actualiza la ubicación actual con la nueva ubicación
            location = newLocation

            // Verifica si la precisión horizontal de la nueva ubicación es aceptable
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                // Imprime un mensaje indicando que se ha completado la obtención de ubicación con precisión suficiente
                print("*** We're done!")
                // Detiene el administrador de ubicación
                stopLocationManager()

                // Verifica si hay una distancia significativa entre la nueva ubicación y la anterior
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }

            // Verifica si no se está realizando la inversa de geocodificación
            if !performingReverseGeocoding {
                // Imprime un mensaje indicando que se va a realizar la geocodificación inversa
                print("*** Going to geocode")

                // Indica que se está realizando la inversa de geocodificación
                performingReverseGeocoding = true

                // Realiza la inversa de geocodificación para obtener información de dirección a partir de la ubicación
                geocoder.reverseGeocodeLocation(newLocation) { placemarks, error in
                    // Actualiza el error de la última inversa de geocodificación
                    self.lastGeocodingError = error
                    
                    // Verifica si no hay errores y si hay al menos un lugar (placemark) en los resultados
                    if error == nil, let places = placemarks, !places.isEmpty {
                        // Verifica si la propiedad 'placemark' es nula (indicando la primera vez que se obtiene la ubicación)
                        if self.placemark == nil {
                            // Imprime un mensaje indicando que es la primera vez
                            print("FIRST TIME!")
                            // Reproduce un efecto de sonido
                            self.playSoundEffect()
                        }
                        
                        // Asigna el último lugar (placemark) de los resultados a la propiedad 'placemark'
                        self.placemark = places.last!
                    } else {
                        // Si hay errores o no hay lugares en los resultados, asigna nulo a la propiedad 'placemark'
                        self.placemark = nil
                    }

                    // Indica que la inversa de geocodificación ha finalizado
                    self.performingReverseGeocoding = false
                    
                    // Actualiza las etiquetas u otras configuraciones relacionadas con la interfaz de usuario
                    self.updateLabels()
                }
            }

            // Actualiza las etiquetas u otras configuraciones relacionadas con la interfaz de usuario
            updateLabels()
        } else if distance < 1 {
            // Si la distancia entre la nueva ubicación y la anterior es menor que 1 metro
            // y el intervalo de tiempo entre ellas es mayor a 10 segundos, se considera una finalización forzada
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                // Imprime un mensaje indicando una finalización forzada
                print("*** Force done!")
                // Detiene el administrador de ubicación
                stopLocationManager()
                // Actualiza las etiquetas u otras configuraciones relacionadas con la interfaz de usuario
                updateLabels()
            }
        }
    }


  // MARK: - Helper Methods
    // Función para mostrar una alerta cuando los servicios de ubicación están deshabilitados
    func showLocationServicesDeniedAlert() {
        // Crea una instancia de UIAlertController con estilo de alerta
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)

        // Crea una acción 'OK' que simplemente cierra la alerta
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil)
        
        // Agrega la acción 'OK' a la alerta
        alert.addAction(okAction)

        // Presenta la alerta en la interfaz de usuario animadamente
        present(alert, animated: true, completion: nil)
    }

    // Función para actualizar las etiquetas y elementos de la interfaz de usuario
    func updateLabels() {
        // Verifica si hay una ubicación válida
        if let location = location {
            // Muestra las etiquetas de latitud y longitud con los valores de la ubicación actual
            latitudeLabel.text = String(
                format: "%.8f",
                location.coordinate.latitude)
            longitudeLabel.text = String(
                format: "%.8f",
                location.coordinate.longitude)
            
            // Muestra el botón de etiquetado y limpia el mensaje
            tagButton.isHidden = false
            messageLabel.text = ""

            // Verifica si hay un placemark disponible
            if let placemark = placemark {
                // Muestra la dirección obtenida del placemark
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                // Muestra un mensaje mientras se está realizando la inversa de geocodificación
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                // Muestra un mensaje en caso de error durante la inversa de geocodificación
                addressLabel.text = "Error Finding Address"
            } else {
                // Muestra un mensaje si no hay dirección disponible
                addressLabel.text = "No Address Found"
            }
            
            // Muestra las etiquetas de latitud y longitud
            latitudeTextLabel.isHidden = false
            longitudeTextLabel.isHidden = false
        } else {
            // Si no hay una ubicación válida, oculta las etiquetas y el botón de etiquetado
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true

            // Determina el mensaje de estado según la situación
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    // Mensaje si los servicios de ubicación están deshabilitados
                    statusMessage = "Location Services Disabled"
                } else {
                    // Mensaje en caso de un error general al obtener la ubicación
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                // Mensaje si los servicios de ubicación están deshabilitados
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                // Mensaje mientras se está buscando la ubicación
                statusMessage = "Searching..."
            } else {
                // Muestra el logo y un mensaje si no hay otros mensajes de estado
                statusMessage = ""
                showLogoView()
            }
            
            // Actualiza el mensaje de la etiqueta de estado
            messageLabel.text = statusMessage
            // Oculta las etiquetas de latitud y longitud
            latitudeTextLabel.isHidden = true
            longitudeTextLabel.isHidden = true
        }
        
        // Configura el estado del botón de obtención de ubicación
        configureGetButton()
    }


    // Función para iniciar el administrador de ubicación y comenzar la obtención de ubicación
    func startLocationManager() {
        // Verifica si los servicios de ubicación están habilitados en el dispositivo
        if CLLocationManager.locationServicesEnabled() {
            // Asigna el controlador de delegado al administrador de ubicación
            locationManager.delegate = self
            
            // Establece la precisión deseada para la obtención de ubicación
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
            // Inicia la actualización continua de la ubicación
            locationManager.startUpdatingLocation()
            
            // Indica que la obtención de ubicación está en curso
            updatingLocation = true

            // Configura un temporizador para controlar el tiempo de espera en la obtención de ubicación
            timer = Timer.scheduledTimer(
                timeInterval: 60,
                target: self,
                selector: #selector(didTimeOut),
                userInfo: nil,
                repeats: false)
        }
    }

    // Función para detener el administrador de ubicación y la obtención de ubicación
    func stopLocationManager() {
        // Verifica si la obtención de ubicación está en curso
        if updatingLocation {
            // Detiene la actualización continua de la ubicación
            locationManager.stopUpdatingLocation()
            
            // Anula la asignación del controlador de delegado al administrador de ubicación
            locationManager.delegate = nil
            
            // Indica que la obtención de ubicación ya no está en curso
            updatingLocation = false

            // Verifica si hay un temporizador activo y lo invalida
            if let timer = timer {
                timer.invalidate()
            }
        }
    }


    // Función para configurar el estado del botón de obtención de ubicación
    func configureGetButton() {
        // Identificador para la vista de actividad (spinner)
        let spinnerTag = 1000

        // Verifica si la obtención de ubicación está en curso
        if updatingLocation {
            // Cambia el título del botón a "Stop" mientras la obtención de ubicación está en curso
            getButton.setTitle("Stop", for: .normal)

            // Verifica si no hay una vista de actividad (spinner) con el identificador existente
            if view.viewWithTag(spinnerTag) == nil {
                // Crea y configura una vista de actividad (spinner)
                let spinner = UIActivityIndicatorView(style: .medium)
                spinner.center = messageLabel.center
                spinner.center.y += spinner.bounds.size.height / 2 + 25
                spinner.startAnimating()
                spinner.tag = spinnerTag
                
                // Agrega la vista de actividad al contenedor de la vista
                containerView.addSubview(spinner)
            }
        } else {
            // Cambia el título del botón a "Get My Location" cuando la obtención de ubicación no está en curso
            getButton.setTitle("Get My Location", for: .normal)

            // Verifica si hay una vista de actividad (spinner) con el identificador existente
            if let spinner = view.viewWithTag(spinnerTag) {
                // Remueve la vista de actividad del contenedor de la vista
                spinner.removeFromSuperview()
            }
        }
    }

    // Función que genera una cadena de texto formateada a partir de un placemark (información de dirección)
    func string(from placemark: CLPlacemark) -> String {
        // Línea 1 de la dirección
        var line1 = ""
        // Agrega el subárea si está disponible
        line1.add(text: placemark.subThoroughfare)
        // Agrega la calle (thoroughfare) con un espacio como separador
        line1.add(text: placemark.thoroughfare, separatedBy: " ")

        // Línea 2 de la dirección
        var line2 = ""
        // Agrega la localidad (city)
        line2.add(text: placemark.locality)
        // Agrega el área administrativa (administrative area) con un espacio como separador
        line2.add(text: placemark.administrativeArea, separatedBy: " ")
        // Agrega el código postal (postal code) con un espacio como separador
        line2.add(text: placemark.postalCode, separatedBy: " ")

        // Agrega la línea 2 al final de la línea 1, separada por una nueva línea
        line1.add(text: line2, separatedBy: "\n")
        
        // Devuelve la cadena de texto completa
        return line1
    }

    // Función invocada cuando se alcanza el tiempo de espera para obtener la ubicación
    @objc func didTimeOut() {
        // Imprime un mensaje indicando que se ha agotado el tiempo de espera
        print("*** Time out")
        
        // Verifica si no se ha obtenido ninguna ubicación
        if location == nil {
            // Detiene el administrador de ubicación
            stopLocationManager()
            
            // Crea un objeto NSError para representar un error relacionado con la ubicación
            lastLocationError = NSError(
                domain: "MyLocationsErrorDomain",
                code: 1,
                userInfo: nil)
            
            // Actualiza las etiquetas u otras configuraciones relacionadas con la interfaz de usuario
            updateLabels()
        }
    }


    // Función para mostrar la vista del logotipo
    func showLogoView() {
        // Verifica si la vista del logotipo no está actualmente visible
        if !logoVisible {
            // Marca la vista del logotipo como visible
            logoVisible = true
            
            // Oculta el contenedor principal
            containerView.isHidden = true
            
            // Agrega el botón del logotipo a la vista principal
            view.addSubview(logoButton)
        }
    }


    // Función para ocultar la vista del logotipo
    func hideLogoView() {
        // Verifica si la vista del logotipo ya está oculta
        if !logoVisible { return }

        // Marca la vista del logotipo como no visible
        logoVisible = false
        
        // Muestra el contenedor principal
        containerView.isHidden = false
        
        // Configura la posición inicial del contenedor principal fuera del límite derecho de la vista
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2

        // Calcula el centro en el eje x de la vista principal
        let centerX = view.bounds.midX

        // Configura la animación para mover el contenedor principal hacia el centro de la vista
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = CAMediaTimingFillMode.forwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: containerView.center)
        panelMover.toValue = NSValue(
          cgPoint: CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(
          name: CAMediaTimingFunctionName.easeOut)
        panelMover.delegate = self
        containerView.layer.add(panelMover, forKey: "panelMover")

        // Configura la animación para mover el botón del logotipo hacia la izquierda de la vista
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = CAMediaTimingFillMode.forwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(
          cgPoint: CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(
          name: CAMediaTimingFunctionName.easeIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")

        // Configura la animación de rotación para girar el botón del logotipo mientras se mueve
        let logoRotator = CABasicAnimation(
          keyPath: "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = CAMediaTimingFillMode.forwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * Double.pi
        logoRotator.timingFunction = CAMediaTimingFunction(
          name: CAMediaTimingFunctionName.easeIn)
        logoButton.layer.add(logoRotator, forKey: "logoRotator")
    }


  // MARK: - Sound effects
    // Función para cargar un efecto de sonido
    func loadSoundEffect(_ name: String) {
        // Obtiene la ruta del archivo de sonido desde el paquete principal
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            // Crea un objeto URL a partir de la ruta del archivo
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            
            // Variable para almacenar el identificador del sistema de sonido
            var soundID: SystemSoundID = 0
            
            // Crea el identificador del sistema de sonido a partir del archivo de sonido
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
            
            // Verifica si hay algún error al crear el identificador del sistema de sonido
            if error != kAudioServicesNoError {
                // Imprime un mensaje si hay un error y muestra el código de error y la ruta del archivo
                print("Error code \(error) loading sound: \(path)")
            }
        }
    }

    // Función para liberar un efecto de sonido cargado
    func unloadSoundEffect() {
        // Libera el identificador del sistema de sonido
        AudioServicesDisposeSystemSoundID(soundID)
        
        // Restablece el identificador del sistema de sonido a 0
        soundID = 0
    }


    // Función para reproducir el efecto de sonido cargado
    func playSoundEffect() {
        // Utiliza la función AudioServicesPlaySystemSound para reproducir el sonido identificado por soundID
        AudioServicesPlaySystemSound(soundID)
    }


    // MARK: - Métodos Delegados de Animación

    // Función del delegado de animación que se llama cuando una animación ha finalizado
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // Elimina todas las animaciones aplicadas al contenedor principal
        containerView.layer.removeAllAnimations()
        
        // Restablece la posición del contenedor principal al centro de la vista
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        
        // Elimina todas las animaciones aplicadas al botón del logotipo
        logoButton.layer.removeAllAnimations()
        
        // Elimina el botón del logotipo de la vista principal
        logoButton.removeFromSuperview()
    }

}
