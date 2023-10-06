//
//  Functions.swift
//  MyLocations
//
//  Created by Benjamin Jaramillo on 05/10/23.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    // Método que ejecuta una tarea después de un cierto número de segundos
    
    DispatchQueue.main.asyncAfter(
        deadline: .now() + seconds, // Calcula la fecha límite en el futuro
        execute: run) // Ejecuta la tarea especificada después del retraso
}


