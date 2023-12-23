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
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Llamada al método awakeFromNib de la superclase para realizar cualquier inicialización necesaria.

        // Puedes agregar código de inicialización personalizado aquí si es necesario.
        // Por ejemplo, configurar las propiedades visuales de la celda o realizar otras tareas de configuración.
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Llamada al método setSelected de la superclase para gestionar la selección de la celda.

        // Puedes agregar código de personalización aquí para la apariencia de la celda en función de si está seleccionada o no.
        // Por ejemplo, cambiar el fondo o el color del texto de la celda en función del estado de selección.
    }

  // MARK: - Helper Method
    func configure(for location: Location) {
        // Esta función se utiliza para configurar la apariencia de una celda de ubicación con los datos de una ubicación específica.

        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        // Configura el texto de la etiqueta `descriptionLabel` con la descripción de la ubicación. Si la descripción está vacía, muestra "(No Description)".

        if let placemark = location.placemark {
            // Si la ubicación tiene información de placemark (información de dirección).

            var text = ""
            if let tmp = placemark.subThoroughfare {
                text += tmp + " "
            }
            if let tmp = placemark.thoroughfare {
                text += tmp + ", "
            }
            if let tmp = placemark.locality {
                text += tmp
            }
            addressLabel.text = text
        } else {
            // Si la ubicación no tiene información de placemark (información de dirección).

            addressLabel.text = String(
                format: "Lat: %.8f, Long: %.8f",
                location.latitude,
                location.longitude)
        }
        // Configura el texto de la etiqueta `addressLabel` con la información de dirección si está disponible en la ubicación. Si no hay información de dirección, muestra las coordenadas de latitud y longitud.
        
        photoImageView.image = thumbnail(for: location)
        // Asigna la imagen de la miniatura generada para la ubicación a la vista de imagen (photoImageView).

        
    }
    
    func thumbnail(for location: Location) -> UIImage {
        // Verifica si la ubicación tiene una foto y si la imagen de la foto existe.
        if location.hasPhoto, let image = location.photoImage {
            // Devuelve la imagen redimensionada con límites de tamaño de 52x52.
            return image.resized(withBounds: CGSize(width: 52, height: 52))
        }
        
        // Si no hay foto o la imagen de la foto no existe, devuelve una UIImage vacía.
        return UIImage()
    }



    
}
