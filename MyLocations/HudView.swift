//
//  HudView.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 05/10/23.
//

import UIKit

class HudView: UIView {
    var text = ""

    class func hud(inView view: UIView, animated: Bool) -> HudView {
        // Método de clase para mostrar un indicador visual Hud en una vista
        
        // Crea una instancia de HudView que ocupa toda la vista especificada
        let hudView = HudView(frame: view.bounds)
        
        // Establece la opacidad de hudView en falso para que sea transparente
        hudView.isOpaque = false

        // Agrega hudView como subvista a la vista especificada
        view.addSubview(hudView)
        
        // Deshabilita la interacción del usuario en la vista principal para evitar interacciones mientras se muestra el Hud
        view.isUserInteractionEnabled = false
        
        // Muestra la vista Hud con animación si es necesario
        hudView.show(animated: animated)

        // Devuelve la instancia de HudView creada
        return hudView
    }

    override func draw(_ rect: CGRect) {
        // Método que se llama para dibujar el contenido de la vista
        
        // Especifica las dimensiones del cuadro (box) a dibujar
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96

        // Calcula el rectángulo (boxRect) donde se dibujará el cuadro
        let boxRect = CGRect(
          x: round((bounds.size.width - boxWidth) / 2),
          y: round((bounds.size.height - boxHeight) / 2),
          width: boxWidth,
          height: boxHeight)

        // Crea un UIBezierPath para dibujar un rectángulo redondeado con esquinas redondeadas
        let roundedRect = UIBezierPath(
          roundedRect: boxRect,
          cornerRadius: 10)
        
        // Establece el color de relleno del rectángulo redondeado
        UIColor(white: 0.3, alpha: 0.8).setFill()
        
        // Rellena el rectángulo redondeado con el color especificado
        roundedRect.fill()

        // Dibuja el checkmark (marca de verificación)
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(
              x: center.x - round(image.size.width / 2),
              y: center.y - round(image.size.height / 2) - boxHeight / 8)
            
            // Dibuja la imagen del checkmark en la ubicación especificada
            image.draw(at: imagePoint)
        }

        // Dibuja el texto
        let attribs = [
          NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
          NSAttributedString.Key.foregroundColor: UIColor.white
        ]

        // Calcula el tamaño del texto
        let textSize = text.size(withAttributes: attribs)

        // Calcula la ubicación donde se dibujará el texto
        let textPoint = CGPoint(
          x: center.x - round(textSize.width / 2),
          y: center.y - round(textSize.height / 2) + boxHeight / 4)

        // Dibuja el texto en la ubicación especificada con los atributos especificados
        text.draw(at: textPoint, withAttributes: attribs)
    }


  // MARK: - Helper methods
    func show(animated: Bool) {
        // Método para mostrar la vista con una animación opcional
        
        if animated {
            // Si se desea una animación:
            
            // Configura la opacidad de la vista en 0 (invisible)
            alpha = 0
            
            // Aplica una transformación de escala para hacer la vista más grande
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)

            // Inicia una animación con propiedades específicas
            UIView.animate(
                withDuration: 0.3, // Duración de la animación (0.3 segundos)
                delay: 0, // Sin retraso inicial
                usingSpringWithDamping: 0.7, // Efecto de rebote moderado
                initialSpringVelocity: 0.5, // Velocidad inicial del rebote
                options: [], // Sin opciones adicionales
                animations: {
                    // Bloque de animaciones
                    self.alpha = 1 // Cambia la opacidad de la vista a 1 (visible)
                    self.transform = CGAffineTransform.identity // Restablece la transformación a la identidad (tamaño original)
                }, completion: nil) // Sin bloque de finalización
        }
    }


    func hide() {
        // Método para ocultar la vista
        
        // Habilita la interacción del usuario en la vista principal
        superview?.isUserInteractionEnabled = true
        
        // Elimina la vista actual de su super vista
        removeFromSuperview()
    }

}
