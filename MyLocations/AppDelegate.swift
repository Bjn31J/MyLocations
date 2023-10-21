//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 06/09/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // Este método se llama cuando la aplicación está siendo lanzada.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Punto de anulación para la personalización después del lanzamiento de la aplicación.
        // Imprime la ruta al directorio de documentos de la aplicación.
        print(applicationDocumentsDirectory)
        return true // Indica que el lanzamiento de la aplicación fue exitoso.
    }

    // MARK: UISceneSession Lifecycle

    // Este método se llama cuando se está creando una nueva sesión de escena.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Llamado cuando se está creando una nueva sesión de escena.
        // Se utiliza este método para seleccionar una configuración para crear la nueva escena.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // Este método se llama cuando el usuario descarta sesiones de escena.
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Llamado cuando el usuario descarta una sesión de escena.
        // Si se descartaron sesiones mientras la aplicación no estaba en ejecución, esto se llamará poco después de application:didFinishLaunchingWithOptions.
        // Utiliza este método para liberar cualquier recurso específico de las escenas descartadas, ya que no se restaurarán.
    }
}


