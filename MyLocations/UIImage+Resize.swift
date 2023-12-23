//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 18/12/23.
//

import UIKit

extension UIImage {
  func resized(withBounds bounds: CGSize) -> UIImage {
    // Calcula el ratio de escala para ajustar la imagen dentro de los límites especificados.
    let horizontalRatio = bounds.width / size.width
    let verticalRatio = bounds.height / size.height
    let ratio = min(horizontalRatio, verticalRatio)

    // Calcula el nuevo tamaño de la imagen basado en el ratio de escala.
    let newSize = CGSize(
      width: size.width * ratio,
      height: size.height * ratio)

    // Inicia el contexto gráfico con el nuevo tamaño.
    UIGraphicsBeginImageContextWithOptions(newSize, true, 0)

    // Dibuja la imagen escalada en el contexto gráfico.
    draw(in: CGRect(origin: CGPoint.zero, size: newSize))

    // Obtiene la nueva imagen del contexto gráfico.
    let newImage = UIGraphicsGetImageFromCurrentImageContext()

    // Finaliza el contexto gráfico.
    UIGraphicsEndImageContext()

    // Devuelve la nueva imagen (asegurándose de que no sea nula, aunque en la práctica debería existir).
    return newImage!
  }
}
