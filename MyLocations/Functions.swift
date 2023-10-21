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
let applicationDocumentsDirectory: URL = {
  let paths = FileManager.default.urls(
    for: .documentDirectory,
       in: .userDomainMask)
  return paths[0]
}()

let dataSaveFailedNotification = Notification.Name(
  rawValue: "DataSaveFailedNotification")

func fatalCoreDataError(_ error: Error) {
  print("*** Fatal error: \(error)")
  NotificationCenter.default.post(
    name: dataSaveFailedNotification,
    object: nil)
}


