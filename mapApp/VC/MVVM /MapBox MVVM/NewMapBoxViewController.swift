//
//  GoogleMapViewController.swift
//  mapApp
//
//  Created by user on 5/15/20.
//  Copyright © 2020 Vinova.Train.mapApp. All rights reserved.
//

import UIKit

import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class setStack: UIStackView {
    var sizeee: CGSize {
        return self.superview!.frame.size
    }
    override var intrinsicContentSize: CGSize {
        return sizeee
    }
}

class NewMapBoxViewController: UIViewController {
    
    var annotations = [MGLPointAnnotation()]
    var whatIndexOfViewModelInViewModels = 0
    var spacing: CGFloat = 12.0
    var btnSize: CGFloat = 12.0
    var customView = UIView()
    var queryService = MainQueryService(queryServiceAccess: .MapBox)
    var mapsViewModel = MapsViewModel(modelAccess: .MapBox)
    var mapsViewModels = [MapsViewModel(modelAccess: .MapBox)]
    lazy var SearchTable = SearchTableViewController()
    var directionsRoute: Route?
    
    lazy var mapView = NavigationMapView(frame: view.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false

        //SearchTable.modelAccess = .MapBox
        SearchTable.handleMapSearchDelegate = self
        
        configureMap()
        configureActivityIndicator()
      
        configureSearchButton()
        
//        self.view.addSubview(customView)
//         configureCustomView()
//        
//        ConfigureVStack()
        configureButtonBusStop()

        mapsViewModel.userLocation = self.mapView.userLocation!.coordinate
        
        SearchTable.tableView.estimatedRowHeight = 90
        SearchTable.tableView.rowHeight = UITableView.automaticDimension

        
    }
    
    
    //MARK: ConfigureVStack
    func ConfigureVStack(){
        let busStopButton = NewButton(title: "🚌")
                
        let goToUserLocationButton = NewButton(title: "👤")

                
        let VStack = creatStack(button: [goToUserLocationButton,busStopButton])
                
        print("\(String(describing: busStopButton.titleLabel))")


                
        customView.addSubview(VStack)
            
        //
                
        let viewsDictionary = ["VStack": VStack]

                
        let VStack_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[VStack]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)

                
        let VStack_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[VStack]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue:0), metrics: nil, views: viewsDictionary)

                
        customView.addConstraints(VStack_H)
                
        customView.addConstraints(VStack_V)
        
        print("\(busStopButton)")
        print("CS: \(customView.frame), \(customView.bounds)")
        print("\(String(describing: goToUserLocationButton.titleLabel))")
    }
    
    func updateUserLocation(){ //Just Idea
        while mapsViewModel.userLocation != self.mapView.userLocation!.coordinate {
            mapsViewModel.userLocation = self.mapView.userLocation!.coordinate
            //Dat ham nay o dau?
            //Neu dang di dung lai va hai ve bang nhau?
            //Neu di den diem dung, trong ham duoi da xu ly chua?
            self.calculateRoute(from: (self.mapView.userLocation!.coordinate), to: annotation.coordinate) { (route, error) in
                if error != nil {
                    print("Error calculating route")
                           //activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    //MARK: Configure CustomView
    func configureCustomView(){
        
        customView.translatesAutoresizingMaskIntoConstraints = false
        
        
            let viewsDictionary = ["customView": customView]
            
            
//            let customView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(view.bounds.maxX-spacing-btnSize)-[customView]-\(spacing)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
//
//            let customView_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(view.bounds.maxY/2-btnSize)-[customView]-\(view.bounds.maxY/2)-|", options: NSLayoutConstraint.FormatOptions(rawValue:0), metrics: nil, views: viewsDictionary)
        
        let customView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[customView]-50-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
                 
        let customView_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[customView]-50-|", options: NSLayoutConstraint.FormatOptions(rawValue:0), metrics: nil, views: viewsDictionary)
            
              view.addConstraints(customView_H)
              view.addConstraints(customView_V)
        
        print("customViewAdd!")
        
        
    }
    
    // MARK: CreatNewButton
    
    func NewButton(title: String) -> UIButton{
        let newButton = UIButton()
        //newButton.frame.size = CGSize(width: btnSize, height: btnSize)
        newButton.addTarget(self, action: #selector(ButtonCenter), for: .touchUpInside)
        newButton.backgroundColor = .clear
        //👤 🚌
        newButton.setTitle(title, for: .normal)
        newButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body).withSize(27)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        //customView.frame.origin = CGPoint(x:view.bounds.maxX-spacing,y:view.bounds.maxY/2)
        
        print("Creat New Button!")

        return newButton
    }
    
    //MARK: ButtonCenter
    @objc func ButtonCenter(sender: UIButton!){
        
        if sender.title(for: .normal) == "🚌" {
            
             activityIndicator.startAnimating()
            self.queryService.getData(query: "bus stop", latitude:mapsViewModel.userLocation.latitude, longitude: mapsViewModel.userLocation.longitude )
                   
            
                   self.queryService._queryServiceAccess?.parseDataDelegate = self
            
            self.calculateRoute(from: (self.mapView.userLocation!.coordinate), to: (self.mapView.userLocation!.coordinate)) { (route, error) in
                                  if error != nil {
                                             print("Error calculating route")
                                             //activityIndicator.stopAnimating()
                                         }
                              }
                           

                   mapView.clearsContextBeforeDrawing = true
                   mapView.removeRoutes()
                   removeAllAnnotations()

                   annotations.removeAll()
                  
                
                   
                   for i in mapsViewModels.indices{
                       print("i:\(i)\n")
                   guard let longitude = self.mapsViewModels[i].longitude else {
                              return
                          }
                          guard let latitude = self.mapsViewModels[i].latitude else {
                              return
                          }
                          guard let name = self.mapsViewModels[i].Name else {
                              return
                          }
                          guard let placeName = self.mapsViewModels[i].placeName else {
                              return
                          }
                       
                       let temp = MGLPointAnnotation()
                      
                       temp.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                                 
                       print("annotation coordinate update view from model: \(annotation.coordinate)")
                              
                       temp.title = name
                       
                       temp.subtitle = placeName

                       //Why it's not work exactly if we use this function? (Test: Print annotations exactly but can not show it in the map!)
                       //let temp = addAnnotations(longitude: longitude, latitude: latitude, name: name, placeName: placeName)
                       
                       
                       annotations.append(temp)
                       self.mapView.addAnnotation(annotations[i])
                       
                   }

                   
                   activityIndicator.stopAnimating()
            
        }
    }
    
    @objc func GoToUserLocation(){
        mapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
    }
    
    //MARK: Button Tam thoi
    
    func configureButtonBusStop(){
        let GoToUserLocationButton = UIButton()
        GoToUserLocationButton.addTarget(self, action: #selector(ButtonCenter), for: .touchUpInside)
        GoToUserLocationButton.backgroundColor = .clear
        GoToUserLocationButton.setTitle("🚌", for: .normal)
        GoToUserLocationButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body).withSize(27)
        GoToUserLocationButton.translatesAutoresizingMaskIntoConstraints = false
        //customView.frame.origin = CGPoint(x:view.bounds.maxX-spacing,y:view.bounds.maxY/2)
        
        self.view.addSubview(GoToUserLocationButton)
          
        let viewsDictionary = ["GoToUserLocationButton": GoToUserLocationButton]
        
        
        let GoToUserLocationButton_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(view.bounds.maxX-spacing)-[GoToUserLocationButton]-\(spacing)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
                 
        let GoToUserLocationButton_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(view.bounds.maxY/2)-[GoToUserLocationButton]-\(view.bounds.maxY/2)-|", options: NSLayoutConstraint.FormatOptions(rawValue:0), metrics: nil, views: viewsDictionary)
        
          view.addConstraints(GoToUserLocationButton_H)
          view.addConstraints(GoToUserLocationButton_V)
        print("ButtonAdd!")
        
    }

    
    //MARK: Creat Stack
    
    func creatStack(button: [UIView], isFillEqually: Bool = true) -> UIStackView {
         
         let stackView = setStack(arrangedSubviews: button)
        
        stackView.axis = .vertical
         if isFillEqually {
             stackView.distribution = .fillEqually
         } else {
             stackView.distribution = .fill
         }
         
         stackView.alignment = .fill
         stackView.spacing = spacing
         stackView.translatesAutoresizingMaskIntoConstraints = false
        
        print("Creat Stack!")
         //self.view.addSubview(stackView)
         
         return stackView
    }
       
    
    //MARK: viewWillLayoutSubviews
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        customView.bounds.origin = CGPoint(x:view.bounds.maxX-spacing,y:view.bounds.maxY/2)
    }
    
    func configureGoToNavigationViewButton(){
        let barButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchPlace))
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func configureCenterLabel(){
    
        
    }
    
    
    //MARK: Search Button
    
    func configureSearchButton(){
        let barButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchPlace))
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func searchPlace() {
        
        //queryService.userLocation = self.mapView.userLocation!.coordinate
        mapsViewModel.userLocation = self.mapView.userLocation!.coordinate

        print("user Location: \(self.mapView.userLocation!.coordinate)")
        SearchTable.setQueryService(queryService: queryService)
        SearchTable.setMapsViewModel(mapsViewModel: mapsViewModel)
               
        let searchController = UISearchController(searchResultsController: SearchTable)
        
        //searchController.resignFirstResponder()
               
        searchController.searchResultsUpdater = SearchTable

        searchController.searchBar.delegate = self
               
        searchController.searchBar.placeholder = "Search for places"
               
        searchController.searchBar.resignFirstResponder()
        
        present(searchController, animated: true, completion: nil)
    }

    
    //MARK: configureMap
    
    func configureMap(){
        
        // Set the map view's delegate
              definesPresentationContext = true
               
              mapView.delegate = self
                
              let url = URL(string: "mapbox://styles/mapbox/streets-v11")

              mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
             // mapView.setCenter(CLLocationCoordinate2D(latitude: Mapp.latitude , longitude: Mapp.longtitude), zoomLevel: 9, animated: false)
             
              view.addSubview(mapView)
             //mapView.styleURL = MGLStyle.satelliteStyleURL
              mapView.styleURL = url
              

        // Allow the map view to display the user's location
          
              mapView.showsUserLocation = true
              
              mapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
        
        
        
    }

    //MARK: - Declare and configureActivityIndicator
    let activityIndicator = UIActivityIndicatorView()
    
    func configureActivityIndicator(){
        activityIndicator.style = UIActivityIndicatorView.Style.medium

        activityIndicator.center = self.view.center

        activityIndicator.hidesWhenStopped = true

        self.view.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0).isActive = true
    }
    
    //MARK: Remove All Annotations
    
    func removeAllAnnotations() {
      
      guard let annotations = mapView.annotations else { return print("Annotations Error") }
      
      if annotations.count != 0 {
        for annotation in annotations {
          mapView.removeAnnotation(annotation)
        }
      } else {
        return
      }
    }
    
    //MARK: UpdateViewFromViewModel
    
    var annotation = MGLPointAnnotation()
    
    func UpdateViewFromModel(){
        
        
        mapView.clearsContextBeforeDrawing = true
        //mapView.removeRoutes()
        
//        self.calculateRoute(from: (self.mapView.userLocation!.coordinate), to: (self.mapView.userLocation!.coordinate)) { (route, error) in
//               if error != nil {
//                          print("Error calculating route")
//                          //activityIndicator.stopAnimating()
//                      }
//           }
        
        removeAllAnnotations()
        
        
                                                    
        guard let longitude = self.mapsViewModels[whatIndexOfViewModelInViewModels].longitude else {
            return
        }
        guard let latitude = self.mapsViewModels[whatIndexOfViewModelInViewModels].latitude else {
            return
        }
        guard let name = self.mapsViewModels[whatIndexOfViewModelInViewModels].Name else {
            return
        }
        guard let placeName = self.mapsViewModels[whatIndexOfViewModelInViewModels].placeName else {
            return
        }
    
        print("AAAAAA: \(longitude), \(latitude), \(name), \(placeName)")
        
        self.navigationItem.title = name
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                  
        print("annotation coordinate update view from model: \(annotation.coordinate)")
               
        annotation.title = name
        
        annotation.subtitle = placeName
               
        activityIndicator.startAnimating()
               print("star animating...")
               
        self.mapView.addAnnotation(annotation)
               
               
        self.calculateRoute(from: (self.mapView.userLocation!.coordinate), to: annotation.coordinate) { (route, error) in
        if error != nil {
                   print("Error calculating route")
                   //activityIndicator.stopAnimating()
               }
    }
    }
    
    //MARK: layoutTrait
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        super.traitCollectionDidChange(previousTraitCollection)

        layoutTrait(traitCollection: traitCollection)
    }
   
    func layoutTrait(traitCollection: UITraitCollection)
    {
        if traitCollection.horizontalSizeClass == .compact, traitCollection.verticalSizeClass == .regular {
            
            spacing = 12
            
        }
        else {
            
            spacing = 24
        }
    }
    
    // MARK: Calculate and Draw Route
    func calculateRoute(from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        completion: @escaping (Route?, Error?) -> ()) {
         
            // Coordinate accuracy is the maximum distance away from the waypoint that the route may still be considered viable, measured in meters. Negative values indicate that a indefinite number of meters away from the route and still be considered viable.
            let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
            let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
             
            // Specify that the route is intended for automobiles avoiding traffic
            let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
             
            // Generate the route object and draw it on the map
            _ = Directions.shared.calculate(options) { [unowned self] (waypoints, routes, error) in
            self.directionsRoute = routes?.first
                guard let directionRouteCheck = self.directionsRoute else {
                    return
                }
            // Draw the route on the map after creating it
            self.drawRoute(route: directionRouteCheck)
        }
    }
     
    func drawRoute(route: Route) {
         //mapView.setUserTrackingMode(.none, animated: true, completionHandler: nil)
        guard route.coordinateCount > 0 else { return }
        // Convert the route’s coordinates into a polyline
        var routeCoordinates = route.coordinates!
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
         
        // If there's already a route line on the map, reset its shape to the new route
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
            
            self.mapView.setUserTrackingMode(.none, animated: true, completionHandler: nil)
            activityIndicator.stopAnimating()
            print("stop animating")
        } else {
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
             
            // Customize the route line color and width
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1))
            lineStyle.lineWidth = NSExpression(forConstantValue: 3)
             
            // Add the source and style layer of the route line to the map
            mapView.style?.addSource(source)
            mapView.style?.addLayer(lineStyle)
            
            self.mapView.setUserTrackingMode(.none, animated: true, completionHandler: nil)
            activityIndicator.stopAnimating()
            print("stop animating")
        }
    }
    
    // MARK: Add Annotations
    
    func addAnnotations(longitude: CLLocationDegrees, latitude: CLLocationDegrees, name: String, placeName: String) -> MGLPointAnnotation{
        
        
        
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                      
            print("annotation coordinate update view from model: \(annotation.coordinate)")
                   
            annotation.title = name
            
            annotation.subtitle = placeName
                   
          
            //self.mapView.addAnnotation(annotation)
        return annotation
    }
    
    @objc func getDirectionss(){
           
          print("sdasda")
        activityIndicator.startAnimating()
                   print("star animating...")
                   
            
                   
            self.calculateRoute(from: (self.mapView.userLocation!.coordinate), to: annotation.coordinate) { (route, error) in
            if error != nil {
                       print("Error calculating route")
                       //activityIndicator.stopAnimating()
                   }
        }
           
       }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: searchBarSearchButtonClicked

