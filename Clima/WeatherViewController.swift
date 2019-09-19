//
//  ViewController.swift
//  WeatherApp
//
//  Created by Ahmed Mahmoud 08/2019.
//  Copyright (c) 2019 Berlin's App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SVProgressHUD


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegete {
    
    //Constants
    let locationManger = CLLocationManager()
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "00cf9387fae1f8ac4e2227759d72122d"
    let weatherDateModel = WeatherDataModel()
    var Clecus : Bool = true
   
    var PARAM : [String : String]?
    //var weatherJasonUpdated : JSON;
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    

    
    //Pre-linked IBOutlets
   
    @IBAction func degreeSW(_ sender: UISwitch) {
        if sender.isOn == true{
            Clecus = true
            degreeLabel.text = "℃"
            updatinUIS()
            
            
        }
        else if sender.isOn == false{
            Clecus = false
            degreeLabel.text = "℉"
            updatinUIS()
            
        }
    }
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
        
        updatinUIS()
        //Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(runTimecode), userInfo: nil, repeats: true)
        //TODO:Set up the location manager here.
    }
   
    
    @objc func runTimecode(){
        
        if PARAM != nil{
            getWeatherDate(url: WEATHER_URL, param: PARAM!)
            
        }
        else {
        }
        
    }
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
     func getWeatherDate(url:String , param : [String : String]){
    
        Alamofire.request(url, method: .get,parameters: param).responseJSON{
            response in
            if response.result.isSuccess{
                print(response.result.value!)
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherDate(json: weatherJSON)
                SVProgressHUD.dismiss()
            }
                
            else{
                self.cityLabel.text = "Connection Issues"
                SVProgressHUD.show()
               
            }
            
            
            
        }
        
    }

    //MARK: - JSON Parsing
    /***************************************************************/
    //Write the updateWeatherData method here:
    func updateWeatherDate(json : JSON){
        let tempResult = json["main"]["temp"].double
    
            weatherDateModel.tempratureC = Int(tempResult! - 273.15)
            weatherDateModel.tempratureF = Int((tempResult! * (9/5)) - 459.67)
        
        
        weatherDateModel.city = json["name"].stringValue
        weatherDateModel.condition = json["weather"][0]["id"].intValue
        weatherDateModel.weatherIconName = weatherDateModel.updateWeatherIcon(condition: weatherDateModel.condition)
        
        updatinUIS()
        
        
    }
    
    
    //MARK: - UI Updates
    /***************************************************************/
    //Write the updateUIWithWeatherData method here:
    func updatinUIS(){
        if Clecus == true{
            temperatureLabel.text = String("\(weatherDateModel.tempratureC)°")

        }
        else if Clecus == false{
            temperatureLabel.text = String("\(weatherDateModel.tempratureF)°")

        }
        cityLabel.text = weatherDateModel.city
        weatherIcon.image = UIImage(named: weatherDateModel.weatherIconName)
        
    }
    
    
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0{
            locationManger.stopUpdatingLocation()
            locationManger.delegate = nil
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String ] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            PARAM = params
            
            getWeatherDate(url: WEATHER_URL, param: params)
        }
        
        
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityLabel.text = "Location Unavilable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func UserEnteredaNewCityName(city: String) {
        
        let newParam  : [String : String] = ["q" : city, "appid": APP_ID]
        getWeatherDate(url: WEATHER_URL, param: newParam)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegete = self
        }
        else{
            
        }
    }
        
   
    
    
    
    
}


