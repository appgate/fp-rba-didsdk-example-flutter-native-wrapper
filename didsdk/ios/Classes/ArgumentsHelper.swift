//
//  ArgumentsHelper.swift
//  didsdk
//
//  Created by Camilo Ortegon on 5/19/23.
//

import Foundation

class ArgumentsHelper {
    
    static func parseParams(_ call: FlutterMethodCall) -> Dictionary<String, Any>? {
        if let args = call.arguments as? Dictionary<String, Any>{
            return args
        }
        return nil
    }
    
}
