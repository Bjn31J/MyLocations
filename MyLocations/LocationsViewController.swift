//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 03/11/23.
//
import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    // Declaración de una clase llamada LocationsViewController que hereda de UITableViewController.

    var managedObjectContext: NSManagedObjectContext!
    // Declaración de una variable llamada managedObjectContext que almacena una instancia de NSManagedObjectContext,
    // que se utiliza para interactuar con la capa de datos de Core Data.

    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
        // Declaración de una propiedad calculada llamada fetchedResultsController que utiliza una inicialización lenta.

        let fetchRequest = NSFetchRequest<Location>()
        // Crea un objeto de tipo NSFetchRequest para recuperar objetos de tipo Location.

        let entity = Location.entity()
        // Obtiene la entidad correspondiente a la clase Location en el contexto de datos.
        fetchRequest.entity = entity

        let sort1 = NSSortDescriptor(key: "category", ascending: true)
        let sort2 = NSSortDescriptor(key: "date", ascending: true)
        // Crea dos descriptores de ordenación para ordenar los resultados por "category" y "date".
        fetchRequest.sortDescriptors = [sort1, sort2]

        fetchRequest.fetchBatchSize = 20
        // Establece un tamaño de lote para las solicitudes de búsqueda de 20 objetos a la vez.

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: "category",
            cacheName: "Locations")
        // Crea un objeto NSFetchedResultsController que se encargará de gestionar y supervisar los resultados de la búsqueda.

        fetchedResultsController.delegate = self
        // Establece el delegado del fetchedResultsController para que este objeto sea notificado de cambios en los datos.

        return fetchedResultsController
        // Devuelve la instancia del NSFetchedResultsController configurada.
    }()
    // La inicialización lenta garantiza que esta propiedad se inicializará la primera vez que se acceda a ella.

    override func viewDidLoad() {
        super.viewDidLoad()
        // Llama a la implementación del método viewDidLoad en la clase padre.

        performFetch()
        // Llama a la función performFetch() para realizar la búsqueda y cargar los datos.

        navigationItem.rightBarButtonItem = editButtonItem
        // Establece el botón en la barra de navegación superior para permitir la edición de la tabla.
    }


    deinit {
        // Este es el destructor de la clase LocationsViewController.
        // Se llama automáticamente cuando la instancia de la clase se elimina de la memoria.

        fetchedResultsController.delegate = nil
        // Aquí, estamos anulando la referencia al delegado del fetchedResultsController.
        // Esto se hace para evitar problemas de referencia circular y asegurar que el objeto delegado
        // no se mantenga vivo más allá de su tiempo de vida útil, lo que podría causar fugas de memoria.
    }


  // MARK: - Helper methods
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
            // Intenta ejecutar la búsqueda utilizando el fetchedResultsController.

        } catch {
            // Si se produce un error al realizar la búsqueda, entra en el bloque catch.

            fatalCoreDataError(error)
            // Llama a la función "fatalCoreDataError" pasando el error como argumento.
            // Esta función se encargará de manejar errores graves relacionados con Core Data.
        }
    }


  // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Este método se llama automáticamente antes de que una transición de vista tenga lugar.

        if segue.identifier == "EditLocation" {
            // Comprueba si la identificación de la transición es "EditLocation".

            let controller = segue.destination as! LocationDetailsViewController
            // Accede al controlador de destino de la transición como una instancia de LocationDetailsViewController.

            controller.managedObjectContext = managedObjectContext
            // Asigna el contexto de datos administrado (managedObjectContext) al controlador de destino.

            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                // Obtiene el índice de la celda que desencadenó la transición.

                let location = fetchedResultsController.object(at: indexPath)
                // Recupera el objeto Location correspondiente a la celda seleccionada.

                controller.locationToEdit = location
                // Asigna el objeto Location a la propiedad "locationToEdit" en el controlador de destino.
            }
        }
    }

  
  // MARK: - Table View Delegates
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Este método determina el número de secciones en la tabla.

        return fetchedResultsController.sections!.count
        // Retorna el número de secciones en el fetchedResultsController.
        // fetchedResultsController es una instancia de NSFetchedResultsController que gestiona los resultados de la búsqueda en Core Data.
        // El número de secciones generalmente corresponde a las categorías o grupos en los datos.
    }


    override func tableView(
      _ tableView: UITableView,
      titleForHeaderInSection section: Int
    ) -> String? {
      let sectionInfo = fetchedResultsController.sections![section]
      return sectionInfo.name.uppercased()
    }
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Este método devuelve el número de filas en una sección específica de la tabla.

        let sectionInfo = fetchedResultsController.sections![section]
        // Accede a la información de la sección correspondiente en los resultados gestionados por el fetchedResultsController.

        return sectionInfo.numberOfObjects
        // Retorna el número de objetos (ubicaciones en este caso) en la sección especificada.
    }


    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        // Este método se utiliza para configurar y devolver una celda específica para una fila en la tabla.

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "LocationCell",
            for: indexPath) as! LocationCell
        // Dequeue o recupera una celda reutilizable con el identificador "LocationCell" para la fila específica.

        let location = fetchedResultsController.object(at: indexPath)
        // Obtiene el objeto de ubicación correspondiente a la fila (indexPath) en la sección.

        cell.configure(for: location)
        // Configura la celda utilizando el objeto de ubicación obtenido.

        return cell
        // Retorna la celda configurada para que se muestre en la tabla.
    }


    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        // Este método se llama cuando el usuario confirma la acción de eliminar una fila en la tabla.

        if editingStyle == .delete {
            // Comprueba si el estilo de edición es "delete" (eliminar).

            let location = fetchedResultsController.object(at: indexPath)
            // Obtiene el objeto de ubicación correspondiente a la fila que se va a eliminar.
            
            //nuevo
            location.removePhotoFile()

            managedObjectContext.delete(location)
            // Marca el objeto de ubicación para su eliminación en el contexto de datos administrado (Core Data).

            do {
                try managedObjectContext.save()
                // Guarda los cambios en el contexto de datos administrado, lo que efectivamente elimina la ubicación de la base de datos.

            } catch {
                fatalCoreDataError(error)
                // En caso de que ocurra un error al guardar los cambios, se llama a la función "fatalCoreDataError" para manejar el error de manera adecuada.
            }
        }
    }
    override func tableView(
      _ tableView: UITableView,
      viewForHeaderInSection section: Int
    ) -> UIView? {
      let labelRect = CGRect(
        x: 15,
        y: tableView.sectionHeaderHeight - 14,
        width: 300,
        height: 14)
      let label = UILabel(frame: labelRect)
      label.font = UIFont.boldSystemFont(ofSize: 11)

      label.text = tableView.dataSource!.tableView!(
        tableView,
        titleForHeaderInSection: section)

      label.textColor = UIColor(white: 1.0, alpha: 0.6)
      label.backgroundColor = UIColor.clear

      let separatorRect = CGRect(
        x: 15, y: tableView.sectionHeaderHeight - 0.5,
        width: tableView.bounds.size.width - 15,
        height: 0.5)
      let separator = UIView(frame: separatorRect)
      separator.backgroundColor = tableView.separatorColor

      let viewRect = CGRect(
        x: 0, y: 0,
        width: tableView.bounds.size.width,
        height: tableView.sectionHeaderHeight)
      let view = UIView(frame: viewRect)
      view.backgroundColor = UIColor(white: 0, alpha: 0.85)
      view.addSubview(label)
      view.addSubview(separator)
      return view
    }
    
}