extension NewMapBoxViewController: UISearchBarDelegate{
      func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
//        mapsViewModel.setMapsModel(mapsModelAccess: PlaceMarkForAllMap.shared[0])
//
//        UpdateViewFromModel()
        
        //annotations
        
                //mapView.removeRoutes()
                
                self.calculateRoute(from: (self.mapView.userLocation!.coordinate), to: (self.mapView.userLocation!.coordinate)) { (route, error) in
                       if error != nil {
                                  print("Error calculating route")
                                  //activityIndicator.stopAnimating()
                              }
                   }
                

        mapView.clearsContextBeforeDrawing = true
        mapView.removeRoutes()
        removeAllAnnotations()

        annotations.removeAll()
        activityIndicator.startAnimating()
        
        var temp = MapsViewModel(modelAccess: .MapBox)
        
        mapsViewModels = PlaceMarkForAllMap.shared.map({ return temp.setMapsModel(mapsModelAccess: $0)})
        
        for i in mapsViewModels.indices{
            print("i:\(i)\n")
        guard let longitude = self.mapsViewModels[i].longitude else {
                   return
               }
               guard let latitude = self.mapsViewModels[i].latitude else {
                   return
               }
               guard let name = self.mapsViewModels[i].Name else {
                   return
               }
               guard let placeName = self.mapsViewModels[i].placeName else {
                   return
               }
            
            let temp = MGLPointAnnotation()
           
            temp.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                      
            print("annotation coordinate update view from model: \(annotation.coordinate)")
                   
            temp.title = name
            
            temp.subtitle = placeName

            //Why it's not work exactly if we use this function? (Test: Print annotations exactly but can not show it in the map!)
            //let temp = addAnnotations(longitude: longitude, latitude: latitude, name: name, placeName: placeName)
            
            
            annotations.append(temp)
            self.mapView.addAnnotation(annotations[i])
            
        }

        
        activityIndicator.stopAnimating()
        
