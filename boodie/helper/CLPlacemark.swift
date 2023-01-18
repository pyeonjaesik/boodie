//
//  CLPlacemark.swift
//  boodie
//
//  Created by jaesik pyeon on 2023/01/12.
//

import CoreLocation

extension CLPlacemark {

    var address: String? {
        if let name = name {
            var result = name
            if let country = country {
                result += ", =\(country)"
            }
            if let street = thoroughfare {
                result += ", \(street)"
            }

            if let city = locality {
                result += ", \(city)"
            }



            return result
        }

        return nil
    }

    var street: String? {
        if let name = name {
            var result = name

            if let street = thoroughfare {
                result = "\(street)"
            }
            return result
        }

        return nil
    }
}
