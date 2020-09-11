//
//  SecondViewController.swift
//  Route Planner
//
//  Created by Joey Massre on 8/12/20.
//  Copyright © 2020 Joey Massre. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class SecondViewController: UIViewController, UITableViewDataSource, MKMapViewDelegate {
    
  

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tripTimeLabel: UILabel!
    @IBOutlet var etaLabel: UILabel!
    weak var activityIndicator: UIActivityIndicatorView! //from first view controller
    
    var bestOrderNums = [(Int, Int)]() //array of best order in number form
    
    //best order array
    var bestOrder = [String](){
        didSet {
            tableView.reloadData()
        }
    }
    
    //array of coordinates
    var coordinates: [CLLocationCoordinate2D] = []

    
    var allLocations: [String]? //locations without spcaes for URL, from first view controller
    var isRound: Bool? //from first view controller
    var isEnd: Bool? //from first view controller
    var locationsToPrint = [String]() //locations with spaces and google maps format
    
    
    var allLocationsNoSpace = [String]() //locations without spaces for URL
    
    var graph = [[Int]]() //2D array of our graph
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
 
        //put all locations in the modified locations array without spaces
        
        //append allLocationsNoSpace with allLocations without spaces
        for location in allLocations! {
            allLocationsNoSpace.append( location.filter { !$0.isWhitespace }) //no spaces
        }
        
        
        
        
        
    
        for i in 0...self.allLocationsNoSpace.count-1{
            self.graph.append([])
            for n in 0...self.allLocationsNoSpace.count-1{
       
                
                let url = URL(string: "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(self.allLocationsNoSpace[i])+&destinations=\(self.allLocationsNoSpace[n])&key=APIKEY")!
                let request = URLRequest(url: url)
                //get data from url request
                let data = SecondViewController.requestSynchronousData(request: request)
                
                let lines = String(data: data!, encoding: .utf8)!.components(separatedBy: "\n") //the page in an array split by line
                
                //put the google maps format of the name in the array
                if i == i{
                    locationsToPrint.append(lines[1].components(separatedBy: " : ")[1].replacingOccurrences(of:"\"", with: "").replacingOccurrences(of: "[ ", with: "").replacingOccurrences(of: " ],", with: ""))
                }
                //put each distance in the graph
                self.graph[i].append(Int(lines[13].components(separatedBy: " : ")[1])!)
       
            }
        }
        
        
        //if there's a specific endpoint
        if isEnd!{
            //findRoute executes with the endPoint.. only adds numbers
            bestOrderNums = findRoute(graph: graph,startingPoint: 0, endPoint: allLocations!.count-1)
            
        }
        //if there's no endpoint
        else {
            //findRoute executes without the endPoint... only adds numbers
            bestOrderNums = findRoute(graph: graph,startingPoint: 0)
        }
        
        //go  into the bestOrderNums and append bestOrder array with the names
        for i in 0...bestOrderNums.count-1{
            bestOrder.append(locationsToPrint[bestOrderNums[i].0])
            
            if i == bestOrderNums.count-1{
                bestOrder.append(locationsToPrint[bestOrderNums[i].1])
            }
        }

        
        //go through the order. start at location 2 in order to go from place to place
        for i in 1...bestOrder.count-1{
            let geoCoder = CLGeocoder()
            
            //location 1
            geoCoder.geocodeAddressString(bestOrder[i-1]) {
                placemarks, error in
                let placemark1 = placemarks?.first //placemark
                let lat1 = placemark1?.location?.coordinate.latitude //latitude location 1
                let lon1 = placemark1?.location?.coordinate.longitude //longitude location 2
                let sourceLocation = CLLocationCoordinate2DMake(lat1!, lon1!) //the source location
            
                //location 2
                geoCoder.geocodeAddressString(self.bestOrder[i]) {
                    placemarks, error in
                    let placemark2 = placemarks?.first
                    let lat2 = placemark2?.location?.coordinate.latitude //latitude location 2
                    let lon2 = placemark2?.location?.coordinate.longitude //longitude location 2
                    let destinationLocation = CLLocationCoordinate2DMake(lat2!, lon2!) //the destination location
                    
                    //put it on map with the route
                    self.mapThis(sourceLocation: sourceLocation, sourceTitle: self.bestOrder[i-1], destinationLocation: destinationLocation, destinationTitle: self.bestOrder[i])
                }
            }
           
        }
        //stop showing previous view controller's activity indicator
        activityIndicator.stopAnimating()

    }
        
        
        
    
    
    
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    }
    
    
    //executes the url data synchronously and returns data
    public static func requestSynchronousData(request: URLRequest) -> Data? {
        var data: Data? = nil
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        //waits for each url to load
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            taskData, _, error -> () in
            data = taskData
            if data == nil, let error = error {print(error)}
            semaphore.signal()
        })
        //then resumes the task
        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        return data
    }
    
    //finds the best route and returns an array of Int touples
    //accepts an end point
    func findRoute(graph: [[Int]], startingPoint: Int, endPoint: Int) -> [(Int,Int)]{
        var tempBest = [(Int, Int)]() //fastest order until proven slower
        var best = [(Int, Int)]() //real best, returns at end

        var vertex = [Int]() //vertices
        
        
        for i in 0...allLocationsNoSpace.count-3{ //list of numbers from 1 through the amount of places you'd like to go through subtracted by one
            vertex.append(i+1)
        }
        
        var min = Int.max
        var counter = 0
        //go through each possibility to see fastest route
        while true{
            counter+=1
            var currentTime=0
            var k = startingPoint
            tempBest.removeAll() //tempBest clears at each new cycle

            for i in 0...vertex.count-1{ //go through the places
                
                //currentTime increases at each vertex
                currentTime+=graph[k][vertex[i]]
                //add the vertex to tempbest
                tempBest.append((k,vertex[i]))
        
                //increase k
                k=vertex[i]
            }
            
            //since its a specific end point increase current time to get from last place back to k
            currentTime+=graph[k][endPoint]
            tempBest.append((k,endPoint))
            
            //if its shorter time then make the new best
            if min>currentTime{
                best.removeAll()
                for i in 0...tempBest.count-1{
                    best.append(tempBest[i])
                }
                min=currentTime
            }
            
            
            
            //go through to see if youve gone through every vertex
            if !nextPermutation(L: &vertex){
                break
            }
            
        }
        
        
        //current time
        let date = Date()
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        //get hours mins seconds from seconds it took
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: min)
        
        //make current time not army time
        if hour > 12{
            hour -= 12
        }
        
        //eta times
        var etaHour = hour+h
        var etaMin = minutes+m
        
        
        if etaMin >= 60{
            etaMin -= 60
            etaHour += 1
        }
        
        
        while etaHour > 12{
            etaHour -= 12
        }
    
       
        
        //display total amount of time
        if h != 1 && m != 1{
            tripTimeLabel.text = "Total Time: \(h) hrs \(m) mins"
        }
        if h==1 && m != 1{
            tripTimeLabel.text = "Total Time: \(h) hr \(m) mins"
        }
        if h != 1 && m == 1{
            tripTimeLabel.text = "Total Time: \(h) hrs \(m) min"
        }
        
        if h == 1 && m == 1 {
            tripTimeLabel.text = "Total Time: \(h) hr \(m) min"
        }
        
        //display time it'll take to get there
        etaLabel.text = "ETA: \(etaHour):\(etaMin)"
        return best

    }
    
    
    //finds the best route and returns an array of Int touples
    //doesn't accept an end point
    func findRoute(graph: [[Int]], startingPoint: Int) -> [(Int,Int)]{
        var tempBest = [(Int, Int)]() //fastest order until proven slower
        var best = [(Int, Int)]() //real best, returns at end

        var vertex = [Int]() //vertices
        
        //list of numbers from 1 through the amount of places you'd like to go through subtracted by one
        for i in 0...allLocationsNoSpace.count-2{
            vertex.append(i+1)
        }
        var min = Int.max
        var counter = 0
        
        //go through each possibility to see fastest route
        while true{
            counter+=1
            var currentTime=0
            var k = startingPoint
            tempBest.removeAll() //tempBest clears at each new cycle
            for i in 0...vertex.count-1{
                //currentTime increases at each vertex
                currentTime+=graph[k][vertex[i]]
                 //add the vertex to tempbest
                tempBest.append((k,vertex[i]))
         
                k=vertex[i]
            }
            //if it's a round trip then add the time it takes to get from the last place back to the starting point
            if isRound!{
                currentTime+=graph[k][startingPoint]
                tempBest.append((k,startingPoint))
            }
            
            //if it's shorter make the best equal to the current temp best and update the min
            if min>currentTime{
                best.removeAll()
                for i in 0...tempBest.count-1{ //go through the places
                    best.append(tempBest[i])
                }
                min=currentTime
            }
            
            
            
            //go through to see if youve gone through every vertex
            if !nextPermutation(L: &vertex){
                break
            }
            
        }
        
        //current time
        let date = Date()
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
            
        //get hours mins seconds from seconds it took
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: min)
        
        //make current time not army time
        if hour > 12{
            hour -= 12
        }
        
        //eta times
        var etaHour = hour+h
        var etaMin = minutes+m
        
        
        if etaMin >= 60{
            etaMin -= 60
            etaHour += 1
        }
        
        
        while etaHour > 12{
        etaHour -= 12
        }
        
           

            
        //display time it'll take to get there
        etaLabel.text = "ETA: \(etaHour):\(etaMin)"
            
            
        //display total amount of time
        if h != 1 && m != 1{
            tripTimeLabel.text = "Total Time: \(h) hrs \(m) mins"
        }
        if h==1 && m != 1{
            tripTimeLabel.text = "Total Time: \(h) hr \(m) mins"
        }
        if h != 1 && m == 1{
            tripTimeLabel.text = "Total Time: \(h) hrs \(m) min"
        }
        
        if h == 1 && m == 1 {
            tripTimeLabel.text = "Total Time: \(h) hr \(m) min"
        }
    
            
        
        return best

    }
    
    //helper method to see if you've gone throug every permutation
    func nextPermutation( L: inout [Int]) -> Bool{
        let n = L.count
        var i = n-2
        while i>=0 && L[i]>=L[i+1]{
            i-=1
        }
        if i == -1{
            return false
        }
        var j=i+1
        
        while j<n && L[j]>L[i]{
            j+=1
        }
        j-=1
        
        let temp = L[i]
        L[i] = L[j]
        L[j] = temp
        
        var left = i+1
        var right = n-1
        while left<right{
            let temp1 = L[left]
            L[left] = L[right]
            L[right] = temp1
            left+=1
            right-=1
        }
        return true
        
        
        
    }
    
    

    
   override func viewWillDisappear(_ animated: Bool) {
    
    //always check to see if moving back to home screen and if so, clear data
    if self.isMovingFromParent {
        allLocationsNoSpace = [String]()
        allLocations = [String]()
        bestOrderNums = [(Int,Int)]()
        bestOrder = [String]()
        
      }
      }
    
    
    
    //gets hours,minutes,seconds
    //helper method
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    //sets amount of rows in tableview
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 1
        return bestOrder.count
    }
        
    //input each location in tableview
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        let location = bestOrder[indexPath.row]

        cell.textLabel!.text = "\(indexPath.row+1). \(location)"
        
        return cell
    }

    
    //maps the directions and put the placemarks of inputed coordinates
    func mapThis(sourceLocation: CLLocationCoordinate2D, sourceTitle: String, destinationLocation : CLLocationCoordinate2D, destinationTitle: String) {
        //source placemark
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        //destination placemark
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)

        //actual items in the map
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        // name of source place on the map
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = sourceTitle

        //put each coordinate into the map itself
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }

        //name of destination place on the map
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = destinationTitle

        //put each coordinate into the map itself
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }

        // show the names
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )

        // request directions
         let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile

        // Calculate the direction
        let directions = MKDirections(request: directionRequest)

        directions.calculate {
            (response, error) -> Void in

            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }

                return
            }

            let route = response.routes[0]
         self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)

            let rect = route.polyline.boundingMapRect
         self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    //draws the route between each location
    //helper method
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        return render
    }


    
     
    
   
}



