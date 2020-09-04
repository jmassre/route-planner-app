//
//  DisplayRouteController.swift
//  Route Planner
//
//  Created by Joey Massre on 8/12/20.
//  Copyright © 2020 Joey Massre. All rights reserved.
//

import Foundation
import UIKit

class DisplayRouteController: UIViewController, UIScrollViewDelegate {
    
    var allLocations?: [String]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for location in allLocations{
            print(location)
        }
    }
}
