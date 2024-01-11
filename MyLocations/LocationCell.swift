//
//  LocationCell.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 03/11/23.
//

import UIKit

class LocationCell: UITableViewCell {
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var addressLabel: UILabel!
  @IBOutlet var photoImageView: UIImageView!
  
    // Sobrescribe el método awakeFromNib de la clase actual (posiblemente una celda de tabla o una vista de tabla personalizada)
    override func awakeFromNib() {
        // Llama al método awakeFromNib de la clase base
        super.awakeFromNib()
        
        // Aplica esquinas redondeadas a la imagen (assumiendo que photoImageView es una instancia de UIImageView)
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
        
        // Permite que las esquinas redondeadas de la imagen se muestren correctamente recortando cualquier contenido que se desborde
        photoImageView.clipsToBounds = true
        
        // Establece la separación del borde izquierdo de la celda (o vista) para que haya un espacio antes del contenido
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Llamada al método setSelected de la superclase para gestionar la selección de la celda.

        // Puedes agregar código de personalización aquí para la apariencia de la celda en función de si está seleccionada o no.
        // Por ejemplo, cambiar el fondo o el color del texto de la celda en función del estado de selección.
    }

  // MARK: - Helper Method
    //nuevo
    
    // Función para configurar la apariencia de una celda o vista con información de ubicación
    func configure(for location: Location) {
        // Verifica si la descripción de la ubicación está vacía
        if location.locationDescription.isEmpty {
            // Si está vacía, establece el texto de la etiqueta de descripción como "(No Description)"
            descriptionLabel.text = "(No Description)"
        } else {
            // Si no está vacía, establece el texto de la etiqueta de descripción como la descripción de la ubicación
            descriptionLabel.text = location.locationDescription
        }

        // Verifica si hay un placemark asociado con la ubicación
        if let placemark = location.placemark {
            // Si hay un placemark, construye una cadena formateada con información de dirección
            var text = ""
            text.add(text: placemark.subThoroughfare)
            text.add(text: placemark.thoroughfare, separatedBy: " ")
            text.add(text: placemark.locality, separatedBy: ", ")
            
            // Establece el texto de la etiqueta de dirección con la información de dirección formateada
            addressLabel.text = text
        } else {
            // Si no hay placemark, establece el texto de la etiqueta de dirección con las coordenadas de latitud y longitud
            addressLabel.text = String(
                format: "Lat: %.8f, Long: %.8f",
                location.latitude,
                location.longitude)
        }
        
        // Establece la imagen de la imagen de la ubicación utilizando la miniatura generada
        photoImageView.image = thumbnail(for: location)
    }

    func thumbnail(for location: Location) -> UIImage {
        // Verifica si la ubicación tiene una foto y si la imagen de la foto existe.
        if location.hasPhoto, let image = location.photoImage {
            // Devuelve la imagen redimensionada con límites de tamaño de 52x52.
            return image.resized(withBounds: CGSize(width: 52, height: 52))
        }
        
        // Si no hay foto o la imagen de la foto no existe, devuelve una UIImage vacía.
        return UIImage(named: "No Photo")!
    }



    
}
