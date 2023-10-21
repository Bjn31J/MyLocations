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
        // Obtén una referencia al controlador de pestañas (UITabBarController) que es la vista raíz de la aplicación.
        let tabController = window!.rootViewController as! UITabBarController

        // Verifica si existen controladores de vista en el controlador de pestañas.
        if let tabViewControllers = tabController.viewControllers {
            // Accede al primer controlador de navegación en la lista de controladores de vista.
            let navController = tabViewControllers[0] as! UINavigationController

            // Accede al primer controlador de vista en el controlador de navegación, que parece ser un 'CurrentLocationViewController'.
            let controller = navController.viewControllers.first as! CurrentLocationViewController

            // Asigna el contexto de objetos gestionados ('managedObjectContext') al controlador de vista.
            controller.managedObjectContext = managedObjectContext
        }

        // Llama a una función llamada 'listenForFatalCoreDataNotifications' para configurar la notificación de errores en Core Data.
        listenForFatalCoreDataNotifications()
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
        // Crea una instancia de NSPersistentContainer con el nombre "MyLocations".
        let container = NSPersistentContainer(name: "MyLocations")

        // Carga las tiendas persistentes (persistent stores) asociadas con el contenedor.
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                // Si se produce un error al cargar las tiendas persistentes, muestra un mensaje de error y finaliza la aplicación.
                fatalError("Could not load data store: \(error)")
            }
        }

        // Devuelve la instancia de NSPersistentContainer configurada.
        return container
    }()
    // Propiedad calculada `managedObjectContext` que se inicializa de manera lenta y obtiene el contexto de vista (`viewContext`) del `persistentContainer`.
    lazy var managedObjectContext = persistentContainer.viewContext

    

    func saveContext () {
        // Función para guardar los cambios en el contexto de Core Data.

        let context = persistentContainer.viewContext
        // Obtiene el contexto de vista del `persistentContainer`.

        if context.hasChanges {
            // Comprueba si el contexto tiene cambios pendientes.

            do {
                try context.save()
                // Intenta guardar los cambios en el contexto.

            } catch {
                // Si se produce un error al guardar los cambios, se maneja el error.

                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                // Si no se puede manejar el error, se llama a `fatalError` para generar un registro de error y finalizar la aplicación.
                
            }
        }
    }
    func listenForFatalCoreDataNotifications() {
        NotificationCenter.default.addObserver(
            forName: dataSaveFailedNotification,
            object: nil,
            queue: OperationQueue.main
        ) { _ in
            // Se registra un observador para la notificación 'dataSaveFailedNotification'.

            let message = """
            There was a fatal error in the app and it cannot continue.

            Press OK to terminate the app. Sorry for the inconvenience.
            """
            // Se crea un mensaje de error que se mostrará al usuario.

            let alert = UIAlertController(
                title: "Internal Error",
                message: message,
                preferredStyle: .alert)
            // Se crea un controlador de alerta para mostrar el mensaje de error.

            let action = UIAlertAction(title: "OK", style: .default) { _ in
                let exception = NSException(
                    name: NSExceptionName.internalInconsistencyException,
                    reason: "Fatal Core Data error",
                    userInfo: nil)
                exception.raise()
            }
            // Se crea una acción "OK" que, al hacer clic en ella, provocará una excepción.

            alert.addAction(action)
            // Se agrega la acción al controlador de alerta.

            let tabController = self.window!.rootViewController!
            tabController.present(
                alert,
                animated: true,
                completion: nil)
            // Se obtiene una referencia al controlador de pestañas y se presenta el controlador de alerta.
        }
    }



}

