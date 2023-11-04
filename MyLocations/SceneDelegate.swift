//
//  SceneDelegate.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 06/09/23.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Este método se llama cuando la escena de la aplicación se va a conectar.

        let tabController = window!.rootViewController as! UITabBarController
        // Accede al controlador raíz de la ventana, que es un UITabBarController.

        if let tabViewControllers = tabController.viewControllers {
            // Verifica si existen controladores de vista dentro del UITabBarController.

            // Configuración del primer tab (pestaña)
            var navController = tabViewControllers[0] as! UINavigationController
            // Accede al controlador de navegación dentro del primer tab.

            let controller1 = navController.viewControllers.first as! CurrentLocationViewController
            // Accede al primer controlador de vista (CurrentLocationViewController) dentro del controlador de navegación.

            controller1.managedObjectContext = managedObjectContext
            // Asigna el contexto de Core Data (managedObjectContext) al primer controlador de vista.

            // Configuración del segundo tab (pestaña)
            navController = tabViewControllers[1] as! UINavigationController
            // Accede al controlador de navegación dentro del segundo tab.

            let controller2 = navController.viewControllers.first as! LocationsViewController
            // Accede al primer controlador de vista (LocationsViewController) dentro del controlador de navegación.

            controller2.managedObjectContext = managedObjectContext
            // Asigna el contexto de Core Data (managedObjectContext) al segundo controlador de vista.
        }

        listenForFatalCoreDataNotifications()
        // Llama a la función `listenForFatalCoreDataNotifications` para configurar la notificación de errores graves relacionados con Core Data.
    }


  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.

    // Save changes in the application's managed object context when the application transitions to the background.
    saveContext()
  }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        // Crea y configura un contenedor de datos Core Data.

        let container = NSPersistentContainer(name: "MyLocations")
        // Crea un contenedor de datos Core Data con el nombre "MyLocations". Asegúrate de que este nombre coincida con el nombre de tu modelo de datos en el archivo `.xcdatamodeld`.

        container.loadPersistentStores { (_, error) in
            // Carga los almacenes persistentes del contenedor. Esto inicializa y configura la capa de almacenamiento de Core Data.

            if let error = error as NSError? {
                // Si se produce un error durante la carga del almacén persistente.

                fatalError("Could not load data store: \(error)")
                // Lanza un error fatal con un mensaje indicando que no se pudo cargar el almacén de datos y proporciona información detallada del error.
            }
        }

        return container
        // Retorna el contenedor de datos Core Data configurado y listo para ser utilizado en la aplicación.
    }()


    lazy var managedObjectContext = persistentContainer.viewContext
    // Crea una propiedad llamada `managedObjectContext` que representa el contexto de Core Data para operaciones de lectura y escritura.

    // Utiliza la propiedad `viewContext` del `persistentContainer` para obtener el contexto de la vista (principal) asociado al contenedor de datos Core Data. Esto proporciona un contexto de trabajo donde puedes realizar operaciones CRUD (Crear, Leer, Actualizar y Eliminar) en los objetos de la base de datos.

    // La palabra clave `lazy` indica que la propiedad se inicializa solo cuando se accede por primera vez y se almacena para su uso futuro.



    func saveContext() {
        // Esta función se utiliza para guardar los cambios en el contexto de Core Data.

        let context = persistentContainer.viewContext
        // Accede al contexto de vista (viewContext) del contenedor de datos Core Data.

        if context.hasChanges {
            // Verifica si hay cambios no guardados en el contexto.

            do {
                try context.save()
                // Intenta guardar los cambios en el contexto en la base de datos.

            } catch {
                // Si se produce un error al intentar guardar los cambios.

                // En una aplicación de producción, se debe implementar un manejo adecuado de errores en lugar de usar `fatalError()`.
                // La siguiente implementación es para desarrollo y depuración.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                // Lanza un error fatal con un mensaje que indica que se ha producido un error no resuelto al guardar los cambios en Core Data. Esto es útil para la depuración, pero no se debe usar en una aplicación en producción.

                // En una aplicación en producción, puedes implementar un manejo de errores más adecuado, como mostrar un mensaje al usuario o registrar el error en un archivo de registro.
            }
        }
    }


  // MARK: - Helper methods
    func listenForFatalCoreDataNotifications() {
        // Esta función configura un observador de notificaciones para detectar errores graves en Core Data.

        NotificationCenter.default.addObserver(
            forName: dataSaveFailedNotification,
            object: nil,
            queue: OperationQueue.main
        ) { _ in
            // Registra el observador para escuchar la notificación llamada `dataSaveFailedNotification`.

            let message = """
            There was a fatal error in the app and it cannot continue.

            Press OK to terminate the app. Sorry for the inconvenience.
            """
            // Define un mensaje que se mostrará en el cuadro de diálogo de alerta en caso de error grave.

            let alert = UIAlertController(
                title: "Internal Error",
                message: message,
                preferredStyle: .alert)
            // Crea un controlador de alerta con el título "Internal Error" y el mensaje definido.

            let action = UIAlertAction(title: "OK", style: .default) { _ in
                // Define una acción "OK" que se ejecutará cuando el usuario toque el botón OK en el cuadro de diálogo de alerta.

                let exception = NSException(
                    name: NSExceptionName.internalInconsistencyException,
                    reason: "Fatal Core Data error",
                    userInfo: nil)
                exception.raise()
                // Crea y lanza una excepción que terminará la aplicación.

                // Esta es una forma de manejar un error grave, forzando la terminación de la aplicación cuando ocurre un error crítico.

            }
            alert.addAction(action)
            // Agrega la acción "OK" al cuadro de diálogo de alerta.

            let tabController = self.window!.rootViewController!
            tabController.present(
                alert,
                animated: true,
                completion: nil)
            // Muestra el cuadro de diálogo de alerta en la interfaz de usuario.
        }
    }

}

