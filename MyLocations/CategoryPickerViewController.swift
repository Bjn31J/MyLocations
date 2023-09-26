//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 25/09/23.
//


import UIKit

class CategoryPickerViewController: UITableViewController {
  // Variable para almacenar el nombre de la categoría seleccionada.
  var selectedCategoryName = ""

  // Lista de categorías disponibles.
  let categories = [
    "No Category",
    "Apple Store",
    "Bar",
    "Bookstore",
    "Club",
    "Grocery Store",
    "Historic Building",
    "House",
    "Icecream Vendor",
    "Landmark",
    "Park"
  ]

  // Variable para mantener el índice de la categoría seleccionada.
  var selectedIndexPath = IndexPath()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Al cargar la vista, busca la categoría seleccionada y establece el índice.
    for i in 0..<categories.count {
      if categories[i] == selectedCategoryName {
        selectedIndexPath = IndexPath(row: i, section: 0)
        break
      }
    }
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Preparar para la transición a otra vista (cuando se elige una categoría).
    if segue.identifier == "PickedCategory" {
      let cell = sender as! UITableViewCell
      if let indexPath = tableView.indexPath(for: cell) {
        selectedCategoryName = categories[indexPath.row]
      }
    }
  }
  
  // MARK: - Table View Delegates
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Devuelve el número de elementos en la lista de categorías.
    return categories.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Configura cada celda de la tabla con una categoría.
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

    let categoryName = categories[indexPath.row]
    cell.textLabel!.text = categoryName

    // Configura la marca de verificación para la categoría seleccionada.
    if categoryName == selectedCategoryName {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Cuando se selecciona una categoría, actualiza la marca de verificación.
    if indexPath.row != selectedIndexPath.row {
      if let newCell = tableView.cellForRow(at: indexPath) {
        newCell.accessoryType = .checkmark
      }
      if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
        oldCell.accessoryType = .none
      }
      selectedIndexPath = indexPath
    }
  }
}