// MARK: - NSFetchedResultsController Delegate Extension
extension LocationsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        // Este método se llama antes de que se realicen cambios en los resultados de la búsqueda de Core Data.

        print("*** controllerWillChangeContent")
        // Imprime un mensaje para indicar que se van a producir cambios en los resultados de la búsqueda.

        tableView.beginUpdates()
        // Llama a `beginUpdates()` en la vista de tabla, lo que indica que se comenzarán a aplicar actualizaciones a la tabla.
    }


    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        // Este método se llama cuando se producen cambios en los resultados de la búsqueda de Core Data.

        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            // Si se ha insertado un objeto nuevo en los resultados.

            tableView.insertRows(at: [newIndexPath!], with: .fade)
            // Se inserta una nueva fila en la tabla en la posición indicada por newIndexPath con una animación de desvanecimiento.

        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            // Si se ha eliminado un objeto de los resultados.

            tableView.deleteRows(at: [indexPath!], with: .fade)
            // Se elimina una fila de la tabla en la posición indicada por indexPath con una animación de desvanecimiento.

        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            // Si un objeto existente ha sido actualizado en los resultados.

            if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                // Si la celda de la tabla en indexPath es de tipo LocationCell.

                let location = controller.object(at: indexPath!) as! Location
                // Se obtiene el objeto de ubicación correspondiente a indexPath.

                cell.configure(for: location)
                // Se actualiza la celda para reflejar los cambios en el objeto de ubicación.
            }

        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            // Si un objeto ha sido movido en los resultados.

            tableView.deleteRows(at: [indexPath!], with: .fade)
            // Se elimina la fila de la tabla en la posición original (indexPath) con una animación de desvanecimiento.

            tableView.insertRows(at: [newIndexPath!], with: .fade)
            // Se inserta una nueva fila en la tabla en la nueva posición (newIndexPath) con una animación de desvanecimiento.

        @unknown default:
            print("*** NSFetchedResults unknown type")
            // Si se produce un tipo de cambio desconocido, se imprime un mensaje de advertencia.
        }
    }


    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        // Este método se llama cuando se producen cambios en las secciones de los resultados de la búsqueda de Core Data.

        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            // Si se ha insertado una nueva sección en los resultados.

            tableView.insertSections(
                IndexSet(integer: sectionIndex), with: .fade)
            // Se inserta una nueva sección en la tabla en la posición indicada por sectionIndex con una animación de desvanecimiento.

        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            // Si se ha eliminado una sección de los resultados.

            tableView.deleteSections(
                IndexSet(integer: sectionIndex), with: .fade)
            // Se elimina una sección de la tabla en la posición indicada por sectionIndex con una animación de desvanecimiento.

        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
            // Si se ha actualizado una sección en los resultados.

        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
            // Si se ha movido una sección en los resultados.

        @unknown default:
            print("*** NSFetchedResults unknown type")
            // Si se produce un tipo de cambio desconocido, se imprime un mensaje de advertencia.
        }
    }

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        // Este método se llama cuando se ha completado un conjunto de cambios en los resultados de la búsqueda de Core Data.

        print("*** controllerDidChangeContent")
        // Imprime un mensaje para indicar que se han realizado cambios en los resultados de la búsqueda.

        tableView.endUpdates()
        // Finaliza las actualizaciones pendientes en la vista de tabla, lo que reflejará todos los cambios en la interfaz de usuario.
    }

    
}
