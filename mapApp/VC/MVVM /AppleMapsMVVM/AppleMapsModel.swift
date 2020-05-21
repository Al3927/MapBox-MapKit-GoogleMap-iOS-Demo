//
//  AppleMapsViewModel.swift
//  mapApp
//
//  Created by user on 5/18/20.
//  Copyright © 2020 Vinova.Train.mapApp. All rights reserved.
//

import Foundation

import CoreLocation

struct AppleMapsPlaceMark{
    
    var Name: String
    
    var placeName: String
    
    var longitude: Double
    
    var latitude: Double
    
    
}

class AppleMapsModel {
    var appleMapsPlaceMarks: [AppleMapsPlaceMark] = []
    
    var placeMark = [PlaceMarkForAllMap]()
}

extension AppleMapsModel:ModelAccess{
    func fetchData(query: String, latitude: Double, longitude: Double) -> [PlaceMarkForAllMap]? {
        print("")
        return nil
    }
    
    func getPlaceMark() -> [PlaceMarkForAllMap] {
        return placeMark
    }
    
    
}