            //UpdateViewFromModel()

            SearchTable.dismiss(animated: true, completion: nil)
   
        }
}

extension NewMapBoxViewController: MGLMapViewDelegate {
    
    //Show annotation information
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
         return true
     }
      
//    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
//        if annotation is MGLUserLocation {
//            //return nil so map view draws "blue dot" for standard user location
//            return nil
//        }
//        let reuseId = "pin"
//        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
//        pinView = MGLAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//        pinView?.tintColor = .orange
//
//        //pinView?.canShowCallout = true
//
//        //pinView?.addSubview(button)
//        return pinView
//    }
    
    func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
    
        let smallSquare = CGSize(width: 30, height: 30)
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(origin: .zero, size: smallSquare)
        button.setBackgroundImage(UIImage(named: "BackButton"), for: .normal)
        button.addTarget(self, action: #selector(getDirectionss), for: .touchUpInside)
       
        return button
    }
    
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
    // Hide the callout view.
    mapView.deselectAnnotation(annotation, animated: false)
     
    activityIndicator.startAnimating()
                   print("star animating...")
                   
            
                   
            self.calculateRoute(from: (self.mapView.userLocation!.coordinate), to: annotation.coordinate) { (route, error) in
            if error != nil {
                       print("Error calculating route")
                       //activityIndicator.stopAnimating()
                   }
        }
    // Show an alert containing the annotation's details
    let alert = UIAlertController(title: annotation.title!!, message: "A lovely (if touristy) place.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
     
    }
     
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        
        print("didSelectannotation")
        
        self.annotation = annotation as! MGLPointAnnotation

//     let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, fromDistance: 4500, pitch: 15, heading: 180)
//
//     mapView.fly(to: camera, withDuration: 4, peakAltitude: 3000, completionHandler: nil)

     }
}

extension NewMapBoxViewController: HandleMapSearch {
    func parseDataFromSearch(viewModel: [MapsViewModel], row: Int) {
        //mapsViewModel = viewModel[row]
        
        //Way 2
        mapsViewModels = viewModel
        whatIndexOfViewModelInViewModels = row
        UpdateViewFromModel()
    }
    
    func addAnnotationAPI(placemark: PlaceMark, row: Int) {
        
    }
    
    func addAnnotationFromSearch(placeMarks: [PlaceMarkForAllMap], row: Int) {
        
       // mapsViewModel.setMapsModel(mapsModelAccess: placeMarks[row])
        
        //UpdateViewFromModel()
        
    }
    
    
}

extension NewMapBoxViewController : ParseDataFromSearch {
    func parseData(data: [PlaceMarkForAllMap]) {
        
       // matchingItems = PlaceMarkForAllMap.shared

        var temp = MapsViewModel(modelAccess: .Google)
        mapsViewModels = data.map({ return temp.setMapsModel(mapsModelAccess: $0)})
       
    }
    
    
}
